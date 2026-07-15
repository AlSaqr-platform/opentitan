// Copyright 2026 Fondazione Chips-IT.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// cfi_syscall_inspector.c — Ibex side, syscall-triggered CFI inspection
//
// Paired with cfi_syscall_monitor.c running on CVA6/Linux.
//
// Execution flow
// --------------
//  1. PLIC + interrupt setup (mirrors mbox_host.c).
//  2. Waits for the Linux launcher to publish the VA→PA table via
//     scratch 12 (CFI_SCRATCH_LAUNCHER_OFF), copies it to TCDM.
//  3. Configures the snooper with the VA range from the table.
//     CORE_HALT_EN is intentionally disabled: the ring is circular and
//     wraps silently.  The last CFI_WINDOW_SIZE entries before any
//     syscall are always readable by seeking to (LAST - WINDOW) in the
//     ring buffer.  Halt would deadlock once CVA6 enters WFI-for-Ibex.
//  4. Signals CVA6 via scratch 13 (SYNC_IBEX_CFI_READY) — launcher
//     releases the monitored process.
//  5. Enters WFI loop; all work happens in external_irq_handler().
//
// IRQ handler (PLIC IRQ 159, mbox 1 doorbell from CVA6)
// -------------------------------------------------------
//  CFI_MSG_SYSCALL:
//    a. Reads cur_last from the snooper LAST register.
//    b. Seeks to (cur_last - CFI_WINDOW_SIZE * ENTRY_SIZE) mod RING_BYTES.
//    c. Reads up to CFI_WINDOW_SIZE entries into cfi_window[].
//    d. Optionally DMA-fetches basic block instructions to L2 (ENABLE_FETCH).
//    e. Writes CFI_RESULT_PASS to scratch 14 (placeholder for PMCA analysis).
//
//  CFI_MSG_APP_DONE:
//    Disarms snooper, sets app_done flag — main loop exits WFI.
//
// PMCA hook
// ---------
//  cfi_window[] and cfi_window_count are declared as non-static globals
//  so they are accessible at a known address from the PMCA side once the
//  shared-memory interface is wired up.  The DMA'd instruction words land
//  in L2_SHARED_BASE + i * L2_BUF_SIZE.  Replace the CFI_RESULT_PASS write
//  with a PMCA offload call when the NN inference is ready.

#include <stdint.h>
#include "utils.h"
#include "regs/snooper_regs.h"
#include "host_uart.h"
#include "idma.h"
#include "cfi_va_pa_table.h"
#include "cfi_syscall_proto.h"
#include "mailboxes.h"
#include "cfi_syscall_inspector.h"

// OpenTitan DIF / runtime
#include "sw/device/lib/dif/dif_rv_plic.h"
#include "sw/device/lib/base/mmio.h"
#include "sw/device/lib/runtime/irq.h"

#ifndef VERBOSE
#define VERBOSE 1
#endif
#define LOG(fmt, ...) do { if (VERBOSE) printf(fmt, ##__VA_ARGS__); } while (0)

// Set to 1 to DMA-fetch basic block instructions to L2 for each window entry.
// Required for future PMCA/NN analysis.  Set to 0 to skip fetches and only
// record the (pc_src, pc_dst, ctr_type) tuples.
#ifndef ENABLE_FETCH
#define ENABLE_FETCH 1
#endif

// Set to 1 to print every fetched basic block (address + raw instruction
// words) to UART after the monitored app exits.  Requires ENABLE_FETCH=1;
// has no effect when ENABLE_FETCH=0.
#ifndef DUMP_FETCH
#define DUMP_FETCH 1
#endif

// Set to 1 to collect per-phase cycle statistics across all inspect_window()
// calls.  Printed in main() after app_done, before the final "done" line.
// Per-syscall averages: ring_read (all N entries), va_to_pa (all N calls),
// dma_issue, dma_wait, and full inspect_window() total.
// Overhead in the gap between phases: 5 fixed csrr reads + 6 per DMA entry.
// Calibrated at runtime; subtracted from the reported overhead line.
#ifndef ENABLE_STATS
#define ENABLE_STATS 0
#endif

