/*
 * Copyright (C) 2026 ETH Zurich, University of Bologna and Fondazione Chips-IT
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef SIMPLE_SYSTEM_MAILBOXES_H__
#define SIMPLE_SYSTEM_MAILBOXES_H__

#define ARCHI_SOC_MAILBOXES_ADDR   0x40000000

#ifdef NO_STANDALONE

#define ARCHI_SOC_MAILBOX_OFFSET   0x100

#define ARCHI_MAILBOX_IRQ_SND_STAT_OFFSET  0x0
#define ARCHI_MAILBOX_IRQ_SND_SET_OFFSET   0x4
#define ARCHI_MAILBOX_IRQ_SND_CLR_OFFSET   0x8
#define ARCHI_MAILBOX_IRQ_SND_EN_OFFSET    0xC
#define ARCHI_MAILBOX_IRQ_RCV_STAT_OFFSET  0x40
#define ARCHI_MAILBOX_IRQ_RCV_SET_OFFSET   0x44
#define ARCHI_MAILBOX_IRQ_RCV_CLR_OFFSET   0x48
#define ARCHI_MAILBOX_IRQ_RCV_EN_OFFSET    0x4C
#define ARCHI_MAILBOX_LETTER0_OFFSET       0x80
#define ARCHI_MAILBOX_LETTER1_OFFSET       0x84

#else

#define ARCHI_SOC_MAILBOX_OFFSET           0x0
#define ARCHI_MAILBOXES_REG0_OFFSET        0x08
#define ARCHI_MAILBOXES_REG1_OFFSET        0x10
#define ARCHI_MAILBOXES_REG2_OFFSET        0x14
#define ARCHI_MAILBOXES_REG3_OFFSET        0x18
#define ARCHI_MAILBOXES_REG4_OFFSET        0x1C
#define ARCHI_MAILBOXES_REG5_OFFSET        0x20

#endif

#define MAILBOX_BASE_ADDR   (ARCHI_SOC_MAILBOXES_ADDR + ARCHI_SOC_MAILBOX_OFFSET)

#endif  // SIMPLE_SYSTEM_MAILBOXES_H__
