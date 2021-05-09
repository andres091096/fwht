`timescale 1ns / 1ps
`default_nettype	none
module sequency_order(i_clk, i_ce, i_reset, o_index);
    parameter   L_WIDTH      = 3;

    input wire i_clk;
    input wire i_ce;
    input wire i_reset;
    output wire [L_WIDTH-1:0] o_index;

    reg  [L_WIDTH-1:0] binary_value = {{L_WIDTH-1{1'b0}},1'b1};
    reg  [L_WIDTH-1:0] gray_value   = {L_WIDTH{1'b0}};

    always @(posedge i_clk)
      if (i_reset) begin
         binary_value <= {{L_WIDTH-1{1'b0}},1'b1};
         gray_value <= {L_WIDTH{1'b0}};
      end
      else if (i_ce) begin
         binary_value <= binary_value + 1;
         gray_value <= (binary_value >> 1) ^ binary_value;
      end

     /*bit_reversal*/
     /*genvar i;
     generate
      for ( i = 0; i < L_WIDTH; i = i + 1)
        begin
          assign o_index[L_WIDTH-i] = gray_value[i];
        end
    endgenerate
    */
    assign o_index[11] = gray_value[0];
    assign o_index[10] = gray_value[1];
    assign o_index[9] = gray_value[2];
    assign o_index[8] = gray_value[3];
    assign o_index[7] = gray_value[4];
    assign o_index[6] = gray_value[5];
    assign o_index[5] = gray_value[6];
    assign o_index[4] = gray_value[7];
    assign o_index[3] = gray_value[8];
    assign o_index[2] = gray_value[9];
    assign o_index[1] = gray_value[10];
    assign o_index[0] = gray_value[11];



endmodule
