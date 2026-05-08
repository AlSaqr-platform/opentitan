// Copyright 2026 Fondazione Chips-IT.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// cfi_va_pa_table.h — Shared VA→PA segment table
//
// This structure lives at CFI_TABLE_PHYS_BASE in physical memory, a region
// that is simultaneously:
//  - accessible to Ibex firmware as a direct-mapped physical address, and
//  - mappable by Linux on CVA6 via /dev/mem or a CMA-reserved region.
//
// Purpose
// -------
// Under Linux the snooper logs *virtual* PCs (CVA6 pipeline taps pre-TLB).
// Ibex's iDMA works with *physical* addresses.  This table bridges the gap:
// the Linux launcher populates it with (va_base, pa_base, num_pages) tuples
// for every executable VMA in the monitored process, then signals Ibex.
// Ibex walks the table to translate each snooped VA before issuing a DMA.
//
// Assumptions (valid for a first prototype)
// ------------------------------------------
//  1. Monitored code pages are mlocked before the snooper is armed — no
//     page migration or swap-out occurs while the table is in use.
//  2. Basic blocks fit within a single physically-contiguous page run — the
//     DMA byte-length is computed in VA space and the source PA is the
//     translation of fetch_start only.  Cross-page-boundary basic blocks
//     will produce a wrong fetch (uncommon for normal compiled code).
//  3. The platform uses 32-bit physical addresses throughout (PA[63:32] = 0).
//
// Protocol
// --------
//  1. Linux launcher builds the table, then writes ready = CFI_TABLE_READY_MAGIC.
//  2. Launcher writes SYNC_TABLE_PUBLISHED → HOST scratch register
//     at CFI_SCRATCH_LAUNCHER_OFF (offset from HOST_REGS_BASE_ADDR).
//  3. Ibex polls that register, reads the table, configures RANGE with VA
//     range, writes SYNC_IBEX_CFI_READY → HOST scratch at CFI_SCRATCH_IBEX_OFF.
//  4. Launcher reads SYNC_IBEX_CFI_READY, releases the monitored process.
//  5. When the process exits the launcher writes SYNC_APP_DONE.
//
// Address note
// ------------
//  CFI_TABLE_PHYS_BASE is placed in the 64 KB window immediately before
//  L2_SHARED_BASE (0xA0010000).  Verify this does not overlap with any
//  other platform allocation (bootrom, LLC tag RAM, etc.) before use.

#ifndef CFI_VA_PA_TABLE_H
#define CFI_VA_PA_TABLE_H

#include <stdint.h>

// ---------------------------------------------------------------------------
// Physical location of the shared table
// ---------------------------------------------------------------------------
// IMPORTANT: the table must reside in the host (CVA6) physical memory so
// that the Linux launcher can map/write it and Ibex can access it as a
// physical address. Do NOT place the table inside the security island L2
// (Ibex-local) memory — CVA6 cannot access that.
//
// Choose a safe location inside the host SPM so the table is reachable
// by both CVA6 and Ibex without using DRAM. Use the uncached SPM window
// to avoid coherent cache issues. The platform maps uncached SPM at
// 0x14000000 (see hardware memory map), so we place the table at
// 0x14000000 by default. Verify this does not overlap any SPM usage.
// ---------------------------------------------------------------------------
#define CFI_TABLE_PHYS_BASE   0x14000000u
#define CFI_TABLE_PHYS_SIZE   0x00001000u  // 4 KB — table fits in one SPM page

// ---------------------------------------------------------------------------
// Magic values
// ---------------------------------------------------------------------------
#define CFI_TABLE_MAGIC        0xCF1AB1E5u
#define CFI_TABLE_READY_MAGIC  0xA1D1E500u  // written last; acts as a store fence

