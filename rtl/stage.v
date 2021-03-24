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
// Filename: stage.v
//
// Project: Fast Walsh-Haddamard Transform
//
// Description: The stage block implement one stage of the Fast Walsh-Haddamard Transform
//              This block have. The parameter 2^(M_WIDTH) --> M

//
// Author: Andrés M. Manjarrés
////////////////////////////////////////////////////////////////////////////////
`default_nettype	none
module stage(clk, reset, i_data, i_start, o_data, o_valid);
    parameter WIDTH=16, L_WIDTH=3, M_WIDTH=2;

    input wire clk;
    input wire reset;
    input wire [(WIDTH-1):0] i_data;
    input wire i_start;
    output wire [(WIDTH-1):0] o_data;
    output reg o_valid;

    reg [M_WIDTH-1:0] M_counter = {M_WIDTH{1'b0}};
    wire w_valid;

    wire FIFO_rd;
    wire FIFO_rd_pulse;
    reg  [L_WIDTH-1:0] r_FIFO_rd;

    wire FIFO_wr;
    wire FIFO_wr_pulse;
    reg  [L_WIDTH-1:0] r_FIFO_wr;

    wire Mux_FIFO;
    wire Mux_Output;
    wire M_enable;
    wire [1:0] ctr = {Mux_Output,Mux_FIFO};

    fsm #(.M_WIDTH(M_WIDTH))
        control(clk, reset, i_start, M_counter, FIFO_rd, FIFO_rd_pulse, FIFO_wr_pulse, Mux_FIFO, Mux_Output, M_enable);

    butterfly #(.WIDTH(WIDTH), .M_WIDTH(M_WIDTH))
              butterfly_0(clk, reset, i_start, i_data, ctr, FIFO_wr, FIFO_rd, o_data, w_valid);

   always @(posedge clk)
      if (reset)
         M_counter <= {M_WIDTH{1'b0}};
      else if (M_enable)
         M_counter <= M_counter + 1'b1;

   initial r_FIFO_rd = 0;
   wire temp1 = (r_FIFO_rd > 0) ? 1'b1 : 1'b0;
   assign FIFO_rd = temp1 || FIFO_rd_pulse;

   always @(posedge clk)
      if (reset)
         r_FIFO_rd <= {L_WIDTH{1'b0}};
      else if (FIFO_rd)
         r_FIFO_rd <= r_FIFO_rd + 1'b1;

   initial r_FIFO_wr = 0;
   wire temp2 = (r_FIFO_wr > 0) ? 1'b1 : 1'b0;
   assign FIFO_wr = temp2 || FIFO_wr_pulse;

   always @(posedge clk)
      if (reset)
         r_FIFO_wr <= {L_WIDTH{1'b0}};
      else if (FIFO_wr)
         r_FIFO_wr <= r_FIFO_wr + 1'b1;

   always @(*)
        o_valid <= w_valid;


endmodule
