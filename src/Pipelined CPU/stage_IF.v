`timescale 1ns / 1ps

`include "opcodes.v"

module STAGE_IF(
        input clk,
        input reset_n,
        
        // normal input & output
        input [`WORD_SIZE-1:0] instruction,
        output [`WORD_SIZE-1:0] PC_now,
        output [`WORD_SIZE-1:0] nextPC,
        
        // control input
        input forcePC,
        input [`WORD_SIZE-1:0] forcePCdata,
        input data_hazard,
        output reg i_readM,
        output reg i_writeM
    );
    
    reg [`WORD_SIZE-1:0] PC;
    assign PC_now = forcePC === 1 ? forcePCdata : PC;
    
    // PC PREDICTOR
    PC_PREDICTOR pc_predictor(
        .clk(clk),
        .reset_n(reset_n),
        .PC(PC_now),
        .instruction(instruction),
        .nextPC(nextPC),
        .forcePC(forcePC),
        .forcePCdata(forcePCdata)
    );
    
    // DATAPATH
    initial PC = `WORD_SIZE'b0;
    always @(posedge clk) begin
        if(!reset_n) PC = `WORD_SIZE'b0;
        else if(data_hazard === 1) PC = PC;
        else PC = nextPC; 
    end
    
    // CONTROL
    initial begin
        i_readM = 1;
        i_writeM = 0;
    end
    
    
endmodule
