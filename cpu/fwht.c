#include "fwht.h"
#include <math.h> //log10
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h> //uint8_t
#include <string.h> //memset
/*
Fast Sequency Ordered Walsh-Hadamard Transform
  the index input, is included because is better do not recompute the Sequency Ordered
  index in each instance of the Walsh-Hadamard Transform.
*/
unsigned int binaryToGray(unsigned int num)
{
    return (num >> 1) ^ num;
}

unsigned int bit_reversal(int n, int bits)
{
  /* Obtained from: http://www.katjaas.nl/bitreversal/bitreversal.html */
  unsigned int nrev;
  long N = 1<<bits; // Mask to clear all the bits shifted.
  nrev = n;

  for (int i=1; i<bits; i++)
  {
    n >>= 1;
    nrev <<= 1;
    nrev |= n & 1; //bitwise-or and bitwise-and to take the LSB of n
  }
  nrev &= N-1;         // clear all bits more significant than N-1
  return nrev;
}

void gen_sensing_matrix(int *A_matrix, int n, int measures)
{

  int *I_matrix = (int*)calloc(n*n,sizeof(int)); //Walsh-Hadamard Transform
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      if(i==j){I_matrix[i*n+j] = 1;}
      else{I_matrix[i*n+j] = 0;}
    }
  }



  int x1; int x2;
  int M = n*n;
  int L = n*n;

  int stages = log10(n)/log10(2); // log2(n*n)
  for (int k = 0; k < stages; k++) { //Stage loop
    M = M/2;
    for (int J = 0; J < n*n; J = J + L) {//Loop2: Split the vector in 2^k new sub_arrays
      for (int i = J; i < J + M; i++) { //Inner Loop
        x1 = I_matrix[i];
        x2 = I_matrix[i+M];
        I_matrix[i] = x1 + x2;
        I_matrix[i+M] = x1 - x2;
      }
    }
    L = L/2;
  }

  /*Sequency Ordered*/
  int bits = log10(n)/log10(2); // log2(n*n)
  unsigned int *index = (unsigned int*)calloc(n,sizeof(unsigned int));
  for (int i = 0; i < n; i++) { index[i] = bit_reversal(binaryToGray(i),bits); }

  for (int j = 0; j < n; j++){
    for (int i = 0; i < measures; i++){ //Only m rows.
      A_matrix[i*n+j] = I_matrix[i*n+index[j]];
    }
  }

  free(I_matrix);
}


void fwht(float *Image, float *out_fwht, int n, unsigned int *index, int measures, float sqrt_eigval)
{
  float x1; float x2;
  float *temp = (float*)calloc(n,sizeof(float)); //Walsh-Hadamard Transform
  int M; int L;
  int stages = log10(n)/log10(2); // log2(n)

  M = n; L = n;
  for (int i = 0; i < n; i++) {
    temp[i] = Image[i];
  }

  for (int k = 0; k < stages; k++) { //Stage loop
    M = M/2;
    for (int J = 0; J < n; J = J + L) {//Loop2: Split the vector in 2^k new sub_arrays
      for (int i = J; i < J + M; i++) { //Inner Loop
        x1 = temp[i];
        x2 = temp[i+M];
        temp[i] = x1 + x2;
        temp[i+M] = x1 - x2;
      }
    }
    L = L/2;
  }

  /*Sequency Ordered*/
  for (int i = 0; i < measures; i++) {
    out_fwht[i] = temp[index[i]]/sqrt_eigval;
  }
  free(temp);
}
