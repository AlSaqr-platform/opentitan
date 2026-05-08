// Copyright 2026 Fondazione Chips-IT.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// snooper_fetch_linux.c — Ibex side, Linux-aware CFI fetch
//
// Paired with cfi_launcher.c running on CVA6 Linux.
//
// Differences from snooper_fetch_test.c (bare-metal)
// ---------------------------------------------------
//  1. SYNC PROTOCOL  — uses scratch 12/13 (CFI_SCRATCH_LAUNCHER_OFF /
//     CFI_SCRATCH_IBEX_OFF) instead of scratch 10/11.  No dummy_start/end
//     in scratch regs; the shared VA→PA table carries that information.
//
//  2. SNOOPER RANGES — set to *virtual* addresses (tbl->va_range_start/end)
//     because Linux MMU is on: the snooper taps the CVA6 pipeline before
//     TLB and therefore logs virtual PCs.
//
//  3. MODE BITS      — enables U_MODE_BIT (bit 0) for user-space apps.
//     Enabling S_MODE_BIT (bit 1) additionally monitors kernel/supervisor
//     code (optional, typically not needed for application CFI).
//
//  4. VA→PA LOOKUP   — before every iDMA fetch, calls cfi_va_to_pa() to
//     translate the virtual fetch_start into a physical address.
//     Byte count is still computed in VA space (valid as long as the basic
//     block stays within a single physically-contiguous page run — holds
//     for all normal compiled code; see cfi_va_pa_table.h for details).
//
//  5. DONE CONDITION — detects SYNC_APP_DONE from the launcher instead of
//     SYNC_FETCH_DONE from a bare-metal CVA6 test.
//
//  6. SINGLE RUN     — no second measurement run; the launcher exits after
//     the app, and Ibex exits after draining the ring completely.
//
// DMA mode
// --------
//  Only USE_DMA 2 (pipelined, one in-flight) is implemented here; it is the
//  best single-channel mode for latency hiding without competing ARs on the
//  serialiser.  Extend to mode 3 (batched) if throughput becomes the limit.

#include <stdint.h>
#include "utils.h"
#include "regs/snooper_regs.h"
#include "host_uart.h"
#include "idma.h"
#include "cfi_va_pa_table.h"

#ifndef VERBOSE
#define VERBOSE 1
#endif
#define LOG(fmt, ...) do { if (VERBOSE) printf(fmt, ##__VA_ARGS__); } while (0)

// Set to 0 to drain the ring without issuing any iDMA transfers.
// Useful for isolating snooper/halt overhead from DMA bus contention.
#ifndef ENABLE_FETCH
#define ENABLE_FETCH 1
#endif

// Set to 0 to disable the hardware halt mechanism (CVA6 runs freely).
// When ENABLE_FETCH=0 this must also be 0 (Ibex won't drain the ring
// via AXI so the snooper would never see the level drop).
#ifndef ENABLE_HALT
#define ENABLE_HALT 1
#endif

// Set to 1 to collect per-phase cycle statistics in the drain loop.
// Printed before the DONE line as a full timeline breakdown.
// Adds ~14 csrr mcycle reads per entry (~56 cycles overhead when enabled).
#ifndef ENABLE_STATS
#define ENABLE_STATS 1
#endif

// ---------------------------------------------------------------------------
// Address map (same physical layout as snooper_fetch_test.c)
// ---------------------------------------------------------------------------
#define BASE_SNPRCFG   ((void *)0x15000000u)
#define BASE_SNPR      (0x16000000u)
#define IDMA_BASE      (0xfef00000u)
#define L2_SHARED_BASE (0xA0010000u)   // instruction DMA destination

// CFI_TABLE_PHYS_BASE is defined in cfi_va_pa_table.h (0xA0000000)

// ---------------------------------------------------------------------------
// Snooper ring geometry
// ---------------------------------------------------------------------------
#define SNPR_RING_BYTES    16380u
#define ENTRY_SIZE         20u

