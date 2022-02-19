`timescale 1ns / 1ps

`include "opcodes.v"

module PC_PREDICTOR(
        input clk,
        input reset_n,
        
        // normal input & output
        input [`WORD_SIZE-1:0] PC,
        input [`WORD_SIZE-1:0] instruction,
        output reg [`WORD_SIZE-1:0] nextPC,
        
        // control input & output
        input forcePC,
        input [`WORD_SIZE-1:0] forcePCdata
    );
    
    // This unit usually works like combination logic.
    // At posedge clk, it updates BTB table.
    
    // parse instruction
    wire [3:0] opcode = instruction[15:12];
    wire [`WORD_SIZE-1:0] offset = {{8{instruction[7]}}, instruction[7:0]};
    
    reg reset_n_switch;
    initial reset_n_switch = 1;
    
    
    always @(reset_n) begin
        if(reset_n == 0) begin
            reset_n_switch = 0;
        end
    end
    always @(posedge clk) begin
        if(reset_n != 0) reset_n_switch = 1;
        

    end
    
    always @(*) begin
    
        if(reset_n == 0) begin
            nextPC = `WORD_SIZE'b0;
            reset_n_switch = 0;
        end
        else begin
            if(opcode == `OPCODE_JMP || opcode == `OPCODE_JAL) begin
                nextPC = {PC[15:12], instruction[11:0]};
            end
            else if(opcode == `OPCODE_BNE || opcode == `OPCODE_BEQ || opcode == `OPCODE_BGZ || opcode == `OPCODE_BLZ) begin
                nextPC = PC + 1 + offset;
            end
            else begin
                nextPC = PC + 1;
            end
        end
        
    end
    
    // if I am alright, branch prediction logic will be here...
    
endmodule
