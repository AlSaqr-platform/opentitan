/*
// Codice rappresentativo di una trasmissione UART di un dato criptato

// Common Lib
#include "sw/device/lib/base/mmio.h"
#include "sw/device/lib/runtime/hart.h"
#include "sw/device/lib/runtime/irq.h"
#include "sw/device/lib/runtime/log.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"
#include "sw/device/lib/testing/test_framework/status.h"
#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"
#include "sw/device/lib/base/memory.h"

#include "sw/device/silicon_creator/rom/uart.h"
#include "sw/device/silicon_creator/rom/string_lib.h"

// RV PLIC Lib
#include "sw/device/lib/dif/dif_rv_plic.h"

// UART lib
#include "sw/device/lib/dif/dif_uart.h"

// AES lib
#include "sw/device/lib/dif/dif_aes.h"
#include "sw/device/lib/testing/aes_testutils.h"
#include "hw/ip/aes/model/aes_modes.h"

#define TIMEOUT (1000 * 1000)

////////////////////////// Global Variables///////////////////////////////////////

// RV PLIC
static const uint32_t kPlicTarget = kTopEarlgreyPlicTargetIbex0;
static dif_rv_plic_t plic0;

// UART
static dif_uart_t uart0;
static unsigned char kSendData[] = "Ciao! Come va ?";
//static unsigned char kSendData[] = "Ciao! Oggi è una bella giornata, perfetta per una passeggiata!";
static unsigned char kReceiveData[sizeof(kSendData)];
// static unsigned char kReceiveData[sizeof(kAesModesPlainText)];
size_t uart_buf_index = 0;
static volatile bool uart_rx_watermark_handled = false;

// UART ISR
static void handle_uart_isr(const dif_rv_plic_irq_id_t interrupt_id) {
  // printf("we1\n");
  dif_uart_irq_t uart_irq = 0;

  switch (interrupt_id) {
    case kTopEarlgreyPlicIrqIdTlul2axiMboxIrq : //here
      CHECK(!uart_rx_watermark_handled,
            "UART RX watermark IRQ asserted more than once");

      uart_irq = kDifUartIrqRxWatermark;
      uart_rx_watermark_handled = true;
      break;
   
    default:
      test_status_set(kTestStatusFailed);
  }

  CHECK_DIF_OK(dif_uart_irq_acknowledge(&uart0, uart_irq));
}

// External ISR
void ottf_external_isr(void) {

 #ifdef TARGET_SYNTHESIS                
  int baud_rate = 115200;
  int test_freq = 50000000;
  #else
  int baud_rate = 115200;
  int test_freq = 100000000;
  #endif
  uart_set_cfg(0,(test_freq/baud_rate)>>4);
  printf("---------------------------------------------------------------------2 \n");

  dif_rv_plic_irq_id_t interrupt_id;
  CHECK_DIF_OK(dif_rv_plic_irq_claim(&plic0, kPlicTarget, &interrupt_id));

  top_earlgrey_plic_peripheral_t peripheral_id =
      top_earlgrey_plic_interrupt_for_peripheral[interrupt_id];
  // CHECK(peripheral_id == kTopEarlgreyPlicPeripheralUart0,
  //       "ISR interrupted peripheral is not UART!");
  handle_uart_isr(interrupt_id);

size_t bytes_received=0;
CHECK_DIF_OK(dif_uart_bytes_receive(&uart0, 1, &kReceiveData[uart_buf_index], &bytes_received));
  if(bytes_received) 
  {
    uart_buf_index += 1;
  }

  CHECK_DIF_OK(dif_rv_plic_irq_complete(&plic0, kPlicTarget, interrupt_id));   

  // printf("irqqqqq\n");
}

// PLIC Interrupt
static void plic_configure_irqs(dif_rv_plic_t *plic) {
  printf("we3\n");

  CHECK_DIF_OK(dif_rv_plic_irq_set_priority(
      plic, kTopEarlgreyPlicIrqIdTlul2axiMboxIrq , kDifRvPlicMaxPriority));
  CHECK_DIF_OK(dif_rv_plic_target_set_threshold(&plic0, kPlicTarget,
                                          kDifRvPlicMinPriority));
  CHECK_DIF_OK(dif_rv_plic_irq_set_enabled(plic,
                                           kTopEarlgreyPlicIrqIdTlul2axiMboxIrq ,
                                           kPlicTarget, kDifToggleEnabled));
  printf("we3\n");
  }


///////////////////////// MAIN ////////////////////////////////

#define TARGET_SYNTHESIS
// #define kTopEarlgreyPlicIrqIdMboxWatermark = kTopEarlgreyPlicIrqIdFlashCtrlProgEmpty = 159 
// kTopEarlgreyPlicIrqIdSensorCtrlAonInitStatusChange = 158

int main(int argc, char **argv) {

// 
  #ifdef TARGET_SYNTHESIS                
  int baud_rate = 115200;
  int test_freq = 50000000;
  #else
  int baud_rate = 115200;
  int test_freq = 100000000;
  #endif
  uart_set_cfg(0,(test_freq/baud_rate)>>4);

//
 dif_aes_key_share_t key;
 size_t data_size = sizeof(kSendData);
 unsigned char encrypted_data[data_size];
 unsigned char decrypted_data[data_size];

//
 irq_global_ctrl(true);     //
 irq_external_ctrl(true);   //

//
 mmio_region_t plic_base_addr =
      mmio_region_from_addr(TOP_EARLGREY_RV_PLIC_BASE_ADDR);
  CHECK_DIF_OK(dif_rv_plic_init(plic_base_addr, &plic0)); 

//  
 plic_configure_irqs(&plic0);


//  printf("test irq\n");

 int volatile *p_reg;
 int volatile p_reg1;
 p_reg = (int *) 0x10404020;
 p_reg1 = *p_reg;
 printf("%d\n", p_reg1);

 while(1){
  // sleep(1);

 }

  // printf("end\n");

 return 0;
}

*/