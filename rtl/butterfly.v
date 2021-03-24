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
// Filename: butterfly.v
//
// Project: Fast Walsh-Haddamard Transform
//
// Description: The butterfly module is the core of the FWHT algorithm,  was
// first propoused by Cooley and Tukey in the fast Fourier transform algorithm.
// The radix-2 butterfly used in FWHT implement the operation:
//                                   y_0 = x_0 + x_1
//                                   y_1 = x_0 - x_1
// In addition this butterfly block is focus on the implementation of the
// Single-Path Delay-Feedback technique.
//
// Author: Andrés M. Manjarrés
////////////////////////////////////////////////////////////////////////////////
`default_nettype	none
module	butterfly(i_clk, i_reset, i_ce, i_data, i_ctr, i_wr, i_rd, o_data, o_valid);
    parameter WIDTH=16, M_WIDTH=2;

    input wire	i_clk, i_reset, i_ce, i_wr, i_rd;
    input wire  [1:0] i_ctr;
    input wire	[(WIDTH-1):0] i_data;
    output wire	[(WIDTH-1):0] o_data;//The output value have one more bit
    output wire o_valid;

    reg	signed	[(WIDTH-1):0] w_sub = 0;
    reg	signed	[(WIDTH-1):0] w_add = 0;    
    reg [(WIDTH-1):0] input_reg; //Input register

    always @ (posedge i_clk)
    if (i_ce)
      input_reg <= i_data;
    else if(i_reset)
      input_reg <= 0;

    wire [(WIDTH-1):0] fifo_out;
    wire [(WIDTH-1):0] fifo_in = (i_ctr[0]) ? w_sub : input_reg;

    wire o_full, o_empty; //FIFO flags

    fifo  #(.WIDTH(WIDTH), .M_WIDTH(M_WIDTH))
          f0(i_clk, i_wr, fifo_in, i_rd, o_full, fifo_out, o_empty);

    always @ (*) begin
      w_sub = fifo_out - input_reg;
      w_add = input_reg + fifo_out;
    end

    assign o_data = (i_ctr[1]) ? fifo_out : w_add;
    assign o_valid = (i_ctr > 0) ? 1'b1 : 1'b0;

endmodule