// Halt level in bytes written to the register — derive entry count from it
// so the software depth counters always stay in sync with hardware.
#define HALT_LEVEL_BYTES   16300u          // written to CFG_REGS_HALT_LEVEL_REG_OFFSET
#define HALT_LEVEL_ENTRIES (HALT_LEVEL_BYTES / ENTRY_SIZE)  // 400 entries
#define HALT_HYSTERESIS    100u                 // entries below threshold before re-arming
#define OVERFLOW_GRACE     10u                  // entries above threshold before flagging overflow

// ---------------------------------------------------------------------------
// main
// ---------------------------------------------------------------------------
int main(void) {
    LOG("[secd] snooper_fetch_linux: start\n\r");

    void *host_regs = (void *)HOST_REGS_BASE_ADDR;

    // Pointer to the shared VA→PA table in physical memory.
    volatile const cfi_va_pa_table_t *tbl =
        (volatile const cfi_va_pa_table_t *)CFI_TABLE_PHYS_BASE;

    // ------------------------------------------------------------------
    // 1. Wait for the Linux launcher to publish the VA→PA table.
    //    The launcher writes CFI_TABLE_READY_MAGIC as the last field,
    //    then writes SYNC_TABLE_PUBLISHED to scratch 12.
    // ------------------------------------------------------------------
    while (*reg32(host_regs, CFI_SCRATCH_LAUNCHER_OFF) != (int)SYNC_TABLE_PUBLISHED)
        ;

    // Sanity-check the table header.
    if (tbl->ready != CFI_TABLE_READY_MAGIC || tbl->magic != CFI_TABLE_MAGIC) {
        // LOG("[secd] ERROR: CFI table not valid (magic=0x%x ready=0x%x)\n\r",
        //     (unsigned)tbl->magic, (unsigned)tbl->ready);
        return 1;
    }

    uint32_t va_start_l = tbl->va_range_start_l;
    uint32_t va_start_h = tbl->va_range_start_h;
    uint32_t va_end_l   = tbl->va_range_end_l;
    uint32_t va_end_h   = tbl->va_range_end_h;
    LOG("[secd] VA range: 0x%x_%08x - 0x%x_%08x  segs=%u\n\r",
        (unsigned)va_start_h, (unsigned)va_start_l,
        (unsigned)va_end_h,   (unsigned)va_end_l,
        (unsigned)tbl->num_segs);

    // ------------------------------------------------------------------
    // 1b. Copy VA→PA table into local TCDM.
    //     cfi_va_to_pa() is called once per ring entry; keeping the table
    //     in local memory avoids an AXI round-trip to the shared SPM on
    //     every lookup (num_segs accesses per entry at SPM latency).
    //     The copy is small (sizeof(cfi_va_pa_table_t) = 540 bytes) and
    //     done once before the drain loop starts.
    // ------------------------------------------------------------------
    static cfi_va_pa_table_t local_tbl;
    {
        idma_txn_id_t copy_id = idma_issue_1d(
            IDMA_BASE,
            CFI_TABLE_PHYS_BASE,
            (uint32_t)&local_tbl,
            sizeof(cfi_va_pa_table_t),
            IDMA_CONF_1D_AXI_TO_AXI);
        idma_wait(IDMA_BASE, copy_id);
    }

    // ------------------------------------------------------------------
    // 2. Configure snooper.
    //    Ranges are set to *virtual* addresses — the snooper filters on
    //    the virtual PC logged from the CVA6 pipeline.
    //    U_MODE_BIT monitors user-space code (Linux apps run in U-mode).
    //    Add S_MODE_BIT to also cover kernel code if desired.
    // ------------------------------------------------------------------

    // Reset CTRL to a known-zero state first so bits from a previous run
    // (e.g. CORE_HALT_EN, WATERMARK_EN, PC_RANGE_x) do not persist.
    *reg32(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET) = 0u;
    fence();

    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_2_BASE_H_REG_OFFSET) = va_start_h;
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_2_BASE_L_REG_OFFSET) = va_start_l;
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_2_LAST_H_REG_OFFSET) = va_end_h;
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_2_LAST_L_REG_OFFSET) = va_end_l;

    // Enable U-mode monitoring (bit 0).
    *reg32(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET) |= (1u << CFG_REGS_CTRL_U_MODE_BIT);

    // Addr mode: log PC_SRC / PC_DST / CTR_TYPE.
    *reg32(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET) &=
        ~(CFG_REGS_CTRL_TRACE_MODE_MASK << CFG_REGS_CTRL_TRACE_MODE_OFFSET);

    // Halt: stall CVA6 when ring reaches HALT_LEVEL_BYTES unread bytes.
    *reg32(BASE_SNPRCFG, CFG_REGS_HALT_LEVEL_REG_OFFSET) = HALT_LEVEL_BYTES;
