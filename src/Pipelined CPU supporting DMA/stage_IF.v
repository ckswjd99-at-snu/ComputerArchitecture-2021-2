`timescale 1ns / 1ps

`include "opcodes.v"

module STAGE_IF(
        input clk,  // real clock
        input v_clk,
        input reset_n,
        
        // normal input & output
        output reg [`WORD_SIZE-1:0] instruction,
        output [`WORD_SIZE-1:0] PC_now,
        
        // control input
        input forcePC,
        input [`WORD_SIZE-1:0] forcePCdata,
        input [`WORD_SIZE-1:0] EX_PC,
        output reg i_readM,
        output reg i_writeM,
        output reg [`WORD_SIZE-1:0] i_address,
        input [4*`WORD_SIZE-1:0] i_data,
        
        output reg memoryWait,
        
        // DMA signal (for memory bus wait)
        input dma_using
    );
    
    reg [`WORD_SIZE-1:0] PC;
    assign PC_now = forcePC === 1 ? forcePCdata : PC;
    
    // CACHE
    wire [`WORD_SIZE-1:0] cache_read_data;
    wire cache_hit;
    wire [`LINE_SIZE-1:0] cache_write_data = i_data;
    reg cache_read;
    reg cache_write;
    CACHE cache(
        .clk(clk),
        .reset_n(reset_n),
        .addr(PC_now),
        .read_data(cache_read_data),
        .hit(cache_hit),
        .write_data(cache_write_data),
        .readC(cache_read),
        .writeC(cache_write),
        .writeCword(0)
    );
    
    // PC PREDICTOR
    wire [`WORD_SIZE-1:0] nextPC;
    PC_PREDICTOR pc_predictor(
        .clk(v_clk),
        .reset_n(reset_n),
        .PC(PC_now),
        .instruction(instruction),
        .nextPC(nextPC),
        .forcePC(forcePC),
        .forcePCdata(forcePCdata),
        .EX_PC(EX_PC)
    );
    
    // DATAPATH
    initial PC = `WORD_SIZE'b0;
    always @(posedge v_clk) begin
        if(!reset_n) PC = `WORD_SIZE'b0;
        else PC = nextPC; 
    end
    
    // CONTROL
    initial begin
        i_readM = 1;
        i_writeM = 0;
    end
    
    
    // MEMORY FETCH
    reg [2:0] memory_fetch_state;
    initial memoryWait = 0;
    initial memory_fetch_state = 0;
    
    always @(*) begin
        if(dma_using == 1) begin
            i_readM = 0;
            i_address = `WORD_SIZE'bz;
        end
        else begin
            i_readM = 1;
            if(memory_fetch_state == 0 && cache_hit == 0) begin
                memoryWait = 1;
                i_address = PC_now;
            end
            else if(memory_fetch_state == 0 && cache_hit == 1) begin
                memoryWait = 0;
                instruction = cache_read_data;
            end
        end
    end
    
    always @(posedge clk) begin
        if(reset_n == 1) begin
            if(memory_fetch_state == 0) begin   // cache checked
                if(cache_hit == 1) memory_fetch_state = 0;
                else begin
                    memory_fetch_state = 1;
                    cache_read = 0;
                end
            end
            else if(memory_fetch_state < 4) begin   // now waiting for memory...
                if(dma_using == 1) memory_fetch_state = memory_fetch_state;
                else memory_fetch_state = memory_fetch_state + 1;
            end
            else if(memory_fetch_state == 4) begin
                cache_write = 1;
                memory_fetch_state = memory_fetch_state + 1;
                instruction = i_data[`LINE_SIZE-1:`LINE_SIZE-`WORD_SIZE];
                memoryWait = 0;
            end
            else if(memory_fetch_state == 5) begin  // i_data is real instruction
                cache_write = 0;
                memory_fetch_state = 0;
                cache_read = 1;
            end
        end
        
    end
    
    
endmodule
