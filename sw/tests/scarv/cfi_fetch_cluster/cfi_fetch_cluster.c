// Copyright 2026 Fondazione Chips-IT.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// cfi_fetch_cluster.c — Ibex side: Linux-aware CFI fetch + cluster offload
//
// Derived from snooper_fetch_linux.c.  Key additions vs the parent:
//
//  CLUSTER BOOT
//  ------------
//  Before arming the snooper Ibex boots the PULP cluster and waits for its
//  first CTRL_CLUSTER_DONE signal (the cluster's "I'm alive" handshake).
//
//  CHAIN ACCUMULATION
//  ------------------
//  The drain loop counts snooper entries.  Every CFI_CHAIN_STRIDE-th valid
//  entry is designated as one of the three basic blocks in a chain.  When
//  all three slots are filled the Ibex fills the control block and writes
//  CTRL_IBEX_CHAIN_READY.  It then continues draining immediately — the
//  cluster works in parallel.
//
//  CLUSTER SYNC (polling, no interrupt on Ibex)
//  ------------
//  Before overwriting a slot that still belongs to an in-flight chain Ibex
//  must wait for CTRL_CLUSTER_DONE.  With CFI_CHAIN_STRIDE=2 and three slots
//  this means Ibex blocks only if the cluster falls more than one chain behind
//  — typically never for a 100 MHz cluster vs 50 MHz Ibex.
//
//  DONE
//  ----
//  After the ring is drained and the last chain has been handed off, Ibex
//  waits for the cluster's final CTRL_CLUSTER_DONE, then reads LETTER0 from
//  the SND mailbox to confirm the cluster completed cleanly.
//
//  SYNC PROTOCOL (scratch registers)
//  ----------------------------------
//  Reuses the same scratch 12/13 protocol as snooper_fetch_linux.c.

#include <stdint.h>
#include "utils.h"
#include "regs/snooper_regs.h"
#include "host_uart.h"
#include "idma.h"
#include "cfi_va_pa_table.h"
#include "mailboxes.h"
#include "cfi_fetch_cluster.h"

#ifndef VERBOSE
#define VERBOSE 1
#endif
#define LOG(fmt, ...) do { if (VERBOSE) printf(fmt, ##__VA_ARGS__); } while (0)

#ifndef ENABLE_FETCH
#define ENABLE_FETCH 1
#endif

#ifndef ENABLE_HALT
#define ENABLE_HALT 1
#endif

// ---------------------------------------------------------------------------
// Address map
// ---------------------------------------------------------------------------
#define BASE_SNPRCFG   ((void *)0x15000000u)
#define BASE_SNPR      (0x16000000u)
#define IDMA_BASE      (0xfef00000u)

// Cluster control (security-island peripheral bus)
#define CLUSTER_BOOT_ADDR_REG   0xB0200040u
#define CLUSTER_FETCH_EN_REG    0xBF000000u
#define CLUSTER_CLK_EN_REG      0xBF000008u
#define EDN_EN_ADDR_REG         0xC1170014u
#define CLUSTER_NUM_CORES       8u
#define CLUSTER_ENTRY_ADDR      0xA0008080u  // cluster-side binary entry (L2_PRIV1)

// Mailbox (Ibex polls SND side to receive doorbell from cluster)
// ARCHI_MAILBOX_IRQ_SND_STAT_OFFSET = 0x0 → polled by Ibex
#define MBOX_SND_STAT_ADDR   (MAILBOX_BASE_ADDR + ARCHI_MAILBOX_IRQ_SND_STAT_OFFSET)
#define MBOX_SND_CLR_ADDR    (MAILBOX_BASE_ADDR + ARCHI_MAILBOX_IRQ_SND_CLR_OFFSET)
#define MBOX_SND_EN_ADDR     (MAILBOX_BASE_ADDR + ARCHI_MAILBOX_IRQ_SND_EN_OFFSET)
#define MBOX_LETTER0_ADDR    (MAILBOX_BASE_ADDR + ARCHI_MAILBOX_LETTER0_OFFSET)