#if ENABLE_HALT
    *reg32(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET) |=  (1u << CFG_REGS_CTRL_CORE_HALT_EN_BIT);
#else
    *reg32(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET) &= ~(1u << CFG_REGS_CTRL_CORE_HALT_EN_BIT);
#endif

    // Watermark: disabled.
    *reg32(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET) &= ~(1u << CFG_REGS_CTRL_WATERMARK_EN_BIT);

    // Enable RANGE_2.
    *reg32(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET) |= (1u << CFG_REGS_CTRL_PC_RANGE_2_BIT);
    fence();

    // ------------------------------------------------------------------
    // 3. Acknowledge: tell the launcher the snooper is armed.
    //    The launcher will PTRACE_CONT the application at this point.
    // ------------------------------------------------------------------
    *reg32(host_regs, CFI_SCRATCH_IBEX_OFF) = SYNC_IBEX_CFI_READY;
    fence();
    // LOG("[secd] Snooper armed. Application running.\n\r");

    // ------------------------------------------------------------------
    // 4. Drain loop (pipelined DMA, USE_DMA-2 style)
    //
    //    KEY DIFFERENCE from bare-metal:
    //    - pc_src_l / pc_dst_l / prev_dst_va are all *virtual* addresses.
    //    - Before issuing the DMA we translate: PA = cfi_va_to_pa(tbl, VA).
    //    - Byte count is computed in VA space (pc_src_l - fetch_start_va)
    //      which equals the byte count in PA space as long as the basic
    //      block does not cross a physical page boundary (see header).
    //
    //    DONE CONDITION: launcher sets SYNC_APP_DONE when the monitored
    //    process exits.  We drain any remaining ring entries before exiting.
    // ------------------------------------------------------------------
    uint32_t drain_ptr        = 0;
    uint32_t fetch_count      = 0;
    uint32_t entry_count      = 0;  // total snooper ring entries consumed
    uint32_t max_ring_depth_bytes = 0;  // high-water mark in bytes (divide once at LOG, not per entry)
#if ENABLE_STATS
    // Per-phase cycle accumulators.  All averaged by entry_count (non-skip entries).
    // overhead = total_entry - ring_read - va_to_pa - dma_issue - ctr_type - dma_wait
    uint32_t stat_ring_read_cyc   = 0;  // 4× AXI loads from BASE_SNPR
    uint32_t stat_va_to_pa_cyc    = 0;  // cfi_va_to_pa() TCDM table scan
    uint32_t stat_dma_issue_cyc   = 0;  // idma_issue_1d() descriptor write
    uint32_t stat_ctr_type_cyc    = 0;  // ctr_type AXI load (after issue)
    uint32_t stat_dma_wait_cyc    = 0;  // idma_wait() residual stall on prev DMA
    uint32_t stat_entry_total_cyc = 0;  // full non-skip entry (entry start → drain_ptr advance)
