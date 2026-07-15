// Copyright 2026 Fondazione Chips-IT.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef SNOOPER_FETCH_CLUSTER_H_
#define SNOOPER_FETCH_CLUSTER_H_

// ---------------------------------------------------------------------------
// Shared control block in L2 SHARED memory.
// Both Ibex (via AXI) and cluster core 0 (via cluster interconnect) access it.
//
// Layout (4 × 4 bytes = 16 bytes):
//   [+0x00] ibex_state    – Ibex writes state transitions to the cluster
//   [+0x04] dummy_start   – CVA6 dummy code region start (physical address)
//   [+0x08] dummy_end     – CVA6 dummy code region end   (physical address)
//   [+0x0C] cluster_state – cluster writes state transitions back to Ibex
//
// Ibex populates dummy_start/dummy_end before writing ibex_state so the
// cluster sees a consistent snapshot when it reads the control block.
// ---------------------------------------------------------------------------
#define SFC_CTRL_BASE         0xA0010000u

#define SFC_IBEX_STATE_OFF    0x00u
#define SFC_DUMMY_START_OFF   0x04u
#define SFC_DUMMY_END_OFF     0x08u
#define SFC_CLUSTER_STATE_OFF 0x0Cu

// Ibex → cluster state values
#define SFC_IDLE              0x00000000u
#define SFC_IBEX_RUN1_READY   0xCAFE0001u  // snooper configured, start run-1
#define SFC_IBEX_RUN2_READY   0xCAFE0002u  // snooper reconfigured (halt off), start run-2

// cluster → Ibex state values
#define SFC_CLUSTER_RUN1_DONE 0xDEAD0001u  // cluster finished run-1 drain + fetch
#define SFC_CLUSTER_RUN2_DONE 0xDEAD0002u  // cluster finished run-2 drain

// ---------------------------------------------------------------------------
// Instruction staging area in L2 shared (follows the control block).
// Cluster DMAs fetched instruction bytes here during run-1.
// ---------------------------------------------------------------------------
#define SFC_INSTR_BASE        0xA0010040u   // 64 B after ctrl block
#define SFC_INSTR_AREA_BYTES  0x10000u      // 64 KB staging window

// ---------------------------------------------------------------------------
// Cluster boot parameters
// ---------------------------------------------------------------------------
#define SFC_CLUSTER_ENTRY_ADDR  0xA0008080u
#define SFC_CLUSTER_NUM_CORES   8u
#define SFC_CLUSTER_BOOT_REG    0xB0200040u  // per-core boot address registers
#define SFC_CLUSTER_FETCH_EN    0xBF000000u
#define SFC_CLUSTER_CLK_EN      0xBF000008u
#define SFC_EDN_EN_ADDR         0xC1170014u

// ---------------------------------------------------------------------------
// Scratch register protocol (must match CVA6 hostd/snooper_fetch_test.c)
//   scratch  8  CVA6 → ibex: dummy_code_start
//   scratch  9  CVA6 → ibex: dummy_code_end
//   scratch 10  CVA6 → ibex: sync state
//   scratch 11  ibex → CVA6: sync state
// ---------------------------------------------------------------------------
#define HOST_SCRATCH_8_REG_OFFSET   0x20u
#define HOST_SCRATCH_9_REG_OFFSET   0x24u
#define HOST_SCRATCH_10_REG_OFFSET  0x28u
#define HOST_SCRATCH_11_REG_OFFSET  0x2cu

#define SYNC_ADDR_VALID_FETCH  0xdeadc0deu
#define SYNC_FETCH_DONE        0xcafe00feu
#define SYNC_IBEX_FETCH_READY  0x5a1e00feu
#define SYNC_IBEX_READY_RUN2   0x5a1e01feu
#define SYNC_FETCH_DONE_RUN2   0xcafe01feu

#endif  // SNOOPER_FETCH_CLUSTER_H_
