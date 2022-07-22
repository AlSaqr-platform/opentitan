// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef SIMPLE_SYSTEM_COMMON_H__

#include <stdint.h>
#include <stdbool.h>
#include <stdarg.h>
#include <stddef.h>


#include "simple_system_regs.h"

#define DEV_WRITE(addr, val) (*((volatile uint32_t *)(addr)) = val)
#define DEV_READ(addr, val) (*((volatile uint32_t *)(addr)))
#define PCOUNT_READ(name, dst) asm volatile("csrr %0, " #name ";" : "=r"(dst))

/**
 * Writes character to simulator out log. Signature matches c stdlib function
 * of the same name.
 *
 * @param c Character to output
 * @returns Character output (never fails so no EOF ever returned)
 */

void external_irq_handler(void) __attribute__((interrupt));

int putchar(int c);

bool putbool(bool c);

int putint(int c);

int putrom(int c);

/**
 * Writes string to simulator out log.  Signature matches c stdlib function of
 * the same name.
 *
 * @param str String to output
 * @returns 0 always (never fails so no error)
 */
//int puts(char *str);

/**
 * Writes ASCII hex representation of number to simulator out log.
 *
 * @param h Number to output in hex
 */
void puthex(uint32_t h);

/**
 * Immediately halts the simulation
 */
void sim_halt();

/**
 * Enables/disables performance counters.  This effects mcycle and minstret as
 * well as the mhpmcounterN counters.
 *
 * @param enable if non-zero enables, otherwise disables
 */
void pcount_enable(int enable);

/**
 * Resets all performance counters.  This effects mcycle and minstret as well
 * as the mhpmcounterN counters.
 */
void pcount_reset();

/**
 * Enables timer interrupt
 *
 * @param time_base Number of time ticks to count before interrupt
 */
void timer_enable(uint64_t time_base);

/**
 * Returns current mtime value
 */
uint64_t timer_read(void);

/**
 * Set a new timer value
 *
 * @param new_time New value for time
 */
void timecmp_update(uint64_t new_time);

/**
 * Disables timer interrupt
 */
void timer_disable(void);

/**
 * Returns current global time value
 */
uint64_t get_elapsed_time(void);

#endif

// Copyright 2017 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the ?License?); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an ?AS IS? BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

/**
 * @file
 * @brief 16750 UART library.
 *
 * Provides UART helper function like setting
 * control registers and reading/writing over
 * the serial interface.
 *
 */
#ifndef _UART_H
#define _UART_H

#include <stdint.h>
#ifdef CLUSTER_UART
  #define UART_BASE_ADDR 0x1A222000
#else
  #define UART_BASE_ADDR 0x40000000
#endif

#define UART_REG_RBR ( UART_BASE_ADDR + 0x00) // Receiver Buffer Register (Read Only)
#define UART_REG_DLL ( UART_BASE_ADDR + 0x00) // Divisor Latch (LS)
#define UART_REG_THR ( UART_BASE_ADDR + 0x00) // Transmitter Holding Register (Write Only)
#define UART_REG_DLM ( UART_BASE_ADDR + 0x04) // Divisor Latch (MS)
#define UART_REG_IER ( UART_BASE_ADDR + 0x04) // Interrupt Enable Register
#define UART_REG_IIR ( UART_BASE_ADDR + 0x08) // Interrupt Identity Register (Read Only)
#define UART_REG_FCR ( UART_BASE_ADDR + 0x08) // FIFO Control Register (Write Only)
#define UART_REG_LCR ( UART_BASE_ADDR + 0x0C) // Line Control Register
#define UART_REG_MCR ( UART_BASE_ADDR + 0x10) // MODEM Control Register
#define UART_REG_LSR ( UART_BASE_ADDR + 0x14) // Line Status Register
#define UART_REG_MSR ( UART_BASE_ADDR + 0x18) // MODEM Status Register
#define UART_REG_SCR ( UART_BASE_ADDR + 0x1C) // Scratch Register

#define RBR_UART REGP_8(UART_REG_RBR)
#define DLL_UART REGP_8(UART_REG_DLL)
#define THR_UART REGP_8(UART_REG_THR)
#define DLM_UART REGP_8(UART_REG_DLM)
#define IER_UART REGP_8(UART_REG_IER)
#define IIR_UART REGP_8(UART_REG_IIR)
#define FCR_UART REGP_8(UART_REG_FCR)
#define LCR_UART REGP_8(UART_REG_LCR)
#define MCR_UART REGP_8(UART_REG_MCR)
#define LSR_UART REGP_8(UART_REG_LSR)
#define MSR_UART REGP_8(UART_REG_MSR)
#define SCR_UART REGP_8(UART_REG_SCR)

#define DLAB 1<<7 	//DLAB bit in LCR reg
#define ERBFI 1 	//ERBFI bit in IER reg
#define ETBEI 1<<1 	//ETBEI bit in IER reg
#define PE 1<<2 	//PE bit in LSR reg
#define THRE 1<<5 	//THRE bit in LSR reg
#define DR 1	 	//DR bit in LSR reg


#define UART_FIFO_DEPTH 64

//UART_FIFO_DEPTH but to be compatible with Arduino_libs and also if in future designs it differed
#define SERIAL_RX_BUFFER_SIZE UART_FIFO_DEPTH
#define SERIAL_TX_BUFFER_SIZE UART_FIFO_DEPTH

void uart_set_cfg(int parity, uint16_t clk_counter);

void uart_send(const char* str, unsigned int len);
void uart_sendchar(const char c);

char uart_getchar();

void uart_wait_tx_done(void);

#endif


#ifndef STRING_LIB_H
#define STRING_LIB_H

#include <stddef.h>

// putchar is defined as a macro which gets in the way of our prototype below
#ifdef putchar
#undef putchar
#endif

size_t strlen (const char *str);
int  strcmp (const char *s1, const char *s2);
char* strcpy (char *s1, const char *s2);
int puts(const char *s);
int printf(const char *format, ...);
void * memset (void *dest, int val, size_t len);
int putchar(int s);

#endif
