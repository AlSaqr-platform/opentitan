// Copyright 2026 Fondazione Chips-IT.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// cfi_syscall_proto.h — per-syscall CFI inspection protocol
//
// Shared by cfi_syscall_monitor.c (CVA6/Linux) and
// cfi_syscall_inspector.c (Ibex).
//
// Communication channels
// ----------------------
//  CVA6 → Ibex  : mailbox 1 letter0 + INT_SND doorbell  (triggers PLIC IRQ 159)
//  Ibex → CVA6  : Cheshire scratch register 14 (offset 0x38 from 0x03000000)
//
// Lifecycle
// ---------
//  1. Initial VA→PA table handshake uses scratch 12/13 (CFI_SCRATCH_LAUNCHER_OFF /
//     CFI_SCRATCH_IBEX_OFF from cfi_va_pa_table.h) — unchanged.
//  2. After SYNC_IBEX_CFI_READY, per-syscall inspection uses this protocol.
//  3. On each sensitive syscall:
//       CVA6: scratch14 ← CFI_RESULT_BUSY
//       CVA6: mbox1.letter0 ← CFI_MSG_SYSCALL | syscall_nr
//       CVA6: mbox1.INT_SND_EN ← 1 ; mbox1.INT_SND_SET ← 1
//       Ibex: IRQ fires → inspect last CFI_WINDOW_SIZE ring entries
//       Ibex: scratch14 ← CFI_RESULT_PASS or CFI_RESULT_VIOLATION
//       CVA6: polls scratch14 until != CFI_RESULT_BUSY
//  4. On monitored app exit:
//       CVA6: mbox1.letter0 ← CFI_MSG_APP_DONE  + doorbell
//       Ibex: disarms snooper

#ifndef CFI_SYSCALL_PROTO_H
#define CFI_SYSCALL_PROTO_H

#include <stdint.h>

// ---------------------------------------------------------------------------
// Scratch register 14  (Ibex → CVA6 result channel)
// offset relative to HOST_REGS_BASE_ADDR = 0x03000000
// ---------------------------------------------------------------------------
#define CFI_SCRATCH_RESULT_OFF   0x38u   // scratch 14

#define CFI_RESULT_BUSY          0xFFFFFFFFu  // Ibex still processing
#define CFI_RESULT_PASS          0x00000000u  // chain looks legitimate
#define CFI_RESULT_VIOLATION     0x00000001u  // CFI anomaly detected

// ---------------------------------------------------------------------------
// Mailbox 1 letter0 message encoding  (CVA6 → Ibex)
//   [31:24] message type
//   [23:0]  syscall number (from a7/x17), valid only for CFI_MSG_SYSCALL
// ---------------------------------------------------------------------------
#define CFI_MSG_SYSCALL          0x01000000u
#define CFI_MSG_APP_DONE         0x02000000u
#define CFI_MSG_TYPE_MASK        0xFF000000u
#define CFI_MSG_SYSCALL_NR_MASK  0x00FFFFFFu

// ---------------------------------------------------------------------------
// Snooper ring inspection window
// ---------------------------------------------------------------------------
#ifndef CFI_WINDOW_SIZE
#define CFI_WINDOW_SIZE   3u
#endif

#endif /* CFI_SYSCALL_PROTO_H */
