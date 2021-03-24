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
// Filename: fifo.v
//
// Project: Fast Walsh-Haddamard Transform
//
// Description: FIFO Design to the Delay Line in the butterfly module
//
// Author: Andrés M. Manjarrés
////////////////////////////////////////////////////////////////////////////////
module fifo (i_clk, i_wr, i_data, i_rd, o_full, o_data, o_empty);
  parameter WIDTH = 8; //Bits per element
  parameter M_WIDTH  = 8; //FIFO_Size = M = 2^(M_WIDTH)

  input wire i_clk;
  input wire i_wr;
  input wire [(WIDTH-1):0] i_data;
  input wire i_rd;
  output reg [(WIDTH-1):0] o_data;
  output reg o_full;
  output reg o_empty;


  reg [(WIDTH-1):0] fifo_mem [0:(1<<M_WIDTH)-1]; //FIFO Memory

  wire w_wr = (i_wr && !o_full); //write_data signal (avoid to write a Full FIFO)
  wire w_rd = i_rd &&!o_empty;   //read_data signal (avoid to read a empty FIFO)

  /* Write to the FIFO memory */
  reg [M_WIDTH:0] wr_addr; //write pointer
  reg [M_WIDTH:0] rd_addr;
  initial rd_addr = 0;
  initial wr_addr = 0;
  
  always @ (posedge i_clk) begin
    if (w_wr)
        wr_addr <= wr_addr + 1;
    if (w_rd)
        rd_addr <= rd_addr + 1;
  end

  always @ (posedge i_clk) begin
    if (w_wr)
        fifo_mem[wr_addr[M_WIDTH-1:0]] <= i_data;
    if (w_rd)
        o_data <= fifo_mem[rd_addr[M_WIDTH-1:0]];
  end  

  ///  Output Flags
  reg [M_WIDTH:0] o_fill;
  always @ (*)
    o_fill = wr_addr - rd_addr;
  always @ (*)
    o_empty = (o_fill == 0);
  always @ (*)
    o_full = (o_fill == {1'b1,{(M_WIDTH){1'b0}} });

endmodule // fifo
