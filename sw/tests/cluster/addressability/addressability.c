#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#include "utils.h"

#define SIZE 1024

#define L3_BASE 0x80000000
#define L2_BASE 0x1C001000

#define SNOOP_BASE 0x71000000


int main() {

  volatile int * fetch_en, * eoc, * edn_enable, * p_reg1;

  int err;

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

  /////////////////
  // Test Check  //
  /////////////////

  err = 0;
  p_reg1 = (int *) L2_BASE;
  // Read L2 and L3
  for(int i=0;i<SIZE;i++){
    p_reg1 = (int *)(L2_BASE + 0x8000 + i*4);
    if( *p_reg1 != i*4){
      err++;
    }
  }

  return err;
}
