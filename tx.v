`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/10/2026 03:42:32 PM
// Design Name: 
// Module Name: tx
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


module transmitter (
    input [7:0] data,
    input start,
    output reg tx,
    output reg busy,
    input clk,
    input reset
    );
    parameter CLK_FREQ = 125000000;
    parameter BAUD_RATE = 115200;
    localparam BAUD_TICK = CLK_FREQ / BAUD_RATE;
    
    localparam p_idle  = 2'd0;
    localparam p_start = 2'd1;
    localparam p_data  = 2'd2;
    localparam p_stop  = 2'd3;
    
     reg [1:0] reg_state;
    reg [15:0] reg_baudcnt;
    reg [2:0] reg_bitcnt;
    reg [7:0] reg_shift;
    
    always @(posedge clk) begin
        if (reset)
            begin
            reg_state <= p_idle;
            tx <= 0;
            busy <= 0;
            reg_baudcnt <= 0;
            reg_bitcnt <= 0;
            end
        else begin
        case (reg_state)
            p_idle: begin
                tx <= 1'b1;
                busy <= 1'b0;
                reg_baudcnt <= 0;
                reg_bitcnt <= 0;
                if (start) begin
                    busy <= 1;
                    reg_shift <= data;
                    reg_state <= p_start;
                end
            end
            p_start: begin
                tx <= 0;
                if (reg_baudcnt == BAUD_TICK-1) begin
                    reg_baudcnt <= 0;
                    reg_state <= p_data;
                end
                else
                    reg_baudcnt <= reg_baudcnt + 1;
            end
            p_data: begin
                tx <= reg_shift[0];
                if (reg_baudcnt == BAUD_TICK-1) 
                begin
                  reg_baudcnt <= 0;
                  reg_shift <= {1'b0, reg_shift[7:1]};
                  if (reg_bitcnt == 3'd7) 
                  begin
                    reg_bitcnt <= 0;
                    reg_state <= p_stop;
                  end else 
                  begin
                    reg_bitcnt <= reg_bitcnt + 1;
                  end
                end else 
                begin
                  reg_baudcnt <= reg_baudcnt + 1;
                end
            end
            p_stop: begin
                tx <= 1;
                if (reg_baudcnt == BAUD_TICK-1)
                begin
                  reg_baudcnt <= 0;
                  reg_state <= p_idle;
                end
                else
                begin
                  reg_baudcnt <= reg_baudcnt + 1;
                end
            end
        endcase
        end
     end
endmodule