// ---------------------------------------------------------------------------
// Snooper ring geometry
// ---------------------------------------------------------------------------
#define SNPR_RING_BYTES    16380u
#define ENTRY_SIZE         20u
#define HALT_LEVEL_BYTES   16000u
#define HALT_LEVEL_ENTRIES (HALT_LEVEL_BYTES / ENTRY_SIZE)
#define HALT_HYSTERESIS    100u
#define OVERFLOW_GRACE     10u

// ---------------------------------------------------------------------------
// Helpers for the shared control block
// ---------------------------------------------------------------------------
static inline volatile uint32_t *ctrl_reg(uint32_t off) {
    return (volatile uint32_t *)(CFI_CTRL_BASE + off);
}

// ---------------------------------------------------------------------------
// Cluster boot helper
// ---------------------------------------------------------------------------
static void cluster_boot(void)
{
    volatile uint32_t *edn = (volatile uint32_t *)EDN_EN_ADDR_REG;
    *edn = 0x9996u;

    // Set boot address for all 8 cores
    for (uint32_t i = 0; i < CLUSTER_NUM_CORES; i++) {
        volatile uint32_t *ba = (volatile uint32_t *)(CLUSTER_BOOT_ADDR_REG + 4u * i);
        *ba = CLUSTER_ENTRY_ADDR;
    }

    // Enable cluster clock then release fetch
    volatile uint32_t *clk_en   = (volatile uint32_t *)CLUSTER_CLK_EN_REG;
    volatile uint32_t *fetch_en = (volatile uint32_t *)CLUSTER_FETCH_EN_REG;
    *clk_en   = 0x1u;
    *fetch_en = 0x1u;
    fence();
}

// ---------------------------------------------------------------------------
// Wait for the cluster to ack a chain (CTRL_CLUSTER_DONE or CTRL_CLUSTER_EXIT)
// ---------------------------------------------------------------------------
static inline void wait_cluster_done(void)
{
    while (*ctrl_reg(CFI_CTRL_CLUSTER_DONE_OFF) == CTRL_IDLE)
        ;
    // Reset the flag so we can detect the next completion
    *ctrl_reg(CFI_CTRL_CLUSTER_DONE_OFF) = CTRL_IDLE;
    fence();
}

// ---------------------------------------------------------------------------
// Publish one chain to the cluster
// ---------------------------------------------------------------------------
static void publish_chain(uint32_t chain_id,
                          uint32_t off0, uint32_t sz0,
                          uint32_t off1, uint32_t sz1,
                          uint32_t off2, uint32_t sz2)
{
    // Fill per-block metadata
    *ctrl_reg(CFI_CTRL_BLK0_OFF_OFF) = off0;
    *ctrl_reg(CFI_CTRL_BLK1_OFF_OFF) = off1;
    *ctrl_reg(CFI_CTRL_BLK2_OFF_OFF) = off2;
    *ctrl_reg(CFI_CTRL_BLK0_SZ_OFF)  = sz0;
    *ctrl_reg(CFI_CTRL_BLK1_SZ_OFF)  = sz1;
    *ctrl_reg(CFI_CTRL_BLK2_SZ_OFF)  = sz2;
    *ctrl_reg(CFI_CTRL_CHAIN_ID_OFF)  = chain_id;
    fence();
    // Signal cluster: new chain ready (written last, acts as store fence)
    *ctrl_reg(CFI_CTRL_IBEX_READY_OFF) = CTRL_IBEX_CHAIN_READY;
    fence();
}

