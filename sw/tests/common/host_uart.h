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

#include <stdint.h>

#define HOST_UART_BASE_ADDR 0x03002000
#define HOST_REGS_BASE_ADDR 0x03000000

#define HOST_RTC_FREQ_REG_OFFSET 0x44

#define BAUDRATE 115200


// Register offsets
#define UART_RBR_REG_OFFSET 0
#define UART_THR_REG_OFFSET 0
#define UART_INTR_ENABLE_REG_OFFSET 4
#define UART_INTR_IDENT_REG_OFFSET 8
#define UART_FIFO_CONTROL_REG_OFFSET 8
#define UART_LINE_CONTROL_REG_OFFSET 12
#define UART_MODEM_CONTROL_REG_OFFSET 16
#define UART_LINE_STATUS_REG_OFFSET 20
#define UART_MODEM_STATUS_REG_OFFSET 24
#define UART_DLAB_LSB_REG_OFFSET 0
#define UART_DLAB_MSB_REG_OFFSET 4

// Register fields
#define UART_LINE_STATUS_DATA_READY_BIT 0
#define UART_LINE_STATUS_THR_EMPTY_BIT 5
#define UART_LINE_STATUS_TMIT_EMPTY_BIT 6

void host_uart_init(void *uart_base, uint32_t freq, uint32_t baud);

int host_uart_read_ready(void *uart_base);

void host_uart_write(void *uart_base, uint8_t byte);

void host_uart_write_str(void *uart_base, void *src, uint32_t len);

void host_uart_write_flush(void *uart_base);

uint8_t host_uart_read(void *uart_base);
