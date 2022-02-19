`timescale 1ns / 1ps

`include "opcodes.v"

module STAGE_ID(
        input clk,
        input reset_n,
        
        // normal input & output
        input [1:0] addr1,
        input [1:0] addr2,
        input [1:0] addr3,
        output [`WORD_SIZE-1:0] data1,
        output [`WORD_SIZE-1:0] data2,
        input [`WORD_SIZE-1:0] data3,
        
        // control input & output
        input rfWrite
    );
    
    RF register_file(
        .write(rfWrite),
        .clk(clk),
        .reset_n(reset_n),
        .addr1(addr1),
        .addr2(addr2),
        .addr3(addr3),
        .data1(data1),
        .data2(data2),
        .data3(data3)
    );
    
endmodule