// ---------------------------------------------------------------------------
// main
// ---------------------------------------------------------------------------
int main(void) {
    LOG("[secd] cfi_fetch_cluster: start\n\r");

    void *host_regs = (void *)HOST_REGS_BASE_ADDR;

    // ------------------------------------------------------------------
    // 0. Initialise shared control block
    // ------------------------------------------------------------------
    *ctrl_reg(CFI_CTRL_IBEX_READY_OFF)   = CTRL_IDLE;
    *ctrl_reg(CFI_CTRL_CHAIN_ID_OFF)     = 0u;
    *ctrl_reg(CFI_CTRL_CLUSTER_DONE_OFF) = CTRL_IDLE;
    fence();

    // ------------------------------------------------------------------
    // 0b. Boot the cluster.
    //     The cluster test polls CFI_CTRL_IBEX_READY_OFF from its side.
    //     Before booting we expect the first CTRL_CLUSTER_DONE to come
    //     once the cluster is initialised and ready (handshake ping).
    // ------------------------------------------------------------------
    cluster_boot();
    LOG("[secd] cluster booted, waiting for cluster ready ping...\n\r");
    wait_cluster_done();
    LOG("[secd] cluster ready.\n\r");

    // ------------------------------------------------------------------
    // 1. Wait for the Linux launcher to publish the VA→PA table
    // ------------------------------------------------------------------
    volatile const cfi_va_pa_table_t *tbl =
        (volatile const cfi_va_pa_table_t *)CFI_TABLE_PHYS_BASE;

    while (*reg32(host_regs, CFI_SCRATCH_LAUNCHER_OFF) != (int)SYNC_TABLE_PUBLISHED)
        ;

    if (tbl->ready != CFI_TABLE_READY_MAGIC || tbl->magic != CFI_TABLE_MAGIC) {
        LOG("[secd] ERROR: CFI table invalid\n\r");
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
    // 1b. Copy VA→PA table into local TCDM for fast lookups
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
    // 2. Configure snooper (virtual address ranges, U-mode, halt)
    // ------------------------------------------------------------------
    *reg32(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET) = 0u;
    fence();

    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_2_BASE_H_REG_OFFSET) = va_start_h;
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_2_BASE_L_REG_OFFSET) = va_start_l;
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_2_LAST_H_REG_OFFSET) = va_end_h;
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_2_LAST_L_REG_OFFSET) = va_end_l;

    *reg32(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET) |= (1u << CFG_REGS_CTRL_U_MODE_BIT);
    *reg32(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET) &=
        ~(CFG_REGS_CTRL_TRACE_MODE_MASK << CFG_REGS_CTRL_TRACE_MODE_OFFSET);
    *reg32(BASE_SNPRCFG, CFG_REGS_HALT_LEVEL_REG_OFFSET) = HALT_LEVEL_BYTES;
#if ENABLE_HALT
    *reg32(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET) |=  (1u << CFG_REGS_CTRL_CORE_HALT_EN_BIT);
#else
    *reg32(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET) &= ~(1u << CFG_REGS_CTRL_CORE_HALT_EN_BIT);
#endif
    *reg32(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET) &= ~(1u << CFG_REGS_CTRL_WATERMARK_EN_BIT);
    *reg32(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET) |=  (1u << CFG_REGS_CTRL_PC_RANGE_2_BIT);
    fence();

    // ------------------------------------------------------------------
    // 3. Acknowledge launcher: snooper armed
    // ------------------------------------------------------------------
    *reg32(host_regs, CFI_SCRATCH_IBEX_OFF) = SYNC_IBEX_CFI_READY;
    fence();

    // ------------------------------------------------------------------
    // 4. Set up pre-written iDMA CONF/REPS so the inner loop is cheap
    // ------------------------------------------------------------------
#if ENABLE_FETCH
    idma_set_conf(IDMA_BASE, IDMA_CONF_1D_AXI_TO_AXI);
    idma_reg_write(IDMA_BASE, IDMA_REPS_2_LOW_REG_OFFSET, 1u);
