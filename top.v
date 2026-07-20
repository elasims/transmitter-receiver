`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/10/2026 03:42:32 PM
// Design Name: 
// Module Name: top
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


module top(
    input clk,
    input reset,
    input rx,
    output tx,
    output [3:0] led
    );
    localparam CLK_FREQ = 125000000;
    localparam BAUD_RATE = 115200;
    
    wire tx_busy;
    wire rx_busy;
    wire datavld;
    wire tx_line;
    wire fram_err;
    wire [7:0] rx_data;
    reg [3:0] counter;
    
    assign tx = tx_line;
    assign led = counter;
    
transmitter uut_tx(
    .clk(clk), 
    .data(rx_data), 
    .start(datavld && !tx_busy), 
    .tx(tx_line), 
    .busy(tx_busy), 
    .reset(reset)
);
receiver uut_rx (
    .clk(clk), 
    .reset(reset), 
    .rx(rx), 
    .data(rx_data),
    .fram_err(fram_err), 
    .busy(rx_busy), 
    .datavld(datavld)
);
always @(posedge clk) begin
  if (reset) begin
    counter <= 4'd0;
  end
  else begin
    if (datavld && !tx_busy) begin
      counter <= counter + 1;
    end
  end
end

endmodule