// ---------------------------------------------------------------------------
// Scratch register offsets for the Linux CFI protocol
// (relative to HOST_REGS_BASE_ADDR = 0x03000000)
// Uses scratch 12 (0x30) and scratch 13 (0x34) — distinct from the
// bare-metal snooper_fetch_test which uses scratch 8–11 (0x20–0x2c).
// ---------------------------------------------------------------------------
#define CFI_SCRATCH_LAUNCHER_OFF  0x30u  // CVA6 launcher → Ibex
#define CFI_SCRATCH_IBEX_OFF      0x34u  // Ibex → CVA6 launcher

#define SYNC_TABLE_PUBLISHED   0xCAFE1234u  // launcher: table written and ready
#define SYNC_IBEX_CFI_READY    0x5A1ECAFEu  // ibex: snooper armed, app may start
#define SYNC_APP_DONE          0xDEADC0FFu  // launcher: monitored app has exited

// ---------------------------------------------------------------------------
// Segment descriptor — one physically-contiguous run of virtual pages
// ---------------------------------------------------------------------------
#define CFI_PAGE_SIZE  4096u
#define CFI_MAX_SEGS   32u

// VA fields are split into _h (upper 32 bits) and _l (lower 32 bits) so that
// Ibex (rv32) never needs 64-bit arithmetic.  This mirrors the H/L split
// already used in every snooper ring entry.  For sv39 user-space on this
// platform va_base_h is always 0; the _h fields are stored for correctness
// and future-proofing.
typedef struct {
    uint32_t va_base_l;  // lower 32 bits of page-aligned virtual base address
    uint32_t va_base_h;  // upper 32 bits (0 for all sv39 user-space on this SoC)
    uint32_t pa_base;    // physical base address (PA[63:32] = 0 on this platform)
    uint32_t num_pages;  // number of 4 KB pages in this physically-contiguous run
} cfi_segment_t;         // 16 bytes

// ---------------------------------------------------------------------------
// The table
// Total size: 6*4 + 32*16 + 4 = 540 bytes — fits in one 4 KB page
// ---------------------------------------------------------------------------
typedef struct {
    uint32_t      magic;             // CFI_TABLE_MAGIC
    uint32_t      num_segs;          // valid entries in seg[]
    uint32_t      va_range_start_l;  // lower 32 bits of min VA (inclusive)
    uint32_t      va_range_start_h;  // upper 32 bits of min VA
    uint32_t      va_range_end_l;    // lower 32 bits of max VA (exclusive)
    uint32_t      va_range_end_h;    // upper 32 bits of max VA
    cfi_segment_t seg[CFI_MAX_SEGS];
    uint32_t      ready;             // written last: CFI_TABLE_READY_MAGIC
} cfi_va_pa_table_t;

// ---------------------------------------------------------------------------
// Ibex-side helper: translate VA → PA using the shared table.
// Returns va unchanged if no segment matches (bare-metal / identity fallback).
// ---------------------------------------------------------------------------
// Ibex-side helper: translate a 32-bit VA (lower half of a sv39 address) to PA.
// Matches only when the segment's upper-32-bit half (va_base_h) also matches
// the supplied va_h — avoids false hits if VA space ever exceeds 4 GB.
// Returns va_l unchanged if no segment matches (identity fallback for bare-metal).
#ifndef __linux__
static inline uint32_t cfi_va_to_pa(volatile const cfi_va_pa_table_t *tbl,
                                    uint32_t va_h, uint32_t va_l) {
    uint32_t n = tbl->num_segs;
    for (uint32_t i = 0; i < n; i++) {
        if (tbl->seg[i].va_base_h != va_h)
            continue;
        uint32_t base = tbl->seg[i].va_base_l;
        uint32_t end  = base + tbl->seg[i].num_pages * CFI_PAGE_SIZE;
        if (va_l >= base && va_l < end)
            return tbl->seg[i].pa_base + (va_l - base);
    }
    return va_l;  // identity fallback — correct in bare-metal (VA == PA)
}
#endif  /* !__linux__ */

#endif  /* CFI_VA_PA_TABLE_H */
