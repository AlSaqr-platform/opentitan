// Copyright 2023 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Nicole Narr <narrn@student.ethz.ch>
// Christopher Reinwardt <creinwar@student.ethz.ch>
// Paul Scheffler <paulsc@iis.ee.ethz.ch>

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <time.h>
#include "utils.h"
#include "regs/snooper_regs.h"
#define OT_PLATFORM_RV32

// OpenTitan Library Includes
#include "sw/device/lib/dif/dif_rv_plic.h" 
#include "sw/device/lib/base/mmio.h"       
#include "sw/device/lib/runtime/irq.h"
volatile uint32_t irq_handled = 0;
// Global PLIC Handle
dif_rv_plic_t plic;

// Define the absolute hardware addresses for the Snooper
#define BASE_SNPRCFG ((void *)0x15000000)
#define BASE_SNPR    ((void *)0x16000000)

// Define the absolute hardware addresses for the PLIC (Target 0, IRQ 158)
#define PlicPrioAddrReg  0xC8000278  // Priority reg for IRQ 158
#define PlicEnAddrReg    0xC8002010  // Enable reg for IRQs 128-159
#define PlicCheckAddrReg 0xC8200004  // Claim/Complete reg for Target 0

void set_register_bit(void *base_addr, uint32_t reg_offset, uint32_t bit_position) {
    uint32_t reg_value = *reg32(base_addr, reg_offset);
    reg_value |= (1 << bit_position);
    *reg32(base_addr, reg_offset) = reg_value;
}

void clear_register_bit(void *base_addr, uint32_t reg_offset, uint32_t bit_position) {
    uint32_t reg_value = *reg32(base_addr, reg_offset);
    reg_value &= ~(1U << bit_position);
    *reg32(base_addr, reg_offset) = reg_value;
}

// Bare-metal Interrupt Service Routine
void external_irq_handler(void){
    int irq_id = 158;
    int volatile * plic_check;
    

    // Start of Interrupt Service Routine: Claim the interrupt
    plic_check = (int *) PlicCheckAddrReg;
    printf("Interrupt received, claiming IRQ...\n\r");
    //print the plic pending register for debugging
    uint32_t pending = *(volatile uint32_t *)0xC8001010;
    printf("PLIC Pending Register: 0x%08x\n\r", pending);
    
    // Wait and verify it's the correct IRQ (158)
    if(*plic_check == irq_id){
    printf("IRQ %d claimed, handling interrupt...\n\r", irq_id);
    clear_register_bit(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_TRIG_PC_0_BIT);
    irq_handled = 1;
    // clear_register_bit(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET, CFG_REGS_CTRL_WATERMARK_EN_BIT);


    // Complete the interrupt by writing the IRQ ID back to the claim/complete register
    *plic_check = irq_id;    }      

    return;
}

