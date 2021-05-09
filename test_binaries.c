#include <stdio.h>
#include <stdlib.h>
#include <stdint.h> //uint8_t
#include <math.h>   //fabs, pow, sqrt
#include <string.h> //memset

int main(int argc, char *argv[]) {

  float *Full_A   = (float*)calloc(1229,sizeof(float));
  FILE *A_f;
  A_f = fopen("data/ifwht_input.bin","rb");
  fread(Full_A, 1229, sizeof(float), A_f);
  fclose(A_f);
  printf("%f\n",Full_A[55] );
  return 0;
}
