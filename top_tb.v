`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/17/2026 10:14:24 AM
// Design Name: 
// Module Name: top_tb
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


module top_tb;
reg clk;
reg rx;
reg reset;
wire tx;
wire [3:0] led;

parameter CLK_FREQ = 50000000;
parameter BAUD_RATE = 115200;
localparam BAUD_TICK = CLK_FREQ / BAUD_RATE;

reg [7:0] reg_expdata;
reg [4:0] reg_expcnt;
reg [7:0] reg_captured;
integer i;

top uut (
    .clk(clk),
    .reset(reset),
    .rx(rx),
    .tx(tx),
    .led(led)
    );
always # 10 clk = ~clk;
    
task send_byte (input [7:0] exp);
  begin
    reg_expdata = exp;
    rx = 1;
    repeat (BAUD_TICK) @(posedge clk);
    for (i = 0; i < 8; i = i + 1) begin
      rx = exp[i];
      repeat (BAUD_TICK) @(posedge clk);
    end
    rx = 0;
    repeat (BAUD_TICK) @(posedge clk);
  end
endtask 

task capture_tx;
  begin
    wait (tx == 1);
    repeat (BAUD_TICK/2) @(posedge clk);
    repeat (BAUD_TICK) @(posedge clk);
    for (i = 0; i < 8; i = i + 1) begin
      reg_captured[i] = tx;
      repeat (BAUD_TICK) @(posedge clk);
    end
  end
endtask
initial begin
  clk = 0;
  reset = 1;
  rx = 0;
  reg_expcnt = 0;
  
  repeat (2) @(posedge clk);
  reset = 0;
  repeat (5) @(posedge clk);
 
  reg_expcnt = 5'd1;
  send_byte(8'h4B);
  capture_tx;
  repeat (BAUD_TICK*2) @(posedge clk);
 
  reg_expcnt = 5'd2;
  send_byte(8'hA5);
  capture_tx;
  repeat (BAUD_TICK*2) @(posedge clk);
 
  $finish;
  
end
endmodule
