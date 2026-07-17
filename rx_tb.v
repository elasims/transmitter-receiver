`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/16/2026 12:00:03 PM
// Design Name: 
// Module Name: rx_tb
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


module rx_tb(

    );
    
    reg clk;
    reg reset;
    reg [7:0] data;
    reg start;
    wire tx_line;
    wire tx_busy;
    wire [7:0] rx;
    wire datavld;
    wire fram_err;
    wire rx_busy;
    
    transmitter uut_tx(.clk(clk), .data(data), .start(start), .tx(tx_line), .busy(tx_busy), .reset(reset));
    receiver uut_rx (.clk(clk), .reset(reset), .rx(tx_line), .data(rx), .fram_err(fram_err), .busy(rx_busy), .datavld(datavld));
    
    always #10 clk = ~clk;
    
    always @(posedge clk) begin
        if(datavld) begin
            if (rx == data) begin
                $display ("pass", rx ,$time);
            end else begin
                $display ("fail", data, rx, $time);
            end
        end
        if (fram_err) begin
            $display ("framing error");
        end
    end
    
 initial begin                   
       clk   = 0;
       reset = 1;
       start = 0;
       data  = 8'h00;
       repeat (2) @(posedge clk);
       reset = 0;
    
       repeat (5) @(posedge clk);
       data  = 8'h4B;
       start = 1;
       @(posedge clk);
       start = 0;
    
       wait (tx_busy == 0);
       @(posedge clk);
       data  = 8'hA5;
       start = 1;
       @(posedge clk);
       start = 0;
    
       wait (tx_busy == 0);
       repeat (10000) @(posedge clk);
    
       $finish;
       end
endmodule
