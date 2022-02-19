`timescale 1ns / 1ps

`include "opcodes.v"

module CONTROL_HAZARD_UNIT(
        input [`WORD_SIZE-1:0] ID_PC,
        input [`WORD_SIZE-1:0] realPC,
        
        output reg forcePC,
        output reg [`WORD_SIZE-1:0] forcePCdata
    );
    
    always @(*) begin
        forcePC = 0;
        if(realPC !== `WORD_SIZE'bz && ID_PC != realPC) begin
            forcePC = 1;
            forcePCdata = realPC;
        end
    end
    
endmodule