#endif

    // ------------------------------------------------------------------
    // 5. Drain loop — sliding-window chain accumulation
    //
    //    Every non-skip snooper entry is a basic block.  Entries are
    //    numbered 0-based (e = 0, 1, 2, ...).  A chain is three
    //    consecutive entries with a step of 2 between chain starts:
    //
    //      chain 0 → entries [0, 1, 2]
    //      chain 1 → entries [2, 3, 4]   (overlap: entry 2 shared)
    //      chain 2 → entries [4, 5, 6]   (overlap: entry 4 shared)
    //      ...
    //
    //    Publish condition (0-based e): e >= 2 && (e % 2 == 0)
    //      → chain = entries [e-2, e-1, e]
    //
    //    Slot rotation (3 L2 slots, 0-based):
    //      entry e → slot s = e % 3
    //      chain at e uses slots  (e-2)%3, (e-1)%3, e%3
    //
    //    Backpressure:
    //      Entry e=3,5,7,… writes the slot that was block-0 of the
    //      just-published chain (one entry lag).  Before that DMA,
    //      wait for CTRL_CLUSTER_DONE so we don't overwrite live data.
    //      Condition: e >= 3 && (e % 2 == 1)
    // ------------------------------------------------------------------
    uint32_t drain_ptr      = 0;
    uint32_t entry_count    = 0;    // 0-based index of next non-skip entry
    uint32_t chain_count    = 0;    // chains published
    uint32_t max_depth_b    = 0;
    uint32_t halt_count     = 0;
    int      in_halt        = 0;
    int      overflow_risk  = 0;
    int      app_done       = 0;

    uint32_t prev_dst_va_l  = 0;
    uint32_t prev_dst_va_h  = 0;

    // blk_sz[s]: bytes written to slot s in the current pass (reset each time
    //            a slot is overwritten).
    uint32_t blk_sz[3] = {0u, 0u, 0u};

    // Set after every publish_chain(); cleared when the inner-loop backpressure
    // wait consumes CTRL_CLUSTER_DONE for that chain.  Used at the end to
    // decide whether a final wait is needed — avoids a double-consume deadlock.
    int need_final_cluster_wait = 0;

    idma_txn_id_t pending_dma_id = IDMA_INVALID_ID;

    uint32_t t_start;
    asm volatile ("csrr %0, mcycle" : "=r"(t_start));

    do {
        // Check app-done from launcher
        if (!app_done &&
            *reg32(host_regs, CFI_SCRATCH_LAUNCHER_OFF) == (int)SYNC_APP_DONE) {
            app_done = 1;
            *reg32(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET) &=
                ~(1u << CFG_REGS_CTRL_PC_RANGE_2_BIT);
            fence();
        }

        uint32_t cur_last =
            (uint32_t)*reg32(BASE_SNPRCFG, CFG_REGS_LAST_REG_OFFSET);
        if (drain_ptr == cur_last)
            continue;

        uint32_t depth_b = (cur_last >= drain_ptr)
            ? (cur_last - drain_ptr)
            : (SNPR_RING_BYTES - drain_ptr + cur_last);
        if (depth_b > max_depth_b)        max_depth_b = depth_b;
        if (depth_b >= HALT_LEVEL_BYTES + OVERFLOW_GRACE * ENTRY_SIZE)
            overflow_risk = 1;
        if (depth_b >= HALT_LEVEL_BYTES) {
            if (!in_halt) { halt_count++; in_halt = 1; }
        } else if (depth_b < HALT_LEVEL_BYTES - HALT_HYSTERESIS * ENTRY_SIZE) {
            in_halt = 0;
        }

        uint32_t batch = depth_b / ENTRY_SIZE;

        for (uint32_t i = 0; i < batch; i++) {
            // Read the first 4 words of the snooper entry
            uint32_t pc_src_l = *reg32((void *)BASE_SNPR, drain_ptr + 0x00);
            uint32_t pc_src_h = *reg32((void *)BASE_SNPR, drain_ptr + 0x04);
            uint32_t pc_dst_l = *reg32((void *)BASE_SNPR, drain_ptr + 0x08);
            uint32_t pc_dst_h = *reg32((void *)BASE_SNPR, drain_ptr + 0x0C);

            // Determine fetch_start VA (fallback to pc_src if prev_dst out of range)
            uint32_t fetch_start_va_l = prev_dst_va_l;
            uint32_t fetch_start_va_h = prev_dst_va_h;
            if (fetch_start_va_h != va_start_h ||
                fetch_start_va_l < va_start_l  ||
                fetch_start_va_l >= va_end_l) {
                fetch_start_va_l = pc_src_l;
                fetch_start_va_h = pc_src_h;
            }

            uint32_t fetch_start_pa =
                cfi_va_to_pa(&local_tbl, fetch_start_va_h, fetch_start_va_l);

            if (fetch_start_pa == 0u) {
                // consume ctr_type and advance — do NOT increment entry_count
                (void)*reg32((void *)BASE_SNPR, drain_ptr + 0x10);
                prev_dst_va_l = pc_dst_l;
                prev_dst_va_h = pc_dst_h;
                drain_ptr += ENTRY_SIZE;
                if (drain_ptr >= SNPR_RING_BYTES) drain_ptr = 0;
                continue;
            }

            // After the app exits its backing physical pages may have been
            // freed by the OS.  Any iDMA read from those PAs would issue an
            // AXI transaction with no responder and hang indefinitely.
            // Drain bare: consume ctr_type and advance drain_ptr without
            // issuing any DMA or chain work.
            if (app_done) {
                (void)*reg32((void *)BASE_SNPR, drain_ptr + 0x10);
                prev_dst_va_l = pc_dst_l;
                prev_dst_va_h = pc_dst_h;
                drain_ptr += ENTRY_SIZE;
                if (drain_ptr >= SNPR_RING_BYTES) drain_ptr = 0;
                continue;
            }

            // Valid non-skip entry: assign slot by 0-based index e
            uint32_t e    = entry_count;        // 0-based
            uint32_t slot = e % 3u;
            entry_count++;

            uint32_t bytes;
            if (pc_src_h != fetch_start_va_h || pc_src_l < fetch_start_va_l)
                bytes = 4u;
            else
                bytes = (pc_src_l - fetch_start_va_l) + 4u;

            // ----------------------------------------------------------
            // Backpressure: entry at e=3,5,7,… will overwrite the slot
            // that was block-0 of the previously published chain.
            // Wait for CTRL_CLUSTER_DONE before that DMA.
            // ----------------------------------------------------------
            if (e >= 3u && (e % 2u == 1u)) {
                while (*ctrl_reg(CFI_CTRL_CLUSTER_DONE_OFF) == CTRL_IDLE)
                    ;
                *ctrl_reg(CFI_CTRL_CLUSTER_DONE_OFF) = CTRL_IDLE;
                fence();
                // We just consumed CTRL_CLUSTER_DONE for the previous chain;
                // the final wait below must not wait again for the same signal.
                need_final_cluster_wait = 0;
            }

            // DMA basic block into its rotating L2 slot
            uint32_t dst_pa = CFI_INSTR_BASE + slot * CFI_INSTR_SLOT_BYTES;
            blk_sz[slot] = bytes;

#if ENABLE_FETCH
            idma_set_addrs(IDMA_BASE, fetch_start_pa, dst_pa, bytes);
            idma_txn_id_t new_id = idma_launch(IDMA_BASE);
            (void)*reg32((void *)BASE_SNPR, drain_ptr + 0x10); // consume ctr_type
            if (pending_dma_id != IDMA_INVALID_ID)
                idma_wait(IDMA_BASE, pending_dma_id);
            pending_dma_id = new_id;
#else
            (void)*reg32((void *)BASE_SNPR, drain_ptr + 0x10);
#endif

            // ----------------------------------------------------------
            // Publish: chain is complete when e >= 2 && e % 2 == 0
            //   chain uses entries [e-2, e-1, e] → slots (e-2)%3, (e-1)%3, e%3
            // ----------------------------------------------------------
            if (e >= 2u && (e % 2u == 0u)) {
#if ENABLE_FETCH
                if (pending_dma_id != IDMA_INVALID_ID) {
                    idma_wait(IDMA_BASE, pending_dma_id);
                    pending_dma_id = IDMA_INVALID_ID;
                }
#endif
                uint32_t s0 = (e - 2u) % 3u;
                uint32_t s1 = (e - 1u) % 3u;
                uint32_t s2 =  e       % 3u;
                publish_chain(
                    chain_count,
                    s0 * CFI_INSTR_SLOT_BYTES, blk_sz[s0],
                    s1 * CFI_INSTR_SLOT_BYTES, blk_sz[s1],
                    s2 * CFI_INSTR_SLOT_BYTES, blk_sz[s2]);
                chain_count++;
                need_final_cluster_wait = 1;
            }

            prev_dst_va_l = pc_dst_l;
            prev_dst_va_h = pc_dst_h;
            drain_ptr    += ENTRY_SIZE;
            if (drain_ptr >= SNPR_RING_BYTES) drain_ptr = 0;
        }

    } while (!app_done ||
             (uint32_t)*reg32(BASE_SNPRCFG, CFG_REGS_LAST_REG_OFFSET) != drain_ptr);

    // ------------------------------------------------------------------
    // 6. Flush last in-flight DMA and wait for cluster to finish last chain
    // ------------------------------------------------------------------
