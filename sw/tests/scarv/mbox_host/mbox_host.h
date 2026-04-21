// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef MBOX_HOST_H_
#define MBOX_HOST_H_

// Base address of the mailbox peripheral on this platform
#define MBOX_BASE_ADDR  0x40000000
// Each mailbox instance occupies 0x100 bytes
#define MBOX_STRIDE     0x100
// PLIC IRQ ID for the incoming mailbox interrupt (mbox 1)
#define MBOX_IRQ_ID     159

#endif  // MBOX_HOST_H_