// ---------------------------------------------------------------------------
// Address constants
// ---------------------------------------------------------------------------
#define BASE_SNPRCFG    ((void *)0x15000000u)
#define BASE_SNPR       (0x16000000u)
#define IDMA_BASE       (0xfef00000u)
#define L2_SHARED_BASE  (0xA0010000u)   // DMA destination for BB instructions
#define L2_BUF_SIZE     4096u           // bytes reserved per window entry

// ---------------------------------------------------------------------------
// Snooper ring geometry (must match hardware)
// ---------------------------------------------------------------------------
#define SNPR_RING_BYTES  16380u
#define ENTRY_SIZE       20u             // 5 × 32-bit words per ring entry

// ---------------------------------------------------------------------------
// Mbox 1 base address (MBOX_BASE_ADDR + 1 * MBOX_STRIDE)
// ---------------------------------------------------------------------------
// Base address of the mailbox peripheral on this platform
#define MBOX_BASE_ADDR  0x40000000
// Each mailbox instance occupies 0x100 bytes
#define MBOX_STRIDE     0x100
// PLIC IRQ ID for the incoming mailbox interrupt (mbox 1)
#define MBOX_IRQ_ID     159
#define MBOX1_BASE  (MBOX_BASE_ADDR + 1u * MBOX_STRIDE)

// ---------------------------------------------------------------------------
// Globals shared with IRQ handler (and future PMCA interface)
// ---------------------------------------------------------------------------
snooper_entry_t cfi_window[CFI_WINDOW_SIZE];  // last N entries before syscall
uint32_t        cfi_window_count;             // valid entries in cfi_window[]

#if ENABLE_FETCH
// Number of bytes actually DMA'd for each cfi_window entry; 0 if the PA
// translation failed.  Used by dump_last_window() to know how many words
// to print per basic block.
static uint32_t fetch_bytes[CFI_WINDOW_SIZE];
#endif

static uint32_t drain_ptr  = 0;   // SW read pointer (updated after each inspection)
static int      app_done   = 0;

static cfi_va_pa_table_t local_tbl;
static uint32_t va_start_l, va_start_h;
static uint32_t va_end_l,   va_end_h;

static void *host_regs;
static dif_rv_plic_t plic;

#if ENABLE_STATS
// Per-phase cycle accumulators — summed over all inspect_window() calls.
// Divide by stat_syscall_count for per-syscall averages (printed in main()).
// ring_read / va_to_pa / dma_issue / dma_wait are each sub-totals within one
// call; overhead = inspect_total - ring_read - va_to_pa - dma_issue - dma_wait.
static uint32_t stat_syscall_count     = 0;
static uint32_t stat_inspect_total_cyc = 0;  // full inspect_window() per call
static uint32_t stat_ring_read_cyc     = 0;  // N×5 AXI loads from BASE_SNPR
static uint32_t stat_va_to_pa_cyc      = 0;  // N cfi_va_to_pa() TCDM scans
static uint32_t stat_dma_issue_cyc     = 0;  // N idma_set_addrs()+idma_launch()
static uint32_t stat_dma_wait_cyc      = 0;  // idma_wait() stalls (in-loop + final)
#endif

