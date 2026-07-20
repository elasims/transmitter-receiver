`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/10/2026 03:42:32 PM
// Design Name: 
// Module Name: rx
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


module receiver(
    input rx,
    output reg [7:0] data,
    output reg datavld,
    output reg fram_err,
    input clk,
    input reset,
    output reg busy
    );
    parameter CLK_FREQ = 125000000;
    parameter BAUD_RATE = 115200;
    localparam BAUD_TICK = CLK_FREQ / BAUD_RATE;
    localparam HALF_TICK = BAUD_TICK / 2;
    parameter p_idle = 3'd0, p_start = 3'd1,  p_data = 3'd2, p_stop = 3'd3, p_wait = 3'd4;
    
    reg [2:0] reg_state;
    reg [15:0] reg_baudcnt;
    reg [2:0] reg_bitcnt;
    reg [7:0] reg_shift;
    
    wire bauddone = reg_baudcnt == BAUD_TICK -1;
    wire halfdone = reg_baudcnt == HALF_TICK -1;
    
    always @(posedge clk) begin
        if (reset)
            begin
            reg_state <= p_idle;
            reg_baudcnt <= 0;
            reg_bitcnt <= 0;
            reg_shift <= 0;
            busy <= 0;
            fram_err <= 0;
            data <= 0;
            end
        else 
            begin
            datavld <= 0;
            fram_err <= 0;
            case (reg_state)
                p_idle : begin
                    busy <= 0;
                    reg_baudcnt <= 0;
                    reg_bitcnt <= 0;
                    reg_state <= (~rx) ? p_start : p_idle;

                end
                p_start: begin
                    busy <= 1;
                    reg_state <= p_start;
                    reg_baudcnt <= (halfdone) ? 0 : reg_baudcnt + 1;
                    if (halfdone) begin
                      reg_state <= p_data;
                      reg_baudcnt <= 0;
                    end else begin                      
                      reg_baudcnt <= reg_baudcnt + 1;                      
                    end
                end
                p_data: begin
                    busy <= 1;
                    reg_state <= p_data;
                    if (bauddone) begin
                        reg_baudcnt <= 0;
                        reg_bitcnt <= reg_bitcnt + 1;
                        reg_shift <= {rx, reg_shift[7:1]};
                        reg_state <= (reg_bitcnt == 4'd7) ? p_stop : p_data;
                    end
                    else begin
                        reg_baudcnt <= reg_baudcnt + 1;
                    end

                end
                p_stop: begin
                    if (bauddone) begin
                        reg_baudcnt <= 0;
                        if (rx) begin
                            data <= reg_shift;
                            datavld <= 1;
                        end
                        else begin
                            fram_err <=1;
                        end
                    end
                    else begin
                        reg_baudcnt <= reg_baudcnt + 1;
                    end
                if (bauddone) begin
                    reg_state <= (~rx) ? p_wait : p_idle;
                end else begin
                    reg_state <= p_stop;
                end
                end
                p_wait: begin
                    busy <= 1;
                    reg_state <= rx ? p_idle : p_wait;
                end
                default: reg_state <= p_idle;
            endcase
        end
     end 
endmodule
