#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#include "utils.h"

#define EntryAddr 0x1C008080
#define ClusterBootAddrReg 0xB0200040
#define ClusterFethEnableReg 0xff000020
#define ClusterEocReg 0xff000024
#define ClusterNumCores 8
#define EdnEnAddrReg 0xc1170014

#define MboxAddrReg0 0x10404008
#define MboxAddrReg1 0x10404010
#define MboxAddrReg2 0x10404014
#define MboxAddrReg3 0x10404018
#define MboxAddrReg4 0x1040401C
#define MboxAddrReg5 0x10404020

int main() {

  volatile int * fetch_en, * eoc, * edn_enable, * boot_addr;
  volatile int * p_reg1, * p_reg2, * p_reg3, * p_reg4, * p_reg5;
  int a, b, c, e, d, err;

  fetch_en = (int *) ClusterFethEnableReg;
  eoc = (int *) ClusterEocReg;
  edn_enable = (int *) EdnEnAddrReg;
  *edn_enable = 0x9996;

  for (int i = 0; i < ClusterNumCores; i++) {
    boot_addr = (int *) (ClusterBootAddrReg + 0x4*i);
    *boot_addr = EntryAddr;
  }

  /////////////////////////
  // Cluster offloading  //
  /////////////////////////

  *fetch_en = 0x1;
  while(!(*eoc));
  *fetch_en = 0x0;

  /////////////////
  // Test Check  //
  /////////////////

  err = 0;

  p_reg1 = (int *) MboxAddrReg0;
  p_reg2 = (int *) MboxAddrReg1;
  p_reg3 = (int *) MboxAddrReg2;
  p_reg4 = (int *) MboxAddrReg3;
  p_reg5 = (int *) MboxAddrReg4;

  a = *p_reg1;
  b = *p_reg2;
  c = *p_reg3;
  d = *p_reg4;
  e = *p_reg5;

  if(a == 0xBAADC0DE && b == 0xBAADC0DE && c == 0xBAADC0DE && d == 0xBAADC0DE && e == 0xBAADC0DE)
    // printf_cl("Msg ok, test succeeded!\r\n");
    err = 0;
  else{
    // printf_cl("Msg wrong, test failed!\r\n");
    err++;
  }

  return err;
}

