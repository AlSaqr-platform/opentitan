#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#include "utils.h"
#include "cluster_code.h"

int main() {

  volatile int * fetch_en, * eoc, * edn_enable;
  volatile int * p_reg1, * p_reg2, * p_reg3, * p_reg4, * p_reg5 ;

  int a, b, c, e, d, err;

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

  err = 0;

  p_reg1 = (int *) 0x10404008;
  p_reg2 = (int *) 0x10404010;
  p_reg3 = (int *) 0x10404014;
  p_reg4 = (int *) 0x10404018;
  p_reg5 = (int *) 0x1040401C;

  a = *p_reg1;
  b = *p_reg2;
  c = *p_reg3;
  d = *p_reg4;
  e = *p_reg5;

  if( a == 0xBAADC0DE &&  b == 0xBAADC0DE && c == 0xBAADC0DE && d == 0xBAADC0DE && e == 0xBAADC0DE)
    printf_cl("Msg ok, test succeeded!\r\n");
  else{
    printf_cl("Msg wrong, test failed!\r\n");
    err++;
  }

  return err;
}

