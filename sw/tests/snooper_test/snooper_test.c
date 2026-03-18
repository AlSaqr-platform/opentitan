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
// Define the absolute hardware addresses
#define BASE_SNPRCFG ((void *)0x15000000)
#define BASE_SNPR    ((void *)0x16000000)
enum car_irq_router_target {
    IRQ_ROUTER_TARGET_NONE            = 0,
    IRQ_ROUTER_TARGET_PLIC            = 1,
    IRQ_ROUTER_TARGET_CVA6_CLIC       = 1 << 1,
    IRQ_ROUTER_TARGET_SECURITY_ISLAND = 1 << 2,
};


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


int main(void) {


    extern char dummy1_code_start, dummy1_code_end, dummy2_code_start, dummy2_code_end;

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

    // // Configure LSBs and MSBs of START_ADDRESS for RANGE_0, first and only logging region
    // *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_0_BASE_H_REG_OFFSET) = 0x00000000;
    // *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_0_BASE_L_REG_OFFSET) = (uintptr_t)0x1000155c;

    // // Configure LSBs and MSBs of END_ADDRESS for RANGE_0, first and only logging region
    // *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_0_LAST_H_REG_OFFSET) = 0x00000000;
    // *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_0_LAST_L_REG_OFFSET) = (uintptr_t)0x1000159c;
    // START_ADDRESS (Base: 0x15000000)
    printf("%x\n\r", *reg32(BASE_SNPR, 0));
    printf("%x\n\r", *reg32(BASE_SNPRCFG, CFG_REGS_BASE_REG_OFFSET));
    //prrint all the registers starting from BASE_SNPRCFG to BASE_SNPRCFG + 0x29

 // Configure LSBs and MSBs of START_ADDRESS for RANGE_0, first and only logging region
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_0_BASE_H_REG_OFFSET) = 0x00000000;
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_0_BASE_L_REG_OFFSET) = (uintptr_t)0x1000149e;

    // Configure LSBs and MSBs of END_ADDRESS for RANGE_0, first and only logging region
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_0_LAST_H_REG_OFFSET) = 0x00000000;
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_0_LAST_L_REG_OFFSET) = (uintptr_t)0x100014de;

    // Configure Snooper to log only instructions executed in M mode
    set_register_bit(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET,CFG_REGS_CTRL_M_MODE_BIT);

    // Set this bit to snoop from core 1 instead of core 0
    // set_register_bit(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET,CFG_REGS_CTRL_CORE_SELECT_BIT);

    // Configure Snooper Logging mode: Instr
    // Instr mode to log the opcode of every instruction
    set_register_bit(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET,CFG_REGS_CTRL_TRACE_MODE_OFFSET);

    // Enable RANGE_0 from CTRL register, this will enable the snooper to log the RANGE_0
    set_register_bit(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET,CFG_REGS_CTRL_PC_RANGE_0_BIT);

    fence();
    
    for (int i = 0; i < 0x2c; i+=4) {
        printf("Offset 0x%x: %x\n\r", i, *reg32(BASE_SNPRCFG, i));
    }

    // 2. Poll the register
    uint32_t last_address = 0;
    const uint32_t target_size = 16 * 4; // 64 bytes

    while (1) {
        // Perform a volatile read to force a hardware bus transaction
        last_address = *(volatile uint32_t *)0x15000008;
        
        if (last_address >= target_size) {
            break; 
        }
        
        // Optional: add a small barrier to prevent the CPU from 
        // flooding the bus too aggressively
        // asm volatile("nop");
    }

    // asm volatile (
    //     "dummy1_code_start: \n\r"
    //     "auipc	zero,0xf3000 \n\r"
    //     "auipc	zero,0xf3000 \n\r"
    //     "li	zero,1 \n\r"
    //     "addi	zero,a5,-602 \n\r"
    //     "auipc	zero,0xf3000 \n\r"
    //     "li	zero,2 \n\r"
    //     "addi	zero,a5,-614 \n\r"
    //     "auipc	zero,0xf3000 \n\r"
    //     "li	zero,3 \n\r"
    //     "addi	zero,a5,-626 \n\r"
    //     "auipc	zero,0xf3000 \n\r"
    //     "auipc	zero,0xf3000 \n\r"
    //     "addi	zero,a4,-638 \n\r"
    //     "auipc	zero,0xf3000 \n\r"
    //     "addi	zero,a5,-654 \n\r"
    //     "auipc	zero,0xf3000 \n\r"
    //     "dummy1_code_end: \n\r"
    //     "addi	zero,a5,-666 \n\r"
    // );

    // Stop snooper logging
    clear_register_bit(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET,CFG_REGS_CTRL_PC_RANGE_0_BIT);

    int base, last, new_base, new_last;

    base = *reg32(BASE_SNPRCFG, CFG_REGS_BASE_REG_OFFSET);
    last = *reg32(BASE_SNPRCFG, CFG_REGS_LAST_REG_OFFSET);

    for(int i=base;i<=last;i=i+4) { // Instruction mode
        printf("%x\n\r", *reg32(BASE_SNPR, i));
        if (*reg32(BASE_SNPR, i) != instructions[i/4])
            return 1; // return error in case the logged instruction is different from the expected instruction
    }

    //--------------------------------------------------------------------------------------------//
    //--------------------------------------ADDR MODE TEST----------------------------------------//
    //--------------------------------------------------------------------------------------------//

    // Configure LSBs and MSBs of START_ADDRESS for RANGE_0, first and only logging region
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_0_BASE_H_REG_OFFSET) = 0x00000000;
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_0_BASE_L_REG_OFFSET) = (uintptr_t)0x100014e2;

    // Configure LSBs and MSBs of END_ADDRESS for RANGE_0, first and only logging region
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_0_LAST_H_REG_OFFSET) = 0x00000000;
    *reg32(BASE_SNPRCFG, CFG_REGS_RANGE_0_LAST_L_REG_OFFSET) = (uintptr_t)0x10001534;

    // Configure Snooper Logging mode: Addr
    // Addr mode to log PC src, PC dst and ctr_type of branches and jumps
    clear_register_bit(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET,CFG_REGS_CTRL_TRACE_MODE_OFFSET);

    // enable watermark interrupt for security island
    //car_irq_router_enable(58, IRQ_ROUTER_TARGET_SECURITY_ISLAND);
    // enable trigger interrupt for security island
    //car_irq_router_enable(59, IRQ_ROUTER_TARGET_SECURITY_ISLAND);


    //-------------------------------------TRIGGER INTERRUPT---------------------------------------//
    // This interrupt triggers when the snooper reads a committing instruction with PC=TRIGGER_PC0
    // The trigger interrupt resets the snooper ctrl register, this stops the snooper operation
    // allowing to read the execution trace without the risk of new instructions 
    // overwriting the instructions already stored in the buffer

    // Configure LSBs and MSBs of TRIGGER_PC0
    *reg32(BASE_SNPRCFG, CFG_REGS_TRIG_PC0_H_REG_OFFSET) = 0x00000000;
    *reg32(BASE_SNPRCFG, CFG_REGS_TRIG_PC0_L_REG_OFFSET) = (uintptr_t)0x10001534;
    // Enable trigger interrupt for PC0
    set_register_bit(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET,CFG_REGS_CTRL_TRIG_PC_0_BIT);


    //------------------------------------WATERMARK INTERRUPT--------------------------------------//
    // Watermark interrupt can only be used in instruction mode
    // This interrupt triggers when the numbers of instructions stored in the buffer minus
    // the number of instructions previously read through AXI is higher than the watermark lvl
    // The interrupt is high as long as this condition is met and does not stop the snooper operation

    // Set watermark level to 10 instructions
    *reg32(BASE_SNPRCFG, CFG_REGS_WATERMARK_LEVEL_REG_OFFSET) = 0x0000000a; 
    // Enable watermark interrupt
    set_register_bit(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET,CFG_REGS_CTRL_WATERMARK_EN_BIT);


    // Enable RANGE_0 from CTRL register, this will enable the snooper to log the RANGE_0
    set_register_bit(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET,CFG_REGS_CTRL_PC_RANGE_0_BIT);

    fence();
    uint32_t ctrl_status;
    do {
        // Read the CTRL register using your macro
        ctrl_status = *reg32(BASE_SNPRCFG, CFG_REGS_CTRL_REG_OFFSET); 
        
        // Optional: slight delay
        asm volatile("nop");
        
    // Keep looping while the RANGE_0 bit is still a '1'
    } while (ctrl_status & (1 << CFG_REGS_CTRL_PC_RANGE_0_BIT));
    

    // asm volatile ("dummy2_code_start:");

    // *reg32(&__base_regs, CHESHIRE_SCRATCH_0_REG_OFFSET) = 0;
    // *reg32(&__base_regs, CHESHIRE_SCRATCH_1_REG_OFFSET) = 1;
    // *reg32(&__base_regs, CHESHIRE_SCRATCH_2_REG_OFFSET) = 2;
    // *reg32(&__base_regs, CHESHIRE_SCRATCH_3_REG_OFFSET) = 3;
    // for (int i=0; i<(int) *reg32(&__base_regs, CHESHIRE_SCRATCH_3_REG_OFFSET); i++) {
    //     *reg32(&__base_regs, CHESHIRE_SCRATCH_0_REG_OFFSET) = 0;  
    // }

    // asm volatile ("dummy2_code_end:");

    new_base = last + 4;
    new_last = *reg32(BASE_SNPRCFG, CFG_REGS_LAST_REG_OFFSET);
    printf("printing logged PCs in the buffer:\n\r");

    for(int i = new_base; i < new_last; i = i + 20) { 
        // 1. Read 64-bit Source PC (Lower word at 0x00)
        uint32_t pc_src_low  = *reg32(BASE_SNPR, i + 0x00);
        uint32_t pc_src_high = *reg32(BASE_SNPR, i + 0x04);

        // 2. Read 64-bit Destination PC (Lower word at 0x08)
        uint32_t pc_dst_low  = *reg32(BASE_SNPR, i + 0x08);
        uint32_t pc_dst_high = *reg32(BASE_SNPR, i + 0x0C);

        // 3. Read 32-bit Metadata (Offset 0x10)
        uint32_t metadata = *reg32(BASE_SNPR, i + 0x10);

        printf("Src: %x  -->  Dst: %x  |  Meta: %x\n\r", pc_src_low, pc_dst_low, metadata);

        // 4. Hardcoded Safety Check
        if ((pc_src_low <= (uintptr_t)0x100014e2) || (pc_src_low >= (uintptr_t)0x10001534)){
            printf("test failed! PC outside of logging region: %x\n\r", pc_src_low);
            return 1; 
        }
    }
    printf("Test passed!\n\r");

    return 0;
}
