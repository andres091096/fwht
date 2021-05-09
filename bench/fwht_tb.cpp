////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Nacional de Astrofísica, Óptica y Electrónica
// Engineer: Andrés M. Manjarrés G.
//
// Create Date: 05.03.2021
// File Name: fwht_tb.cpp
// Project Name: Fast Walsh-Haddamard Transform
// Description: Verilator Testbench of the complete module of Fast Walsh
//              Haddamard Transform
//
// Dependencies: fwht.v
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
////////////////////////////////////////////////////////////////////////////////
// MIT License
//
// Copyright (c) 2021 Instituto Nacional de Astrofísica, Óptica y Electrónica.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
////////////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>     /* calloc, exit, free */
#include <iostream>
#include <fstream>
#include "Vfwht.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
using namespace std;

// Fixed-point format: 1.15 (16-bit)
//typedef uint16_t fixed_point_t;
typedef unsigned int fixed_point_t;
#define FIXED_POINT_FRACTIONAL_BITS 14
#define FIXED_POINT_BITS 32
#define INPUT_SIZE 4096

// Converts float to 11.5 format
inline fixed_point_t float_to_fixed(float input)
{
    return (fixed_point_t)(round(input * (1 << FIXED_POINT_FRACTIONAL_BITS)));
}

inline float fixed_to_float(fixed_point_t input)
{
    int sign = input >> (FIXED_POINT_BITS - 1);
    if (sign == 1){
      input = input - 1;
      input = ~input;
      return -1*((float)input / (float)(1 << FIXED_POINT_FRACTIONAL_BITS));
    }
    else{
        return ((float)input / (float)(1 << FIXED_POINT_FRACTIONAL_BITS));
    }

}

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


float * fwht(float fwht_in[], int n)
{
  float x1; float x2;
  float *temp = (float*)calloc(n,sizeof(float)); //Walsh-Hadamard Transform
  int M; int L;
  static float  fwht_out[INPUT_SIZE];  //n=4096 because the use of static I must put a constant size
  int stages = log10(n)/log10(2); // log2(n)

  M = n; L = n;
  for (int i = 0; i < n; i++) {
    temp[i] = fwht_in[i];
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
  for (int i = 0; i < n; i++) {
    fwht_out[i] = temp[i];
  }
  free(temp);

  return fwht_out;
}

void tick(int tickcount, Vfwht *tb, VerilatedVcdC* tfp) {

	tb->eval();
	if(tfp)
				tfp->dump(tickcount * 10-2);
	tb->ACLK=1;
	tb->eval();
	if(tfp)
				tfp->dump(tickcount * 10);
	tb->ACLK=0;
	tb->eval();

	if(tfp){
				tfp->dump(tickcount * 10+5);
				tfp->flush();
			}
}

int main(int argc, char const *argv[]) {
  int check_status = 0;
	Verilated::commandArgs(argc, argv);
	Vfwht *tb = new Vfwht; // Instantiate our design

  //Generate a trace
	Verilated::traceEverOn(true);
	VerilatedVcdC* tfp = new VerilatedVcdC;
	tb->trace(tfp,99);
	tfp->open("fwht_trace.vcd");
  unsigned tickcount=0;
  /* Apply Reset*/
	tick(++tickcount,tb,tfp);
	tb->ARESET = 1;
	tick(++tickcount,tb,tfp);
	tb->ARESET = 0;
	tick(++tickcount,tb,tfp);

  float f;
  int i = 0;
  fixed_point_t f_hardware;
  float fwht_in[INPUT_SIZE];
  for (i = 0; i < INPUT_SIZE; i++) {
    fwht_in[i] = 0;
  }
  i = 0;
  std::ifstream fin("data/measures.bin", std::ios::binary);
  while (fin.read(reinterpret_cast<char*>(&f), sizeof(float))){
    f = f/64;
    fwht_in[i] = f;
    f_hardware = float_to_fixed(f);
    tick(++tickcount,tb,tfp);
    tb->s_axis_tdata  = f_hardware;
    tb->s_axis_tvalid = 1;
    i = i+1;
  }
  fin.close();

  float *fwht_out;
  fwht_out = fwht(fwht_in, INPUT_SIZE);

  tick(++tickcount,tb,tfp);
  tb->s_axis_tvalid = 0;

  float tol_err = 1e-2;
  float diff;
  int j = 0;
  int bits = log10(INPUT_SIZE)/log10(2); // log2(INPUT_SIZE)
  int index_cpu;
  int index_rtl;
  float cpu_version[INPUT_SIZE];
  for (int i = 0; i < 8000; i++) {
    tick(++tickcount,tb,tfp);
    if (tb->m_axis_tvalid){
      diff = fixed_to_float((fixed_point_t)tb->m_axis_tdata) - *(fwht_out+j);
      index_cpu = bit_reversal(binaryToGray(j),bits);
      index_rtl = tb->o_index;
      cpu_version[j] = *(fwht_out+j);
      if (abs(diff) > tol_err | index_cpu != index_rtl){
        check_status = 1;
        printf("Data Mismatch: data : %i : Expected %f -> Got %f \n", j, *(fwht_out+j) , fixed_to_float((fixed_point_t)tb->m_axis_tdata));
      }
      j = j+1;
    }
  }

  /*ofstream myFile ("data/Image_Recons_data.bin", ios::out | ios::binary);
  myFile.write ((char*)&f_fp, INPUT_SIZE*sizeof(fixed_point_t));*/

  if (check_status) {
      printf("INFO: Test failed\n");
      return EXIT_FAILURE;
  } else {
      printf("INFO: Test completed successfully.\n");
      return EXIT_SUCCESS;
  }

}
