`timescale 100ps / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/09/11 09:24:42
// Design Name: 
// Module Name: ALU
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

`include "opcodes.v"

module ALU(
    input [15:0] A,
    input [15:0] B,
    input [5:0] OP,
    output [15:0] C
    );
    
    reg [15:0] result;
    assign C = result;
    
    always @(*)
    begin
        case(OP)
        `FUNC_ADD:
            result = A + B;
        `FUNC_SUB:
            result = A - B;
        `FUNC_AND:
            result = A & B;
        `FUNC_ORR:
            result = A | B;
        `FUNC_NOT:
            result = ~A;
        `FUNC_TCP:
            result = ~A+1;
        `FUNC_SHL:
            result = {A[14:0], 1'b0};
        `FUNC_SHR:
            result = {A[15], A[15:1]};
        endcase
    end
endmodule
