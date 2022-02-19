`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/13 00:20:50
// Design Name: 
// Module Name: stage_EX
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


module STAGE_EX(
        input clk,
        input reset_n,
        
        // normal input & output
        input [`WORD_SIZE-1:0] PC,
        input [`WORD_SIZE-1:0] instruction,
        input [`WORD_SIZE-1:0] A,
        input [`WORD_SIZE-1:0] B,
        output [`WORD_SIZE-1:0] aluOut,
        
        // control input & output
        input aluSrcA,
        input aluSrcB,
        input [5:0] func
    );
    
    wire [`WORD_SIZE-1:0] offset_ze = {8'b0, instruction[7:0]};
    
    wire [`WORD_SIZE-1:0] aluA = aluSrcA == 1'b0 ? PC : A;
    wire [`WORD_SIZE-1:0] aluB = aluSrcB == 1'b0 ? B : offset_ze ;
    
    ALU alu(
        .A(aluA),
        .B(aluB),
        .C(aluOut),
        .OP(func)
    );
    
    
    
endmodule
