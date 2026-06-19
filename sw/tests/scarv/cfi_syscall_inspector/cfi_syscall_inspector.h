// Copyright 2026 Fondazione Chips-IT.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef CFI_SYSCALL_INSPECTOR_H_
#define CFI_SYSCALL_INSPECTOR_H_

#include <stdint.h>

// Snooper entry as captured in the inspection window.
typedef struct {
    uint32_t pc_src_l;
    uint32_t pc_src_h;
    uint32_t pc_dst_l;
    uint32_t pc_dst_h;
    uint32_t ctr_type;
} snooper_entry_t;

// Inspection window populated on each syscall notification.
// Declared extern so the PMCA-side consumer can reference them
// once the shared-memory interface is wired up.
#ifndef CFI_WINDOW_SIZE
#define CFI_WINDOW_SIZE 16u
#endif

extern snooper_entry_t cfi_window[CFI_WINDOW_SIZE];
extern uint32_t        cfi_window_count;

#endif  // CFI_SYSCALL_INSPECTOR_H_