// ---------------------------------------------------------------------------
// inspect_window — called from IRQ handler on each CFI_MSG_SYSCALL
// ---------------------------------------------------------------------------
static void inspect_window(void) {
    // Mark result as busy before reading ring so CVA6 sees a clean sentinel.
    *reg32(host_regs, CFI_SCRATCH_RESULT_OFF) = (int)CFI_RESULT_BUSY;
    fence();
#if ENABLE_STATS
    uint32_t _s0, _s1, _t_insp_start;
    asm volatile ("csrr %0, mcycle" : "=r"(_t_insp_start));
#endif

    uint32_t cur_last = (uint32_t)*reg32(BASE_SNPRCFG, CFG_REGS_LAST_REG_OFFSET);

    // Compute how many new entries are available since the last drain.
    uint32_t depth;
    if (cur_last >= drain_ptr)
        depth = cur_last - drain_ptr;
    else
        depth = SNPR_RING_BYTES - drain_ptr + cur_last;

    // Clamp to what the ring can actually hold (overflow detection).
    if (depth > SNPR_RING_BYTES)
        depth = SNPR_RING_BYTES;

    // Decide how many entries to capture: last min(available, WINDOW_SIZE).
    uint32_t avail   = depth / ENTRY_SIZE;
    uint32_t n       = (avail < CFI_WINDOW_SIZE) ? avail : (uint32_t)CFI_WINDOW_SIZE;
    uint32_t use_bytes = n * ENTRY_SIZE;

    // Seek to (cur_last - use_bytes) mod RING_BYTES — the start of the window.
    uint32_t rptr;
    if (cur_last >= use_bytes)
        rptr = cur_last - use_bytes;
    else
        rptr = SNPR_RING_BYTES - (use_bytes - cur_last);

    // ---- DEBUG: snooper pointer trace (set DEBUG_PTR 0 to silence) ----------
    //   last : write pointer  (advances on every recorded branch)
    //   base : oldest pointer  (advances only after the ring has wrapped once)
    //   dl   : bytes recorded since the previous syscall (0 => nothing captured)
    //   ctrl : CTRL readback  (bit0=U_MODE, bit5=PC_RANGE_2 must stay set)
    // If last/dl never change, CVA6 stopped feeding CTR records — the ring is
    // fine, the input stream stopped.  If ctrl drops bit0/bit5, the enables got
    // auto-cleared (trigger).  If last climbs but the window is stale, the
    // seek/read is wrong.
#ifndef DEBUG_PTR
#define DEBUG_PTR 1
#endif
#if DEBUG_PTR
    {
        static uint32_t dbg_prev = 0, dbg_n = 0;
        uint32_t base = (uint32_t)*reg32(BASE_SNPRCFG, CFG_REGS_BASE_REG_OFFSET);
        uint32_t ctrl = (uint32_t)*reg32(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET);
        uint32_t dl   = (cur_last >= dbg_prev)
                        ? (cur_last - dbg_prev)
                        : (SNPR_RING_BYTES - dbg_prev + cur_last);
        LOG("[insp] #%u last=0x%x base=0x%x dl=%u depth=%u n=%u rptr=0x%x ctrl=0x%08x\n\r",
            (unsigned)dbg_n, (unsigned)cur_last, (unsigned)base, (unsigned)dl,
            (unsigned)depth, (unsigned)n, (unsigned)rptr, (unsigned)ctrl);
        dbg_prev = cur_last; dbg_n++;
    }
#endif

    // Read the window entries.  Ring memory is random-accessible via AXI
    // offset into BASE_SNPR — we can seek freely without affecting LAST.
    cfi_window_count = 0;
#if ENABLE_STATS
    asm volatile ("csrr %0, mcycle" : "=r"(_s0));
#endif
    for (uint32_t i = 0; i < n; i++) {
        cfi_window[i].pc_src_l = (uint32_t)*reg32((void *)BASE_SNPR, rptr + 0x00);
        cfi_window[i].pc_src_h = (uint32_t)*reg32((void *)BASE_SNPR, rptr + 0x04);
        cfi_window[i].pc_dst_l = (uint32_t)*reg32((void *)BASE_SNPR, rptr + 0x08);
        cfi_window[i].pc_dst_h = (uint32_t)*reg32((void *)BASE_SNPR, rptr + 0x0C);
        cfi_window[i].ctr_type = (uint32_t)*reg32((void *)BASE_SNPR, rptr + 0x10);
        rptr += ENTRY_SIZE;
        if (rptr >= SNPR_RING_BYTES) rptr -= SNPR_RING_BYTES;
        cfi_window_count++;
    }
#if ENABLE_STATS
    asm volatile ("csrr %0, mcycle" : "=r"(_s1));
    stat_ring_read_cyc += _s1 - _s0;
#endif

    // Advance drain_ptr to cur_last — mark ring up to here as consumed.
    drain_ptr = cur_last;

#if ENABLE_FETCH
    // DMA-fetch basic block instructions for each window entry.
    // BB start = previous entry's pc_dst (or current pc_src as fallback).
    // BB end   = current pc_src + 4 bytes (last branch instruction).
    // Both src and dst are virtual addresses; translate dst to PA for DMA.
    for (uint32_t i = 0; i < CFI_WINDOW_SIZE; i++) fetch_bytes[i] = 0u;

    if (n > 0) {
        idma_set_conf(IDMA_BASE, IDMA_CONF_1D_AXI_TO_AXI);
        idma_reg_write(IDMA_BASE, IDMA_REPS_2_LOW_REG_OFFSET, 1u);
    }

    idma_txn_id_t last_id = IDMA_INVALID_ID;

    for (uint32_t i = 0; i < n; i++) {
        // BB start: previous entry's destination (chain continuity).
        uint32_t bb_va_l = (i > 0) ? cfi_window[i - 1].pc_dst_l : cfi_window[i].pc_src_l;
        uint32_t bb_va_h = (i > 0) ? cfi_window[i - 1].pc_dst_h : cfi_window[i].pc_src_h;

        // Fall back to pc_src if the previous dst is outside the monitored range.
        if (bb_va_h != va_start_h ||
            bb_va_l  < va_start_l ||
            bb_va_l >= va_end_l) {
            bb_va_l = cfi_window[i].pc_src_l;
            bb_va_h = cfi_window[i].pc_src_h;
        }

#if ENABLE_STATS
        asm volatile ("csrr %0, mcycle" : "=r"(_s0));
#endif
        uint32_t bb_pa = cfi_va_to_pa(&local_tbl, bb_va_h, bb_va_l);
#if ENABLE_STATS
        asm volatile ("csrr %0, mcycle" : "=r"(_s1));
        stat_va_to_pa_cyc += _s1 - _s0;
#endif
        if (bb_pa == 0u)
            continue;   // fetch_bytes[i] stays 0

        // Byte count: from BB start to (pc_src + 4), clamped to L2_BUF_SIZE.
        uint32_t bytes;
        if (cfi_window[i].pc_src_h != bb_va_h ||
            cfi_window[i].pc_src_l  < bb_va_l) {
            bytes = 4u;  // guard against underflow on backward branch
        } else {
            bytes = (cfi_window[i].pc_src_l - bb_va_l) + 4u;
            if (bytes > L2_BUF_SIZE) bytes = L2_BUF_SIZE;
        }
        fetch_bytes[i] = bytes;

        uint32_t dst = L2_SHARED_BASE + i * L2_BUF_SIZE;

        // Wait for previous DMA before issuing the next (serialised for now;
        // pipeline once the PMCA consumer side is wired up).
#if ENABLE_STATS
        asm volatile ("csrr %0, mcycle" : "=r"(_s0));
#endif
        if (last_id != IDMA_INVALID_ID)
            idma_wait(IDMA_BASE, last_id);
#if ENABLE_STATS
        asm volatile ("csrr %0, mcycle" : "=r"(_s1));
        stat_dma_wait_cyc += _s1 - _s0;
        asm volatile ("csrr %0, mcycle" : "=r"(_s0));
#endif
        idma_set_addrs(IDMA_BASE, bb_pa, dst, bytes);
        last_id = idma_launch(IDMA_BASE);
#if ENABLE_STATS
        asm volatile ("csrr %0, mcycle" : "=r"(_s1));
        stat_dma_issue_cyc += _s1 - _s0;
#endif
    }

#if ENABLE_STATS
    asm volatile ("csrr %0, mcycle" : "=r"(_s0));
#endif
    if (last_id != IDMA_INVALID_ID)
        idma_wait(IDMA_BASE, last_id);
#if ENABLE_STATS
    asm volatile ("csrr %0, mcycle" : "=r"(_s1));
    stat_dma_wait_cyc += _s1 - _s0;
#endif
#endif

    // --- PMCA hook ---
    // Replace this write with a PMCA offload call once the NN is ready.
    // The cfi_window[] array and L2_SHARED_BASE slots are already populated.
    *reg32(host_regs, CFI_SCRATCH_RESULT_OFF) = (int)CFI_RESULT_PASS;
    fence();
#if ENABLE_STATS
    {
        uint32_t _t_insp_end;
        asm volatile ("csrr %0, mcycle" : "=r"(_t_insp_end));
        stat_inspect_total_cyc += _t_insp_end - _t_insp_start;
        stat_syscall_count++;
    }
#endif
}

