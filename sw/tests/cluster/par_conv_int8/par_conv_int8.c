#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#include "utils.h"

int main() {

  volatile int * fetch_en, * eoc, * edn_enable;
  volatile int * p_reg;

  fetch_en = (int *) 0xff000020;
  eoc = (int *) 0xff000024;

  edn_enable = (int *) 0xc1170014;
  *edn_enable = 0x9996;

  /////////////////////////
  // Cluster offloading  //
  /////////////////////////

  *fetch_en = 0x1;
  while(!(*eoc));
  *fetch_en = 0x0;

  p_reg = (int *) 0x10404008;

  if(*p_reg != 0){
    printf_cl("Matmul wrong result!\r\n");
    return -1;
  }

  printf_cl("Cluster raised irq to Ibex, test succeed!\r\n");
  return 0;
}
