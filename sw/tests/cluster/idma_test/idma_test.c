#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#include "utils.h"

#define SIZE 1024

#define L2_BASE 0x1C001000
#define L1BaseAddr 0xB0000000

#define EntryAddr 0x1C008080
#define ClusterBootAddrReg 0xB0200040
#define ClusterFetchEnableReg 0xff000020
#define ClusterEocReg 0xff000024
#define ClusterNumCores 8
#define EdnEnAddrReg 0xc1170014
#define MboxAddrReg0 0x10404008

int main() {

  volatile int * fetch_en, * eoc, * edn_enable, * boot_addr, * p_reg1;

  fetch_en = (int *) ClusterFetchEnableReg;
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

  p_reg1 = (int *) MboxAddrReg0;

  if(*p_reg1 != 0){
    return -1;
  }

  return 0;
}
