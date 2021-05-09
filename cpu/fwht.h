#include <stdint.h> //uint8_t

unsigned int binaryToGray(unsigned int num);
unsigned int bit_reversal(int n, int bits);
void gen_sensing_matrix(int *A_matrix, int n, int measures);
void fwht(float *Image, float *out_fwht, int n, unsigned int *index, int measures, float sqrt_eigval);
