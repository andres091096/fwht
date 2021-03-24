`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 23.02.2021 14:19:04
// Design Name:
// Module Name: laststage
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module laststage(i_clk, i_reset, i_data, i_ce, o_data, o_valid);
    parameter WIDTH=16;

    input wire i_clk;
    input wire i_reset;
    input wire [(WIDTH-1):0] i_data;
    input wire i_ce;
    output wire [(WIDTH-1):0] o_data;
    output reg o_valid;

    wire w_valid;
    reg [1:0] ctr = 2'b00;
    reg ctr_reset = 1'b1;
    

    reg	signed[(WIDTH-1):0] w_sub, w_add;
    wire [(WIDTH-1):0] delay_in;
    reg [(WIDTH-1):0] input_reg; //Input register
    reg [(WIDTH-1):0] delay_reg; //Input register

    always @ (posedge i_clk)
        ctr_reset <=  !i_ce;

    always @ (posedge i_clk)
    if (i_ce)
      input_reg <= i_data;
    else if(i_reset)
      input_reg <= 0;

    always @ (posedge i_clk)
    if(ctr_reset)
      delay_reg <= 0;
    else
      delay_reg <= delay_in;


    assign delay_in = (ctr[0]) ? w_sub : input_reg;

    always @ (*) begin
      w_sub = delay_reg - input_reg;
      w_add = input_reg + delay_reg;
    end

    assign o_data = (ctr[1]) ? delay_reg : w_add;
    assign w_valid = (ctr > 0) ? 1'b1 : 1'b0;

   always @(posedge i_clk)
      if (ctr_reset)
         ctr <= 0;
      else if (ctr + 1'b1 < 3)
         ctr <= ctr + 1'b1;
      else
         ctr <= 1;


   always @(*)
        o_valid = w_valid; 

endmodule
