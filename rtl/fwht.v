`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 22.02.2021 08:36:29
// Design Name:
// Module Name: fwht
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//               * 2^(L_WIDTH)  = Number of Inputs
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
`default_nettype	none
module fwht(ACLK, ARESET, s_axis_tdata, s_axis_tvalid, s_axis_tready, m_axis_tdata, m_axis_tvalid, m_axis_tready, o_index );
    parameter WIDTH=32, L_WIDTH=12;

    input wire ACLK;
    input wire ARESET;
    //Input interface
    input wire [(WIDTH-1):0] s_axis_tdata;
    input wire s_axis_tvalid;
    output wire s_axis_tready;
    //Output  interface
    output wire [(WIDTH-1):0] m_axis_tdata;
    input wire m_axis_tready;
    output wire m_axis_tvalid;
    output wire [(L_WIDTH-1):0]o_index;
    /*
    wire [(WIDTH-1):0] out_stage13;
    wire [(WIDTH-1):0] out_stage12;
    */
    wire [(WIDTH-1):0] out_stage11;
    wire [(WIDTH-1):0] out_stage10;
    wire [(WIDTH-1):0] out_stage9;
    wire [(WIDTH-1):0] out_stage8;
    wire [(WIDTH-1):0] out_stage7;
    wire [(WIDTH-1):0] out_stage6;
    wire [(WIDTH-1):0] out_stage5;
    wire [(WIDTH-1):0] out_stage4;
    wire [(WIDTH-1):0] out_stage3;
    wire [(WIDTH-1):0] out_stage2;
    wire [(WIDTH-1):0] out_stage1;
    wire [(WIDTH-1):0] d_tdada;
    /*
    wire valid_stage13;
    wire valid_stage12;
    */
    wire valid_stage11;
    wire valid_stage10;
    wire valid_stage9;
    wire valid_stage8;
    wire valid_stage7;
    wire valid_stage6;
    wire valid_stage5;
    wire valid_stage4;
    wire valid_stage3;
    wire valid_stage2;
    wire valid_stage1;

    wire o_valid;
    wire d_tvalid;
    /*
    stage #(.WIDTH(WIDTH), .L_WIDTH(L_WIDTH), .M_WIDTH(11))
            stage_13(ACLK, ARESET, s_axis_tdata, s_axis_tvalid, out_stage13, valid_stage13);

    stage #(.WIDTH(WIDTH), .L_WIDTH(L_WIDTH), .M_WIDTH(11))
            stage_12(ACLK, ARESET, out_stage13, valid_stage13, out_stage12, valid_stage12);
    */
    assign d_tdada  = s_axis_tvalid ? s_axis_tdata : {WIDTH{1'b0}};
    assign d_tvalid = s_axis_tvalid | (|count) ;


    stage #(.WIDTH(WIDTH), .L_WIDTH(L_WIDTH), .M_WIDTH(11))
            stage_11(ACLK, ARESET, d_tdada, d_tvalid, out_stage11, valid_stage11);

    stage #(.WIDTH(WIDTH), .L_WIDTH(L_WIDTH), .M_WIDTH(10))
            stage_10(ACLK, ARESET, out_stage11, valid_stage11, out_stage10, valid_stage10);

    stage #(.WIDTH(WIDTH), .L_WIDTH(L_WIDTH), .M_WIDTH(9))
            stage_9(ACLK, ARESET, out_stage10, valid_stage10, out_stage9, valid_stage9);

    stage #(.WIDTH(WIDTH), .L_WIDTH(L_WIDTH), .M_WIDTH(8))
            stage_8(ACLK, ARESET, out_stage9, valid_stage9, out_stage8, valid_stage8);

    stage #(.WIDTH(WIDTH), .L_WIDTH(L_WIDTH), .M_WIDTH(7))
            stage_7(ACLK, ARESET, out_stage8, valid_stage8, out_stage7, valid_stage7);

    stage #(.WIDTH(WIDTH), .L_WIDTH(L_WIDTH), .M_WIDTH(6))
            stage_6(ACLK, ARESET, out_stage7, valid_stage7, out_stage6, valid_stage6);

    stage #(.WIDTH(WIDTH), .L_WIDTH(L_WIDTH), .M_WIDTH(5))
            stage_5(ACLK, ARESET, out_stage6, valid_stage6, out_stage5, valid_stage5);

    stage #(.WIDTH(WIDTH), .L_WIDTH(L_WIDTH), .M_WIDTH(4))
            stage_4(ACLK, ARESET, out_stage5, valid_stage5, out_stage4, valid_stage4);

    stage #(.WIDTH(WIDTH), .L_WIDTH(L_WIDTH), .M_WIDTH(3))
            stage_3(ACLK, ARESET, out_stage4, valid_stage4, out_stage3, valid_stage3);

    stage #(.WIDTH(WIDTH), .L_WIDTH(L_WIDTH), .M_WIDTH(2))
           stage_2(ACLK, ARESET, out_stage3, valid_stage3, out_stage2, valid_stage2);

    stage #(.WIDTH(WIDTH), .L_WIDTH(L_WIDTH), .M_WIDTH(1))
           stage_1(ACLK, ARESET, out_stage2, valid_stage2, out_stage1, valid_stage1);

    laststage #(.WIDTH(WIDTH))
              last(ACLK, ARESET, out_stage1, valid_stage1, m_axis_tdata, o_valid);

    sequency_order #(.L_WIDTH(L_WIDTH))
                    seq_ord(ACLK, o_valid, ARESET, o_index);

    // s_axis_tready logic //
    localparam state1 = 2'b00;
    localparam state2 = 2'b01;
    localparam state3 = 2'b10;
    localparam state4 = 2'b11;

    reg [1:0] state = state1;
    reg ready;
    reg count_rst;
    reg [(L_WIDTH-1):0] count = 0;

    always @(posedge ACLK)
        if (count_rst)
            count <= {L_WIDTH{1'b0}};
        else
            count <= count + 1'b1;

    always @(posedge ACLK)
        if (ARESET) begin
            state <= state1;
      end
      else
         case (state)
            state1 : begin
               if (s_axis_tvalid)
                  state <= state2;
               else
                  state <= state1;
            end
            state2 : begin
               if (&count[L_WIDTH-1:1])
                  state <= state3;
               else
                  state <= state2;
            end
            state3 : begin
               if (o_valid)
                  state <= state4;
               else
                  state <= state3;
            end
            state4 : begin
               if (!o_valid)
                  state <= state1;
               else
                  state <= state4;
            end
         endcase

    always @(*)
        case (state)
            state1 : begin
                ready    <= 1'b1;
                count_rst <= 1'b1;
            end
            state2 : begin
                ready    <= 1'b1;
                count_rst <= 1'b0;
            end
            state3 : begin
                ready    <= 1'b0;
                count_rst <= 1'b1;
            end
            state4 : begin
                ready    <= 1'b0;
                count_rst <= 1'b1;
            end
            default : begin
                ready    <= 1'b1;
                count_rst <= 1'b1;
            end
        endcase

    assign s_axis_tready = ready;
    assign m_axis_tvalid = o_valid;

endmodule