// ---------------------------------------------------------------------------
// dump_last_window — print the last inspection window to UART.
// Enabled at compile time with -DDUMP_FETCH=1.
// Prints (pc_src, pc_dst, ctr_type) for every entry and decodes the
// instruction stream from L2 using the same halfword walk used in
// snooper_fetch_linux (RVI = 4-byte when hw[1:0]==0b11, else RVC = 2-byte).
// Called from main() after app_done, outside of any IRQ context.
// ---------------------------------------------------------------------------
#if DUMP_FETCH && ENABLE_FETCH
static void dump_last_window(void) {
    LOG("[insp] === fetch dump: %u entries ===\n\r",
        (unsigned)cfi_window_count);
    for (uint32_t i = 0; i < cfi_window_count; i++) {
        LOG("[insp] [%u] src=0x%x_%08x  dst=0x%x_%08x  type=%u\n\r",
            (unsigned)i,
            (unsigned)cfi_window[i].pc_src_h,
            (unsigned)cfi_window[i].pc_src_l,
            (unsigned)cfi_window[i].pc_dst_h,
            (unsigned)cfi_window[i].pc_dst_l,
            (unsigned)cfi_window[i].ctr_type);

        uint32_t nb = fetch_bytes[i];
        if (nb == 0u) {
            LOG("[insp]      (no fetch)\n\r");
            continue;
        }

        uint32_t base = L2_SHARED_BASE + i * L2_BUF_SIZE;
        uint32_t byte_off = 0u;
        while (byte_off < nb) {
            uint16_t hw0 = *(volatile uint16_t *)(base + byte_off);
            if ((hw0 & 0x3u) == 0x3u) {
                uint16_t hw1   = *(volatile uint16_t *)(base + byte_off + 2u);
                uint32_t instr = (uint32_t)hw0 | ((uint32_t)hw1 << 16);
                LOG("[insp]      +0x%03x: 0x%08x\n\r",
                    (unsigned)byte_off, (unsigned)instr);
                byte_off += 4u;
            } else {
                LOG("[insp]      +0x%03x: 0x%04x (RVC)\n\r",
                    (unsigned)byte_off, (unsigned)hw0);
                byte_off += 2u;
            }
        }
    }
    LOG("[insp] === end dump ===\n\r");
}
#endif