#if ENABLE_FETCH
    if (pending_dma_id != IDMA_INVALID_ID)
        idma_wait(IDMA_BASE, pending_dma_id);
#endif

    // Wait for the cluster to finish the last published chain.
    // Skip if need_final_cluster_wait is false — that means the backpressure
    // path already consumed CTRL_CLUSTER_DONE for the last chain and waiting
    // again would deadlock.
    if (chain_count > 0 && need_final_cluster_wait) {
        while (*ctrl_reg(CFI_CTRL_CLUSTER_DONE_OFF) == CTRL_IDLE)
            ;
        *ctrl_reg(CFI_CTRL_CLUSTER_DONE_OFF) = CTRL_IDLE;
        fence();
    }

    // ------------------------------------------------------------------
    // 7. Signal cluster to exit and wait for its SND doorbell
    // ------------------------------------------------------------------
    *ctrl_reg(CFI_CTRL_IBEX_READY_OFF) = CTRL_CLUSTER_EXIT;
    fence();

    // Poll SND_STAT: the cluster rings its SND doorbell after seeing EXIT
    // while (*(volatile uint32_t *)MBOX_SND_STAT_ADDR == 0u)
    //     ;
    uint32_t cluster_ret = *(volatile uint32_t *)MBOX_LETTER0_ADDR;
    // Clear the SND interrupt
    *(volatile uint32_t *)MBOX_SND_CLR_ADDR = 0x1u;
    *(volatile uint32_t *)MBOX_SND_EN_ADDR  = 0x0u;

    // ------------------------------------------------------------------
    // 8. Reset snooper ring
    // ------------------------------------------------------------------
    *reg32(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET) |=  (1u << CFG_REGS_CTRL_CNT_RST_BIT);
    *reg32(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET) &= ~(1u << CFG_REGS_CTRL_CNT_RST_BIT);

    // Disable cluster
    *(volatile uint32_t *)CLUSTER_FETCH_EN_REG = 0x0u;

    uint32_t t_end;
    asm volatile ("csrr %0, mcycle" : "=r"(t_end));
#ifndef IBEX_FREQ_MHZ
#define IBEX_FREQ_MHZ 50u
#endif
    uint32_t cycles = t_end - t_start;
    uint32_t ms     = cycles / (IBEX_FREQ_MHZ * 1000u);

    LOG("[secd] cfi_fetch_cluster: entries=%u chains=%u max_depth=%u halts=%u "
        "cycles=%u ms=%u cluster_ret=%u%s DONE\n\r",
        (unsigned)entry_count, (unsigned)chain_count,
        (unsigned)(max_depth_b / ENTRY_SIZE), (unsigned)halt_count,
        (unsigned)cycles, (unsigned)ms, (unsigned)cluster_ret,
        overflow_risk ? " OVERFLOW_RISK" : "");

    return (int)cluster_ret;
}
