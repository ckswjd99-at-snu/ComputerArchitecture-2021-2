`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/09/14 08:38:36
// Design Name: 
// Module Name: RF
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

// internal forward required

module RF(
    input write,
    input clk,
    input reset_n,
    input [1:0] addr1,
    input [1:0] addr2,
    input [1:0] addr3,
    output reg [15:0] data1,
    output reg [15:0] data2,
    input [15:0] data3
    );
    
    integer i;

    reg [15:0] memory [3:0];
    
    initial begin
        for(i=0; i<4; i=i+1) begin
            memory[i] = 16'b0;
        end
    end
    
    always @(reset_n) begin
        if(reset_n == 0) begin
            for(i=0; i<4; i=i+1) begin
                memory[i] = 0;
            end
        end
    end
    
    always @(*) begin
        data1 = memory[addr1];
        data2 = memory[addr2];
    end
    
    always @(posedge clk) begin
        if(write == 1) begin
            memory[addr3] = data3;
        end
    end
endmodule

