#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#include "utils.h"

#define SIZE 1024
#define L2_BASE 0x1C001000

#define EntryAddr 0x1C008080
#define ClusterBootAddrReg 0xB0200040
#define ClusterFetchEnableReg 0xff000020
#define ClusterEocReg 0xff000024
#define ClusterNumCores 8
#define EdnEnAddrReg 0xc1170014

int main() {

  volatile int * fetch_en, * eoc, * edn_enable, * boot_addr, * p_reg1;
  int err;

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

  err = 0;
  p_reg1 = (int *) L2_BASE;
  // Read L2
  for(int i=0;i<SIZE;i++){
    p_reg1 = (int *)(L2_BASE + 0x8000 + i*4);
    if( *p_reg1 != i*4){
      err++;
    }
  }

  return err;
}