int main(void) {

    extern char dummy1_code_start, dummy1_code_end, dummy2_code_start, dummy2_code_end;
    // volatile uint64_t counter = 0;
    // while(1){
    //     counter++;
    // }

    static const uint32_t instructions[] = {
        0xf3000017, 0xf3000017, 
        0x00100013, 0xda678013,
        0xf3000017, 0x00200013, 
        0xd9a78013, 0xf3000017, 
        0x00300013, 0xd8e78013,
        0xf3000017, 0xf3000017, 
        0xd8270013, 0xf3000017,  
        0xd7278013, 0xf3000017, 
        0xd6678013
    };
    printf("hello ibex\n\r");

    //---------------------------------------------------------------------------------------------//
    //--------------------------------------INSTR MODE TEST----------------------------------------//
    //---------------------------------------------------------------------------------------------//

    printf("%x\n\r", (unsigned int)*reg32(BASE_SNPR, 0));
    printf("%x\n\r", (unsigned int)*reg32(BASE_SNPRCFG, CFG_REGS_BASE_REG_OFFSET));

    // Configure LSBs and MSBs of START_ADDRESS for RANGE_0
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_0_BASE_H_REG_OFFSET) = 0x00000000;
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_0_BASE_L_REG_OFFSET) = (uintptr_t)0x100014ca;

    // Configure LSBs and MSBs of END_ADDRESS for RANGE_0
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_0_LAST_H_REG_OFFSET) = 0x00000000;
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_0_LAST_L_REG_OFFSET) = (uintptr_t)0x1000150a;

    // Configure Snooper to log only instructions executed in M mode
    set_register_bit(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET,CFG_REGS_CTRL_M_MODE_BIT);

    // Configure Snooper Logging mode: Instr
    set_register_bit(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET,CFG_REGS_CTRL_TRACE_MODE_OFFSET);

    // Enable RANGE_0 from CTRL register
    set_register_bit(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET,CFG_REGS_CTRL_PC_RANGE_0_BIT);

    fence();
    
    for (int i = 0; i < 0x2c; i+=4) {
        printf("Offset 0x%x: %x\n\r", i, (unsigned int)*reg32(BASE_SNPRCFG, i));
    }

    uint32_t last_address = 0;
    const uint32_t target_size = 16 * 4; // 64 bytes

    while (1) {
        // Perform a volatile read to force a hardware bus transaction
        last_address = *reg32(BASE_SNPRCFG, CFG_REGS_LAST_REG_OFFSET);
        if (last_address >= target_size) {
            break; 
        }
    }

    // Stop snooper logging
    clear_register_bit(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET,CFG_REGS_CTRL_PC_RANGE_0_BIT);

    int base, last, new_base, new_last;

    base = *reg32(BASE_SNPRCFG, CFG_REGS_BASE_REG_OFFSET);
    last = *reg32(BASE_SNPRCFG, CFG_REGS_LAST_REG_OFFSET);

    for(int i=base;i<=last;i=i+4) { 
        printf("%x\n\r", (unsigned int)*reg32(BASE_SNPR, i));
        if (*reg32(BASE_SNPR, i) != instructions[i/4])
            return 1; 
    }

    //--------------------------------------------------------------------------------------------//
    //--------------------------------------ADDR MODE TEST----------------------------------------//
    //--------------------------------------------------------------------------------------------//

    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_0_BASE_H_REG_OFFSET) = 0x00000000;
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_0_BASE_L_REG_OFFSET) = (uintptr_t)0x1000150e;

    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_0_LAST_H_REG_OFFSET) = 0x00000000;
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_0_LAST_L_REG_OFFSET) = (uintptr_t)0x10001560;
    
    // // Configure Snooper Logging mode: Addr
    // // Addr mode to log PC src, PC dst and ctr_type of branches and jumps
    clear_register_bit(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET,CFG_REGS_CTRL_TRACE_MODE_OFFSET);

    // 1. CPU interrupt configuration using helper routines
    irq_set_vector_offset(0xe0000001); // Sets mtvec (Base address 0xe0000000 + Vectored mode 1)
    irq_global_ctrl(true);             // Sets mstatus MIE bit (Global interrupt enable)
    irq_external_ctrl(true);           // Sets mie MEIE bit (External interrupt enable)
    // 1. Set the base address
    plic.base_addr = mmio_region_from_addr(0xC8000000);

    // // 2. PLIC peripheral configuration
    dif_rv_plic_reset(&plic);
    
    dif_rv_plic_target_set_threshold(&plic, 0, 0);                 // Unmask interrupts above priority 0
    printf("Configuring PLIC for IRQ 158...\n\r");
    dif_rv_plic_irq_set_priority(&plic, 158, 1);                   // Set IRQ 158 to priority 1
    dif_rv_plic_irq_set_enabled(&plic, 158, 0, kDifToggleEnabled); // Enable IRQ 158 for target 0
    printf("PLIC configured. Waiting for interrupt...\n\r");


    // //---------------------------------------------------------------------------------------------//

    //-------------------------------------TRIGGER INTERRUPT---------------------------------------//
    *reg32(BASE_SNPRCFG, CFG_REGS_TRIG_PC0_H_REG_OFFSET) = 0x00000000;
    *reg32(BASE_SNPRCFG, CFG_REGS_TRIG_PC0_L_REG_OFFSET) = (uintptr_t)0x10001560;
    set_register_bit(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET,CFG_REGS_CTRL_TRIG_PC_0_BIT);


    //------------------------------------WATERMARK INTERRUPT--------------------------------------//
    // *reg32(BASE_SNPRCFG, CFG_REGS_WATERMARK_LEVEL_REG_OFFSET) = 0x0000000a; 
    // set_register_bit(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET,CFG_REGS_CTRL_WATERMARK_EN_BIT);

    set_register_bit(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET,CFG_REGS_CTRL_PC_RANGE_0_BIT);

    fence();

    // // Wait for the ISR to set the flag
    uint32_t pending = *(volatile uint32_t *)0xC8001010;
    while (!irq_handled) {
        asm volatile("wfi"); 
    }
    printf("Interrupt successfully caught!\n");
    
    new_base = last + 4;
    new_last = *reg32(BASE_SNPRCFG, CFG_REGS_LAST_REG_OFFSET);
    printf("printing logged PCs in the buffer:\n\r");
    printf("New Base: 0x%x, New Last: 0x%x\n\r", (unsigned int)new_base, (unsigned int)new_last);

    for(int i = new_base; i < new_last; i = i + 20) { 
        uint32_t pc_src_low  = *reg32(BASE_SNPR, i + 0x00);
        uint32_t pc_dst_low  = *reg32(BASE_SNPR, i + 0x08);
        uint32_t metadata = *reg32(BASE_SNPR, i + 0x10);

        printf("Src: %x  -->  Dst: %x  |  Meta: %x\n\r", (unsigned int)pc_src_low, (unsigned int)pc_dst_low, (unsigned int)metadata);

        if ((pc_src_low <= (uintptr_t)0x1000150e) || (pc_src_low >= (uintptr_t)0x10001560)){
            printf("test failed! PC outside of logging region: %x\n\r", (unsigned int)pc_src_low);
            return 1; 
        }
    }
    printf("Test passed!\n\r");

    return 0;
}