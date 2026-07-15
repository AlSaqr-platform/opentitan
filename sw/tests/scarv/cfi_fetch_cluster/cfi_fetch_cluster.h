// Copyright 2026 Fondazione Chips-IT.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef CFI_FETCH_CLUSTER_H_
#define CFI_FETCH_CLUSTER_H_

// ---------------------------------------------------------------------------
// Shared control block placed at the very start of L2 SHARED memory.
// Both Ibex (via AXI) and the cluster (via OBI/TCDM crossbar) can access it.
//
// Layout  (5 × 4 bytes = 20 bytes, cache-line-friendly):
//
//   [+0x00]  ibex_ready    – Ibex writes CTRL_IBEX_CHAIN_READY when a new
//                            chain of 3 basic blocks has been fully DMA'd.
//                            Reset to CTRL_IDLE by Ibex before writing.
//   [+0x04]  ibex_chain_id – monotonically incrementing chain counter so the
//                            cluster can detect a fresh job vs stale data.
//   [+0x08]  cluster_done  – cluster writes CTRL_CLUSTER_DONE when it has
//                            finished preprocessing the current chain.
//                            Reset to CTRL_IDLE by the cluster before polling.
//   [+0x0C]  blk_offsets[3] – byte offset of each basic block's first
//                            instruction within the L2 instruction window
//                            (relative to CFI_INSTR_BASE).
//   [+0x18]  blk_sizes[3]  – byte length (multiple of 2; may include C insns)
//                            of each basic block in the chain.
//   [+0x24]  padding        – align to 32 bytes
//
// Ibex fills blk_offsets / blk_sizes before writing ibex_ready.
// The cluster reads them under its own snapshot once ibex_ready is observed.
//
// NOTE: Chains form a sliding window with step 2 over the non-skip entry
//       stream.  Entry indices are 0-based:
//         chain 0 → entries [0, 1, 2]
//         chain 1 → entries [2, 3, 4]   (block 2 shared with chain 0)
//         chain 2 → entries [4, 5, 6]   (block 4 shared with chain 1)
//       Slots rotate: entry e uses slot (e % 3).
//       Ibex publishes a chain when e >= 2 && e % 2 == 0.
// ---------------------------------------------------------------------------

#define CFI_CTRL_BASE       0xA0010000u  // L2_SHARED base — control block here
#define CFI_INSTR_BASE      0xA0010040u  // instruction words start 64 B after ctrl

// Offsets within CFI_CTRL_BASE
#define CFI_CTRL_IBEX_READY_OFF   0x00u
#define CFI_CTRL_CHAIN_ID_OFF     0x04u
#define CFI_CTRL_CLUSTER_DONE_OFF 0x08u
#define CFI_CTRL_BLK0_OFF_OFF     0x0Cu
#define CFI_CTRL_BLK1_OFF_OFF     0x10u
#define CFI_CTRL_BLK2_OFF_OFF     0x14u
#define CFI_CTRL_BLK0_SZ_OFF      0x18u
#define CFI_CTRL_BLK1_SZ_OFF      0x1Cu
#define CFI_CTRL_BLK2_SZ_OFF      0x20u

// Handshake values
#define CTRL_IDLE               0x00000000u
#define CTRL_IBEX_CHAIN_READY   0xCAFE0001u  // Ibex → cluster: new chain ready
#define CTRL_CLUSTER_DONE       0xDEAD0002u  // cluster → Ibex: preprocessing done
#define CTRL_CLUSTER_EXIT       0xDEAD0003u  // cluster → Ibex: no more jobs, bye

// Mailbox "SND" doorbell sent by cluster → Ibex when all chains processed.
// The SND side fires the interrupt already wired to Ibex's PLIC (line 160).
// Ibex can choose to poll LETTER0 or handle the interrupt; we poll for simplicity.
#define CFI_MBOX_DONE_VALUE     0x0u         // LETTER0 = 0 → success

// ---------------------------------------------------------------------------
// Instruction window geometry.
// Ibex accumulates DMA'd words into a sliding window inside L2 shared memory
// starting at CFI_INSTR_BASE.  The window is divided into CHAIN_SLOTS slots;
// each slot holds up to CFI_INSTR_SLOT_BYTES bytes.
//
// With chain_stride = 2 snooper entries per basic block position we take
// entries at positions 0, 2, 4 to form a chain of 3 blocks.
// ---------------------------------------------------------------------------
#define CFI_CHAIN_SLOTS         3u
#define CFI_INSTR_SLOT_BYTES    4096u  // 4 KB per basic block slot — ample margin
#define CFI_INSTR_WINDOW_BYTES  (CFI_CHAIN_SLOTS * CFI_INSTR_SLOT_BYTES)

#endif  // CFI_FETCH_CLUSTER_H_
