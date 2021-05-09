#include <stdio.h>
#include <stdlib.h>
#include <stdint.h> //uint8_t
#include <math.h>   //fabs, pow, sqrt
#include <string.h> //memset
#include <time.h>
#include "fwht.h"
void matrix_by_vector(int *a, uint8_t *b, float *product, int m, int n, float sqrt_eigval){
  float tmp;
  for (int i = 0; i < m; i++) {
    tmp = 0;
    for (int j = 0; j < n; j++) {
      tmp += (a[i*n + j] * (float)b[j])/sqrt_eigval;
    }
    product[i] = tmp;
  }
}

void matrix_transp_by_vector(int *a, float *b, float *product, int m, int n, float sqrt_eigval){
  float tmp;
  for (int j = 0; j < n; j++) {
    tmp = 0;
    for (int i = 0; i < m; i++) {
      tmp += (a[j+ i*n] * b[i])/sqrt_eigval;
    }
    product[j] = tmp;
  }
}

int main(int argc, char const *argv[])
{
  int px = 64;
  int py = 64;
  int n = px*py;
  int m = 1229;
  float eig = 64;
  int check_status = 0;
  clock_t start, end;
  double cpu_time_used;

  int bits = log10(n)/log10(2); // log2(n*n)
  unsigned int *index = (unsigned int*)calloc(n,sizeof(unsigned int));

  uint8_t *Image = (uint8_t*)calloc(n,sizeof(uint8_t));
  FILE *im_f;
  im_f = fopen("../data/Shepp_Logan_Phantom_64.bin","rb");
  fread(Image, n, sizeof(uint8_t), im_f);
  fclose(im_f);

  float *Image_fp = (float*)calloc(n,sizeof(float));
  for (int i = 0; i < n; i++) {
    index[i] = bit_reversal(binaryToGray(i),bits);
    Image_fp[i] = (float)Image[i];
  }

  /* Generate the sensing matrix */

  int *A_matrix   = (int*)calloc(n*m,sizeof(int));
  gen_sensing_matrix(A_matrix, n, m);

  /* Compute the Matrix-by-vector product*/
  float *b_mp   = (float*)calloc(m,sizeof(float));
  start = clock();
  matrix_by_vector(A_matrix,Image, b_mp, m, n, eig);
  end = clock();
  cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
  printf("INFO: Matrix by Vector Time: %f \n", cpu_time_used);

  float *b_fw   = (float*)calloc(m,sizeof(float));
  start = clock();
  fwht(Image_fp, b_fw, n, index, m, eig);
  end = clock();
  cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
  printf("INFO: Fast WH-Transfor Time: %f \n", cpu_time_used);

  for (int i = 0; i < m; i++) {
      if (b_mp[i] != b_fw[i]){
        check_status += 1;
        printf("ERROR: Data Mismatch in forward stage: data : %i : Expected %f -> Got %f \n", i, b_mp[i] , b_fw[i]);
        if ( check_status > 4){
          break;
        }
      }
  }


  //calculate A'*b

  float *Atb  = (float*)calloc(n,sizeof(float));
  start = clock();
  matrix_transp_by_vector(A_matrix, b_mp, Atb, m, n, eig);
  end = clock();
  cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
  printf("INFO: Matrix Transpose by Vector Time: %f \n", cpu_time_used);

  float *Atb_fw    = (float*)calloc(n,sizeof(float));
  float *b_fw_ext  = (float*)calloc(n,sizeof(float));
  for (int i = 0; i < n; i++) {
    if (i < m) {b_fw_ext[i] = b_fw[i];}
    else       {b_fw_ext[i] = 0; }
  }
  start = clock();
  fwht(b_fw_ext, Atb_fw, n, index, n, eig);
  end = clock();
  cpu_time_used = ((double) (end - start)) / CLOCKS_PER_SEC;
  printf("INFO: Inverse Fast WH-Transfor Time: %f \n", cpu_time_used);
  for (int i = 0; i < n; i++) {
      if (Atb[i] != Atb_fw[i]){
        check_status += 1;
        printf("ERROR: Data Mismatch in backward stage: data : %i : Expected %f -> Got %f \n", i, Atb[i] , Atb_fw[i]);
        if ( check_status > 4){
          break;
        }
      }
  }

  free(Image);
  free(A_matrix);
  free(b_mp);
  free(b_fw);
  free(b_fw_ext);
  free(Atb);
  free(Atb_fw);
  free(index);

  if (check_status) {
      printf("INFO: Test failed\n");
      return EXIT_FAILURE;
  } else {
      printf("INFO: Test completed successfully.\n");
      return EXIT_SUCCESS;
  }

}
