#include <stdbool.h>

#include "simple_system_common.h"


#define TARGET_SYNTHESIS

#define COMMIT_LOG_PHMON

#ifndef COMMIT_LOG_PHMON
#ifndef COMMIT_LOG_CVA6
	#error "Define `COMMIT_LOG_PHMON` or `COMMIT_LOG_CVA6`"
#endif
#endif

typedef uint64_t ssptr_t;

/* =============================================================================
 * System-on-Chip Memory Map
 * ===========================================================================*/

#define MAILBOX_BASE           0x10404000
#define HRAM_BASE              0x80000000
#define SRAM_BASE              0xE0000000
#define SHADOWSTACK_BASE       0xE0010000

#define MAILBOX_IRQ_ID         68
#define MAILBOX_REG_DATA       ((uint32_t*)(MAILBOX_BASE + 0x00))
#define MAILBOX_REG_DOORBELL   ((uint32_t*)(MAILBOX_BASE + 0x20))
#define MAILBOX_REG_COMPLETION ((uint32_t*)(MAILBOX_BASE + 0x24))

#define SHADOWSTACK_REG_BASE   ((uint32_t*)(SHADOWSTACK_BASE + 0X00000))
#define SHADOWSTACK_REG_LIMIT  ((uint32_t*)(SHADOWSTACK_BASE + 0X00100))
#define SHADOWSTACK_REG_HEAP   ((uint32_t*)(HRAM_BASE + 0X10000))

/* =============================================================================
 * MailBox definitions and functions
 * 
 * Address    Field              Commit Log (PHMon64)   Commit Log (PHMon32)
 * -----------------------------------------------------------------------------
 * 0x00       Reserved 1         instruction            instruction
 * 0x04       Channel Status     pc_src (LSB)           pc_src
 * 0x08       Reserved 2         pc_src (MSB)           pc_dst
 * 0x0c       Reserved 3         pc_dst (LSB)           address
 * 0x10       Channel Flags      pc_dst (MSB)           data
 * 0x14       Length             address (LSB)
 * 0x18       Message Header     address (MSB)
 * 0x1c       Message Payload    data (LSB)
 * 0x20       Doorbell IRQ       data (MSB)
 * 0x24       Completion IRQ
 * ===========================================================================*/

static inline bool
mailbox_is_call()
{
#ifdef COMMIT_LOG_PHMON
	/*
	 * Verify if the instruction in the PHMon mailbox is a RVI32 `call`.
	 *
	 * This function assumes that any compressed instruction decoded by the
	 * core is expanded to its 32-bits equivalent.
	 *
	 * RVI Call
	 * -----------------------------------------------------------
	 * JAL  (link x1)      xxxx xxxx xxxx xxxx xxxx 0000 1110 1111
	 * JAL  (link x5)      xxxx xxxx xxxx xxxx xxxx 0010 1110 1111
	 * JALR (link x1)      xxxx xxxx xxxx xxxx xxxx 0000 1110 0111
	 * JALR (link x5)      xxxx xxxx xxxx xxxx xxxx 0010 1110 0111
	 * -----------------------------------------------------------
	 *           MASK   0x    0    0    0    0    0    d    f    7
	 *         RESULT   0x    0    0    0    0    0    0    e    7
	 */
	return (MAILBOX_REG_DATA[0] & 0x00000df7) == 0x000000e7;
#elif COMMIT_LOG_CVA6
	return false;
#endif
}

static inline bool
mailbox_is_return()
{
#ifdef COMMIT_LOG_PHMON
	/*
	 * Verify if the instruction in the PHMon mailbox is a RVI32 `return`.
	 *
	 * This function assumes that any compressed instruction decoded by the core
	 * is expanded to its 32-bits equivalent.
	 *
	 * RVI Return
	 * -----------------------------------------------------------
	 * JALR (return x1)    xxxx xxxx xxxx 0000 1xxx xxxx x110 0111
	 * JALR (return x5)    xxxx xxxx xxxx 0010 1xxx xxxx x110 0111
	 * -----------------------------------------------------------
	 *           MASK   0x    0    0    0    d    8    0    7    f
	 *         RESULT   0x    0    0    0    0    8    0    6    7
	 */
	return (MAILBOX_REG_DATA[0] & 0x000d807f) == 0x00008067;
#elif COMMIT_LOG_CVA6
	return false;
#endif
}

static inline uint64_t
mailbox_get_pc_src()
{
#ifdef COMMIT_LOG_PHMON
	return *(ssptr_t*)(MAILBOX_REG_DATA + 1);
#elif COMMIT_LOG_CVA6
	return false;
#endif
}

static inline uint64_t
mailbox_get_pc_dst()
{
#ifdef COMMIT_LOG_PHMON
	return *(ssptr_t*)(MAILBOX_REG_DATA + 1 + sizeof(ssptr_t)/sizeof(uint32_t));
#elif COMMIT_LOG_CVA6
	return false;
#endif
}

static inline void
mailbox_complete(uint32_t data)
{
	MAILBOX_REG_DATA[0] = data;
	*MAILBOX_REG_COMPLETION = 1;
}