// ---------------------------------------------------------------------------
// external_irq_handler — fires on PLIC IRQ 159 (mbox 1 doorbell from CVA6)
// ---------------------------------------------------------------------------
void external_irq_handler(void) {
    dif_rv_plic_irq_id_t irq_id;

    if (dif_rv_plic_irq_claim(&plic, 0, &irq_id) != kDifOk) return;
    if (irq_id != MBOX_IRQ_ID) {
        if (irq_id != 0)
            (void)dif_rv_plic_irq_complete(&plic, 0, irq_id);
        return;
    }

    // Read and clear the mbox interrupt before processing, so a second
    // doorbell from CVA6 can be detected while we are in this handler.
    volatile int *p;
    p  = (volatile int *)(MBOX1_BASE + ARCHI_MAILBOX_IRQ_SND_SET_OFFSET);
    *p = 0;
    p  = (volatile int *)(MBOX1_BASE + ARCHI_MAILBOX_IRQ_SND_EN_OFFSET);
    *p = 0;
    p  = (volatile int *)(MBOX1_BASE + ARCHI_MAILBOX_IRQ_SND_CLR_OFFSET);
    *p = 1;
    fence();

    // Decode message from letter0.
    uint32_t msg = (uint32_t)*(volatile int *)(MBOX1_BASE + ARCHI_MAILBOX_LETTER0_OFFSET);
    uint32_t msg_type = msg & CFI_MSG_TYPE_MASK;

    if (msg_type == CFI_MSG_APP_DONE) {
        // Disarm snooper: disable U-mode monitoring and halt.
        *reg32(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET) = 0u;
        fence();
        app_done = 1;
        LOG("[insp] app done\n\r");
    } else if (msg_type == CFI_MSG_SYSCALL) {
        uint32_t nr = msg & CFI_MSG_SYSCALL_NR_MASK;
        (void)nr;   // available for logging / future policy use
        inspect_window();
        LOG("[insp] syscall %u: window=%u\n\r", (unsigned)nr, (unsigned)cfi_window_count);
    } else {
        // Unknown message: write PASS to avoid stalling CVA6.
        *reg32(host_regs, CFI_SCRATCH_RESULT_OFF) = (int)CFI_RESULT_PASS;
        fence();
        LOG("[insp] unknown msg 0x%08x\n\r", (unsigned)msg);
    }

    (void)dif_rv_plic_irq_complete(&plic, 0, irq_id);
}