#endif
    uint32_t halt_count      = 0;  // number of times ring depth crossed halt threshold
    int      in_halt         = 0;  // edge-detect state
    int      overflow_suspected = 0; // depth exceeded halt+10 grace → halt may not have protected
    uint32_t prev_dst_va_l = 0;  // initialise to 0 so first entry always falls back to pc_src
    uint32_t prev_dst_va_h = 0;
    uint32_t l2_write_ptr = 0;
    int      app_done     = 0;

    // Cycle counter — Ibex mcycle is a 64-bit CSR; read low 32 bits only.
    // Wrap-around at 2^32 cycles (~42 s at 100 MHz); sufficient for any single run.
    uint32_t t_start, t_end;
    asm volatile ("csrr %0, mcycle" : "=r"(t_start));

    idma_txn_id_t pending_dma_id = IDMA_INVALID_ID;

#if ENABLE_FETCH
    // CONF and REPS_2 are constant for every 1D AXI→AXI transfer in the drain
    // loop.  Write them once here so idma_issue_1d() is replaced by the cheaper
    // idma_set_addrs() + idma_launch() sequence (3 writes + 1 read instead of 5).
    idma_set_conf(IDMA_BASE, IDMA_CONF_1D_AXI_TO_AXI);
    idma_reg_write(IDMA_BASE, IDMA_REPS_2_LOW_REG_OFFSET, 1u);
