`timescale 1ns / 1ps
module fsm(i_clk, i_reset, i_start, Count, rd_signal, o_FIFO_rd, o_FIFO_wr, o_Mux_FIFO, o_Mux_Output, o_M_enable);
    parameter M_WIDTH=2;

    input wire i_clk;
    input wire i_reset;
    input wire i_start;
    input wire [M_WIDTH-1:0] Count;
    input wire rd_signal;
    output reg o_FIFO_rd;
    output reg o_FIFO_wr;
    output reg o_Mux_FIFO;
    output reg o_Mux_Output;
    output reg o_M_enable; //Enable to the M counter

    parameter IDLE = 3'b000;
    parameter s1 = 3'b001;
    parameter s2 = 3'b010;
    parameter s3 = 3'b011;
    parameter s4 = 3'b100;

   reg [2:0] state = IDLE;

   always @(posedge i_clk)
      if (i_reset) begin
         state <= IDLE;
      end
      else
         case (state)
            IDLE : begin
               if (i_start)
                  state <= s1;
               else
                  state <= IDLE;
            end
            s1 : begin
               if(Count == (1<<M_WIDTH)-2)
                    state <= s2;
               else
                    state <= s1;
            end
            s2 : begin
                state <= s3;
            end
            s3 : begin
                if (Count == (1<<M_WIDTH)-1)
                    state <= s4;
                else
                    state <= s3;
            end
            s4 : begin
               if (Count == (1<<M_WIDTH)-1 && !rd_signal)
                    state <= IDLE;
               else if(Count == (1<<M_WIDTH)-1 && rd_signal)
                    state <= s3;
                else
                    state <= s4;
            end
            default : begin  // Fault Recovery
               state <= s1;
            end
         endcase

    always @(*)
    case (state)
        IDLE : begin
            o_FIFO_rd <= 1'b0;
            o_FIFO_wr <= 1'b0;
            o_Mux_FIFO <= 1'b0;
            o_Mux_Output <= 1'b0;
            o_M_enable <= 1'b0;
        end
        s1 : begin
            o_FIFO_rd <= 1'b0;
            o_FIFO_wr <= 1'b1;
            o_Mux_FIFO <= 1'b0;
            o_Mux_Output <= 1'b0;
            o_M_enable <= 1'b1;
        end
        s2 : begin
            o_FIFO_rd <= 1'b1;
            o_FIFO_wr <= 1'b0;
            o_Mux_FIFO <= 1'b0;
            o_Mux_Output <= 1'b0;
            o_M_enable <= 1'b1;
        end
        s3 : begin
            o_FIFO_rd <= 1'b0;
            o_FIFO_wr <= 1'b0;
            o_Mux_FIFO <= 1'b1; // Save the substraction into FIFO
            o_Mux_Output <= 1'b0;
            o_M_enable <= 1'b1;
        end
        s4 : begin
            o_FIFO_rd <= 1'b0;
            o_FIFO_wr <= 1'b0;
            o_Mux_FIFO <= 1'b0;
            o_Mux_Output <= 1'b1; // Out the substraction
            o_M_enable <= 1'b1;
        end
        default : begin
            o_FIFO_rd <= 1'b0;
            o_FIFO_wr <= 1'b0;
            o_Mux_FIFO <= 1'b0;
            o_Mux_Output <= 1'b0;
            o_M_enable <= 1'b0;
        end
    endcase

endmodule