static inline void
mailbox_clear_doorbell()
{
	*MAILBOX_REG_DOORBELL = 0;
}

/* =============================================================================
 * Shadow Stack definitions and functions
 * ===========================================================================*/

typedef struct shadow_stack {
	uint32_t *base;
	uint32_t *limit;
	uint32_t *ptr;
	uint32_t *heap;
} shadow_stack_t;

shadow_stack_t shadow_stack = {
	.base  = SHADOWSTACK_REG_BASE,
	.limit = SHADOWSTACK_REG_LIMIT,
	.ptr   = SHADOWSTACK_REG_LIMIT,
	.heap  = SHADOWSTACK_REG_HEAP
};

static inline void
shadow_stack_push(ssptr_t address)
{
	*((ssptr_t*)shadow_stack.ptr) = address;
	shadow_stack.ptr += sizeof(ssptr_t) / sizeof(uint32_t);
}

static inline bool
shadow_stack_check(ssptr_t address)
{
	bool fault = false;

	shadow_stack.ptr -= sizeof(ssptr_t) / sizeof(uint32_t);
	fault = !(*((ssptr_t*)shadow_stack.ptr) == address);

	return fault;
}

static inline bool
shadow_stack_is_full()
{
	return shadow_stack.ptr == shadow_stack.limit;
}

static inline bool
shadow_stack_is_empty()
{
	return shadow_stack.ptr == shadow_stack.base;
}

static inline void
shadow_stack_save()
{
	uint32_t size = SHADOWSTACK_REG_LIMIT - SHADOWSTACK_REG_BASE;
	uint32_t i    = 0;

	for (i=0; i<size; i++) {
		shadow_stack.heap[i] = shadow_stack.base[i];
	}
	shadow_stack.heap += size;
	shadow_stack.ptr = SHADOWSTACK_REG_BASE;
}

static inline void
shadow_stack_restore()
{
	uint32_t size = SHADOWSTACK_REG_LIMIT - SHADOWSTACK_REG_BASE;
	uint32_t i    = 0;

	for (i=0; i<size; i++) {
		shadow_stack.base[i] = (shadow_stack.heap - i - 1)[i];
	}
	shadow_stack.heap -= size;
	shadow_stack.ptr = SHADOWSTACK_REG_LIMIT;
}

/* =============================================================================
 * External IRQ handler
 * ===========================================================================*/

void 
external_irq_handler(void)
{
	// PLIC IRQ Complete register address
	volatile uint32_t *IRQ_COMPLETE = (uint32_t*)0xC8200004;

	// Shadow Stack.
	uint64_t address = 0x0;
	bool     fault   = false;

	// Claim the IRQ to serve the interrupt request.
	(void)*IRQ_COMPLETE;

	mailbox_clear_doorbell();
	if (shadow_stack_is_empty()) {
		shadow_stack_restore();
	}
	address = mailbox_get_pc_dst();
	fault = shadow_stack_check(address);
	mailbox_complete(fault);

	// Complete interrupt writing the interrupt ID to the PLIC Completion
	// register.
	*IRQ_COMPLETE = MAILBOX_IRQ_ID;
}

/* =============================================================================
 * Main
 * ===========================================================================*/

int 
main(int argc, char **argv)
{
	// Configure the UART peripheral to enable printf style logging.
#ifdef TARGET_SYNTHESIS                
	int baud_rate = 115200;
	int test_freq = 50000000;
#else
	//set_flls();
	int baud_rate = 115200;
	int test_freq = 100000000;
#endif
	uart_set_cfg(
		0,
		(test_freq/baud_rate) >> 4
	);

	printf("[IBEX] Shadow stack, 64 bit, 2 ISR, return\n");
	uart_wait_tx_done();

	uint32_t          val        = 0;
	volatile uint32_t *plic_prio = (volatile uint32_t*)0xc8000110;
	volatile uint32_t *plic_en   = (volatile uint32_t*)0xc8002008;
	uint32_t          *ptr       = NULL;

	// Initialize the shadow stack memory content. This is required to run
	// the tests on QuestaSim, otherwise reading the OpenTitan SRAM returns
	// 'X' and the simulation crashes.
	ptr = SHADOWSTACK_REG_BASE;
	while (ptr != SHADOWSTACK_REG_LIMIT) {
		*ptr = 0;
		ptr += 1;
	}

	// Set the Machine Trap-Vector base address to 0xe0000000 and configure the
	// core to serve interrupt in vectorized mode.
	val = 0xe0000001;
	asm volatile("csrw mtvec, %0\n" : : "r"(val));

	// Enable global and external interrupts on IBEX.
	val = 0x00001808;
	asm volatile("csrw  mstatus, %0\n" : : "r"(val));
	val = 0x00000800;
	asm volatile("csrw  mie, %0\n"     : : "r"(val));

	// Configure PLIC to enable MailBox interrupt and setting its priority to 1.
	*plic_prio = 1;
	*plic_en = 0x00000010;

	// React to CVA6 command executing the `external_irq_handler` function.
	while(1) {
		asm volatile ("wfi");
	}

	return 0;
}
