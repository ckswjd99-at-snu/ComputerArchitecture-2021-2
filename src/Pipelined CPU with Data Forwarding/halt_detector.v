`timescale 1ns / 1ps

`include "opcodes.v"

module HALT_DETECTOR(
        input clk,
        input reset_n,
        
        input [`WORD_SIZE-1:0] instruction,
        output reg is_halted
    );
    initial is_halted = 0;
    always @(reset_n) if(reset_n == 0) is_halted = 0;
    
    always @(posedge clk) begin
        if(reset_n != 0) begin
            if(instruction[15:12] === `OPCODE_RRR && instruction[5:0] === `FUNC_HLT) begin
                is_halted = 1;
            end
        end
    end
    
endmodule