// ---------------------------------------------------------------------------
// main
// ---------------------------------------------------------------------------
int main(void) {
    LOG("[insp] cfi_syscall_inspector: start\n\r");

    host_regs = (void *)HOST_REGS_BASE_ADDR;

    // -----------------------------------------------------------------------
    // 1. Interrupt / PLIC setup (mirrors mbox_host.c)
    // -----------------------------------------------------------------------
    irq_set_vector_offset(0xe0000001);
    irq_global_ctrl(true);
    irq_external_ctrl(true);

    plic.base_addr = mmio_region_from_addr(0xC8000000);
    (void)dif_rv_plic_reset(&plic);
    (void)dif_rv_plic_target_set_threshold(&plic, 0, 0);
    (void)dif_rv_plic_irq_set_priority(&plic, MBOX_IRQ_ID, 1);
    (void)dif_rv_plic_irq_set_enabled(&plic, MBOX_IRQ_ID, 0, kDifToggleEnabled);

    // -----------------------------------------------------------------------
    // 2. Wait for the Linux launcher to publish the VA→PA table
    // -----------------------------------------------------------------------
    volatile const cfi_va_pa_table_t *shared_tbl =
        (volatile const cfi_va_pa_table_t *)CFI_TABLE_PHYS_BASE;

    while (*reg32(host_regs, CFI_SCRATCH_LAUNCHER_OFF) != (int)SYNC_TABLE_PUBLISHED)
        ;
    *reg32(host_regs, CFI_SCRATCH_LAUNCHER_OFF) = 0u;
    fence();

    if (shared_tbl->ready != CFI_TABLE_READY_MAGIC ||
        shared_tbl->magic != CFI_TABLE_MAGIC) {
        LOG("[insp] ERROR: bad CFI table\n\r");
        return 1;
    }

    // Copy table to TCDM for fast cfi_va_to_pa() lookups in the IRQ handler.
    {
        volatile const uint8_t *src = (volatile const uint8_t *)CFI_TABLE_PHYS_BASE;
        uint8_t *dst = (uint8_t *)&local_tbl;
        for (uint32_t i = 0; i < (uint32_t)sizeof(local_tbl); i++)
            dst[i] = src[i];
        fence();
    }

    va_start_l = local_tbl.va_range_start_l;
    va_start_h = local_tbl.va_range_start_h;
    va_end_l   = local_tbl.va_range_end_l;
    va_end_h   = local_tbl.va_range_end_h;
    LOG("[insp] VA range 0x%x_%08x – 0x%x_%08x  segs=%u\n\r",
        (unsigned)va_start_h, (unsigned)va_start_l,
        (unsigned)va_end_h,   (unsigned)va_end_l,
        (unsigned)local_tbl.num_segs);

    // -----------------------------------------------------------------------
    // 3. Configure snooper
    //
    //    CORE_HALT_EN is disabled.  The ring wraps silently when full.
    //    inspect_window() always reads the last CFI_WINDOW_SIZE entries
    //    by seeking to (LAST - WINDOW_BYTES) in the ring address space,
    //    so overflow between syscalls does not corrupt the window.
    // -----------------------------------------------------------------------
    *reg32(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET) = 0u;
    fence();

    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_2_BASE_H_REG_OFFSET) = va_start_h;
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_2_BASE_L_REG_OFFSET) = va_start_l;
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_2_LAST_H_REG_OFFSET) = va_end_h;
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_2_LAST_L_REG_OFFSET) = va_end_l;

    *reg32(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET) |=
        (1u << CFG_REGS_CTRL_U_MODE_BIT) |
        (1u << CFG_REGS_CTRL_PC_RANGE_2_BIT);
    // Trace mode = ADDRESS (0): 20-byte PC_SRC/PC_DST/CTR_TYPE records, matching
    // ENTRY_SIZE.  Set explicitly (clear the field) rather than relying on the
    // zeroed CTRL above — mirrors snooper_fetch_linux.c.
    *reg32(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET) &=
        ~(CFG_REGS_CTRL_TRACE_MODE_MASK << CFG_REGS_CTRL_TRACE_MODE_OFFSET);
    // Explicitly leave CORE_HALT_EN = 0 and WATERMARK_EN = 0.
    fence();

    // -----------------------------------------------------------------------
    // 4. Acknowledge: tell launcher the snooper is armed
    // -----------------------------------------------------------------------
    *reg32(host_regs, CFI_SCRATCH_IBEX_OFF) = (int)SYNC_IBEX_CFI_READY;
    fence();
    LOG("[insp] snooper armed, waiting for syscalls\n\r");

    // -----------------------------------------------------------------------
    // 5. WFI loop — all work happens in external_irq_handler()
    // -----------------------------------------------------------------------
    while (!app_done)
        asm volatile ("wfi");