#endif

    do {
        if (!app_done &&
            *reg32(host_regs, CFI_SCRATCH_LAUNCHER_OFF) == (int)SYNC_APP_DONE) {
            app_done = 1;
            // Stop accepting new entries so LAST freezes and the ring drains cleanly.
            *reg32(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET) &=
                ~(1u << CFG_REGS_CTRL_PC_RANGE_2_BIT);
            fence();
        }

        // Read cur_last ONCE per batch: amortises the ~30-cycle AXI read over
        // every entry available in this snapshot instead of paying it per entry.
        uint32_t cur_last =
            (uint32_t)*reg32(BASE_SNPRCFG, CFG_REGS_LAST_REG_OFFSET);
        if (drain_ptr == cur_last)
            continue;

        // Depth tracking in byte domain: avoids __udivsi3 (~35 cyc, no HW
        // divider on Ibex) every entry.  One divide per batch for batch_entries.
        uint32_t depth_bytes = (cur_last >= drain_ptr)
            ? (cur_last - drain_ptr)
            : (SNPR_RING_BYTES - drain_ptr + cur_last);
        if (depth_bytes > max_ring_depth_bytes)
            max_ring_depth_bytes = depth_bytes;
        if (depth_bytes >= HALT_LEVEL_BYTES + OVERFLOW_GRACE * ENTRY_SIZE)
            overflow_suspected = 1;
        if (depth_bytes >= HALT_LEVEL_BYTES) {
            if (!in_halt) { halt_count++; in_halt = 1; }
        } else if (depth_bytes < HALT_LEVEL_BYTES - HALT_HYSTERESIS * ENTRY_SIZE) {
            in_halt = 0;
        }

        uint32_t batch_entries = depth_bytes / ENTRY_SIZE;

        for (uint32_t i = 0; i < batch_entries; i++) {
            // Read one snooper entry.  All 5 words must be consumed in order —
            // each 32-bit AXI read advances the snooper's internal read pointer.
            // ctr_type is deferred to after idma_issue_1d so its ~30-cycle
            // latency overlaps with the descriptor write.
#if ENABLE_STATS
            uint32_t _s0, _s1, _t_entry;
            asm volatile ("csrr %0, mcycle" : "=r"(_t_entry));
            asm volatile ("csrr %0, mcycle" : "=r"(_s0));
#endif
            uint32_t pc_src_l = *reg32((void *)BASE_SNPR, drain_ptr + 0x00);
            uint32_t pc_src_h = *reg32((void *)BASE_SNPR, drain_ptr + 0x04);
            uint32_t pc_dst_l = *reg32((void *)BASE_SNPR, drain_ptr + 0x08);
            uint32_t pc_dst_h = *reg32((void *)BASE_SNPR, drain_ptr + 0x0C);
#if ENABLE_STATS
            asm volatile ("csrr %0, mcycle" : "=r"(_s1));
            uint32_t _ring_this = _s1 - _s0;
#endif
            // ctr_type consumed below, after idma_issue_1d.

            // Determine the virtual start of the basic block (H/L).
            uint32_t fetch_start_va_l = prev_dst_va_l;
            uint32_t fetch_start_va_h = prev_dst_va_h;
            // Fallback to pc_src if prev_dst is outside the monitored range.
            if (fetch_start_va_h != va_start_h ||
                fetch_start_va_l < va_start_l  ||
                fetch_start_va_l >= va_end_l) {
                fetch_start_va_l = pc_src_l;
                fetch_start_va_h = pc_src_h;
            }

            // Translate fetch_start to PA for the DMA source address.
            // pc_src is hardware-guaranteed in-range (snooper range filter) so a
            // second cfi_va_to_pa call for pc_src is unnecessary.
#if ENABLE_STATS
            asm volatile ("csrr %0, mcycle" : "=r"(_s0));
#endif
            uint32_t fetch_start_pa = cfi_va_to_pa(&local_tbl, fetch_start_va_h, fetch_start_va_l);
#if ENABLE_STATS
            asm volatile ("csrr %0, mcycle" : "=r"(_s1));
            uint32_t _vatopa_this = _s1 - _s0;
#endif

            entry_count++;

            // Skip DMA if fetch_start VA→PA translation missed (returns 0).
            if (fetch_start_pa == 0u) {
                (void)*reg32((void *)BASE_SNPR, drain_ptr + 0x10); // consume ctr_type
                prev_dst_va_l = pc_dst_l;
                prev_dst_va_h = pc_dst_h;
                drain_ptr += ENTRY_SIZE;
                if (drain_ptr >= SNPR_RING_BYTES)
                    drain_ptr = 0;
                continue; // skip stats: don't pollute averages with degenerate entries
            }

            // Accumulate ring_read and va_to_pa only for non-skip entries so all
            // per-phase stats share the same denominator (dma_count).
#if ENABLE_STATS
            stat_ring_read_cyc += _ring_this;
            stat_va_to_pa_cyc  += _vatopa_this;
#endif

            // Guard against uint32 underflow on backward branches.
            uint32_t bytes;
            if (pc_src_h != fetch_start_va_h || pc_src_l < fetch_start_va_l) {
                bytes = 4u;
            } else {
                bytes = (pc_src_l - fetch_start_va_l) + 4u;
            }

            // Issue DMA[n]; wait for DMA[n-1].
            // DMA[n] runs in the background while CPU processes next entry.
#if ENABLE_FETCH
            {
#if ENABLE_STATS
                asm volatile ("csrr %0, mcycle" : "=r"(_s0));
#endif
                idma_set_addrs(IDMA_BASE, fetch_start_pa,
                               L2_SHARED_BASE + l2_write_ptr, bytes);
                idma_txn_id_t new_id = idma_launch(IDMA_BASE);
#if ENABLE_STATS
                asm volatile ("csrr %0, mcycle" : "=r"(_s1));
                stat_dma_issue_cyc += _s1 - _s0;
                asm volatile ("csrr %0, mcycle" : "=r"(_s0));
#endif
                // Consume ctr_type: pointer advance is mandatory; latency overlaps
                // with DMA descriptor propagation rather than blocking issue.
                (void)*reg32((void *)BASE_SNPR, drain_ptr + 0x10);
#if ENABLE_STATS
                asm volatile ("csrr %0, mcycle" : "=r"(_s1));
                stat_ctr_type_cyc += _s1 - _s0;
                asm volatile ("csrr %0, mcycle" : "=r"(_s0));
#endif
                if (pending_dma_id != IDMA_INVALID_ID)
                    idma_wait(IDMA_BASE, pending_dma_id);
#if ENABLE_STATS
                asm volatile ("csrr %0, mcycle" : "=r"(_s1));
                stat_dma_wait_cyc += _s1 - _s0;
#endif
                pending_dma_id = new_id;
            }
            fetch_count  += (bytes + 3u) >> 2;
            l2_write_ptr += bytes;
#else
            (void)*reg32((void *)BASE_SNPR, drain_ptr + 0x10); // consume ctr_type
            fetch_count  += (bytes + 3u) >> 2;
#endif

            prev_dst_va_l = pc_dst_l;
            prev_dst_va_h = pc_dst_h;
            drain_ptr  += ENTRY_SIZE;
            if (drain_ptr >= SNPR_RING_BYTES)
                drain_ptr = 0;
#if ENABLE_STATS
            asm volatile ("csrr %0, mcycle" : "=r"(_s1));
            stat_entry_total_cyc += _s1 - _t_entry;
#endif
        }

    } while (!app_done ||
             (uint32_t)*reg32(BASE_SNPRCFG, CFG_REGS_LAST_REG_OFFSET) != drain_ptr);

    // Flush last in-flight DMA.
