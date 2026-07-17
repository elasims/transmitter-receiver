`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/14/2026 04:39:29 PM
// Design Name: 
// Module Name: tx_tb
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

module tx_tb(

);

reg clk;
reg reset;
reg [7:0] data;
reg start;
wire tx;
wire busy;

transmitter uut(.clk(clk), .data(data), .start(start), .tx(tx), .busy(busy), .reset(reset));

    
    
always #10 clk = ~clk;

initial begin
    clk = 0;
    start = 0;
    data = 8'h00;
    reset = 1;
    
    repeat (2) @(posedge clk);
    reset = 0;                  
        
    repeat (5) @ (posedge clk);
    data = 8'h4B;
    start = 1;
    
    @(posedge clk);
    start = 0;
    wait (busy == 0);
    @(posedge clk);          
    data = 8'hA5;
    start = 1;
    @(posedge clk);
    start = 0;
    repeat (10000) @(posedge clk);       
    $finish;
end
endmodule
