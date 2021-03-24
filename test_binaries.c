#include <stdio.h>
#include <stdlib.h>
#include <stdint.h> //uint8_t
#include <math.h>   //fabs, pow, sqrt
#include <string.h> //memset

int main(int argc, char *argv[]) {

  int *Full_A   = (int*)calloc(4096,sizeof(int));
  FILE *A_f;
  A_f = fopen("Image_Recons_data.bin","rb");
  fread(Full_A, 4096, sizeof(int), A_f);
  fclose(A_f);
  printf("%i\n",Full_A[5] );
  return 0;
}