#if ENABLE_FETCH
    if (pending_dma_id != IDMA_INVALID_ID)
        idma_wait(IDMA_BASE, pending_dma_id);
#endif

    asm volatile ("csrr %0, mcycle" : "=r"(t_end));
    uint32_t cycles = t_end - t_start;
    // Convert to ms: cycles / (freq_MHz * 1000).  Adjust IBEX_FREQ_MHZ if needed.
#ifndef IBEX_FREQ_MHZ
#define IBEX_FREQ_MHZ 50u
#endif
    uint32_t ms = cycles / (IBEX_FREQ_MHZ * 1000u);
    // ------------------------------------------------------------------
    // 5. Reset snooper ring.
    // ------------------------------------------------------------------
    *reg32(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET) |=  (1u << CFG_REGS_CTRL_CNT_RST_BIT);
    *reg32(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET) &= ~(1u << CFG_REGS_CTRL_CNT_RST_BIT);

#if ENABLE_STATS
    {
        uint32_t n = entry_count ? entry_count : 1u;
        uint32_t avg_total    = stat_entry_total_cyc / n;
        uint32_t avg_ring     = stat_ring_read_cyc   / n;
        uint32_t avg_vatopa   = stat_va_to_pa_cyc    / n;
        uint32_t avg_issue    = stat_dma_issue_cyc   / n;
        uint32_t avg_ctrtype  = stat_ctr_type_cyc    / n;
        uint32_t avg_wait     = stat_dma_wait_cyc    / n;
        uint32_t avg_overhead = avg_total - avg_ring - avg_vatopa
                              - avg_issue - avg_ctrtype - avg_wait;
        LOG("[secd] stats over %u entries (entry_count):\n\r", (unsigned)entry_count);
        LOG("[secd]   ring_read   avg=%4u cyc  (4x AXI load BASE_SNPR)\n\r",   (unsigned)avg_ring);
        LOG("[secd]   va_to_pa    avg=%4u cyc  (TCDM table scan)\n\r",          (unsigned)avg_vatopa);
        LOG("[secd]   dma_issue   avg=%4u cyc  (idma descriptor write)\n\r",   (unsigned)avg_issue);
        LOG("[secd]   ctr_type    avg=%4u cyc  (AXI load after issue)\n\r",    (unsigned)avg_ctrtype);
        LOG("[secd]   dma_wait    avg=%4u cyc  (residual stall prev DMA)\n\r", (unsigned)avg_wait);
        LOG("[secd]   overhead    avg=%4u cyc  (checks, ptr advance, loop)\n\r",(unsigned)avg_overhead);
        LOG("[secd]   total_entry avg=%4u cyc\n\r",                             (unsigned)avg_total);
    }
#endif
    LOG("[secd] snooper_fetch_linux: entries=%u fetched=%u words, max_depth=%u halts=%u cycles=%u ms=%u fetch=%d halt=%d%s DONE\n\r",
        (unsigned)entry_count, (unsigned)fetch_count,
        (unsigned)(max_ring_depth_bytes / ENTRY_SIZE), (unsigned)halt_count,
        (unsigned)cycles, (unsigned)ms,
        ENABLE_FETCH, ENABLE_HALT,
        overflow_suspected ? " OVERFLOW_RISK" : "");
    return 0;
}