#if ENABLE_STATS
    {
        uint32_t n = stat_syscall_count ? stat_syscall_count : 1u;
        uint32_t avg_total    = stat_inspect_total_cyc / n;
        uint32_t avg_ring     = stat_ring_read_cyc     / n;
        uint32_t avg_vatopa   = stat_va_to_pa_cyc      / n;
        uint32_t avg_issue    = stat_dma_issue_cyc     / n;
        uint32_t avg_wait     = stat_dma_wait_cyc      / n;
        uint32_t avg_overhead = avg_total - avg_ring - avg_vatopa - avg_issue - avg_wait;

        // Calibrate csrr mcycle read latency with two back-to-back reads.
        uint32_t _cal0, _cal1;
        asm volatile ("csrr %0, mcycle" : "=r"(_cal0));
        asm volatile ("csrr %0, mcycle" : "=r"(_cal1));
        uint32_t csrr_cyc_cal = _cal1 - _cal0;

        // csrr reads whose execution time falls in the overhead gap (not inside
        // any named phase): 5 fixed + 6 per DMA entry (ENABLE_FETCH=1), or
        // 3 fixed (ENABLE_FETCH=0).  Use CFI_WINDOW_SIZE as the entry count.
#if ENABLE_FETCH
        uint32_t n_csrr       = 5u + 6u * (uint32_t)CFI_WINDOW_SIZE;
#else
        uint32_t n_csrr       = 3u;
#endif
        uint32_t csrr_cost    = n_csrr * csrr_cyc_cal;
        uint32_t logic_ovhd   = (avg_overhead > csrr_cost) ? avg_overhead - csrr_cost : 0u;

        LOG("[insp] stats over %u syscalls (csrr=%u cyc, window=%u):\n\r",
            (unsigned)stat_syscall_count, (unsigned)csrr_cyc_cal, (unsigned)CFI_WINDOW_SIZE);
        LOG("[insp]   ring_read     avg=%4u cyc  (N×5 AXI loads from BASE_SNPR)\n\r",  (unsigned)avg_ring);
        LOG("[insp]   va_to_pa      avg=%4u cyc  (N cfi_va_to_pa TCDM scans)\n\r",     (unsigned)avg_vatopa);
        LOG("[insp]   dma_issue     avg=%4u cyc  (N idma_set_addrs+idma_launch)\n\r",  (unsigned)avg_issue);
        LOG("[insp]   dma_wait      avg=%4u cyc  (idma_wait stalls, in-loop+final)\n\r",(unsigned)avg_wait);
        LOG("[insp]   csrr_cost     avg=%4u cyc  (%u reads x %u cyc, window=%u)\n\r",
            (unsigned)csrr_cost, (unsigned)n_csrr,
            (unsigned)csrr_cyc_cal, (unsigned)CFI_WINDOW_SIZE);
        LOG("[insp]   logic_ovhd    avg=%4u cyc  (overhead - csrr_cost)\n\r",          (unsigned)logic_ovhd);
        LOG("[insp]   inspect_total avg=%4u cyc\n\r",                                   (unsigned)avg_total);
    }
#endif

#if DUMP_FETCH && ENABLE_FETCH
    dump_last_window();
#endif

    // Reset snooper to a clean state.
    *reg32(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET) |=  (1u << CFG_REGS_CTRL_CNT_RST_BIT);
    fence();
    *reg32(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET) = 0u;
    fence();

    LOG("[insp] done\n\r");
    return 0;
}
