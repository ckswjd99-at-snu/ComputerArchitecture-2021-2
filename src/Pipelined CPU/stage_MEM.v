`timescale 1ns / 1ps

`include "opcodes.v"

module STAGE_MEM(
        input clk,
        input reset_n,
        
        // normal input & output
        input [`WORD_SIZE-1:0] instruction,
        input [`WORD_SIZE-1:0] addr,
        input [`WORD_SIZE-1:0] write_data,
        output [`WORD_SIZE-1:0] read_data,
        
        // real communication with memory
        output reg d_readM, 
        output reg d_writeM, 
        output [`WORD_SIZE-1:0] d_address, 
        inout [`WORD_SIZE-1:0] d_data
    );
    
    // parse instruction
    wire [3:0] inst_opcode = instruction[15:12];
    assign d_address = addr;
    assign d_data = inst_opcode == `OPCODE_SWD ? write_data : `WORD_SIZE'bz;
    assign read_data = d_data;
    
    always @(posedge clk) begin
        d_readM = 0;
        d_writeM = 0;
        if(inst_opcode == `OPCODE_LWD) begin
            d_readM = 1;
        end
        else if(inst_opcode == `OPCODE_SWD) begin
            d_writeM = 1;
        end
    end
    
    always @(*) begin
        d_readM = 0;
        d_writeM = 0;
        if(inst_opcode == `OPCODE_LWD) begin
            d_readM = 1;
        end
        else if(inst_opcode == `OPCODE_SWD) begin
            d_writeM = 1;
        end
    end
    
endmodule
