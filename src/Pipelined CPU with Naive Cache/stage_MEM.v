`timescale 1ns / 1ps

`include "opcodes.v"

module STAGE_MEM(
        input clk,
        input v_clk,
        input reset_n,
        
        // normal input & output
        input [`WORD_SIZE-1:0] instruction,
        input [`WORD_SIZE-1:0] addr,
        input [`WORD_SIZE-1:0] write_data,
        output reg [`WORD_SIZE-1:0] read_data,
        
        // real communication with memory
        output reg d_readM, 
        output reg d_writeM, 
        output [`WORD_SIZE-1:0] d_address, 
        inout [`LINE_SIZE-1:0] d_data,
        
        output reg memoryWait
    );
    integer i;
    
    // parse instruction
    wire [3:0] inst_opcode = instruction[15:12];
    assign d_address = addr;
    assign d_data = inst_opcode == `OPCODE_SWD ? {write_data, 48'b0} : `LINE_SIZE'bz;
    
    reg isWrite;
    reg isRead;
    always @(*) begin
        if(inst_opcode == `OPCODE_SWD) begin
            isWrite = 1;
            isRead = 0;
        end
        else if(inst_opcode == `OPCODE_LWD) begin
            isWrite = 0;
            isRead = 1;
        end
        else begin
            isWrite = 0;
            isRead = 0;
        end
    end
    
    // CACHE
    wire [`WORD_SIZE-1:0] cache_read_data;
    wire cache_hit;
    wire [`LINE_SIZE-1:0] cache_write_data = d_data;
    reg cache_read;
    reg cache_write;
    reg cache_writeWord;
    initial cache_writeWord = 0;
    CACHE cache(
        .clk(clk),
        .reset_n(reset_n),
        .addr(addr),
        .read_data(cache_read_data),
        .hit(cache_hit),
        .write_data(cache_write_data),
        .readC(cache_read),
        .writeC(cache_write),
        .writeCword(cache_writeWord)
    );
    
    // MEMORY FETCH
    reg [2:0] memory_fetch_state;
    initial memoryWait = 0;
    initial memory_fetch_state = 0;
    
    always @(*) begin
        if(isRead) begin
            if(memory_fetch_state == 0) begin
                cache_read = 1;
            end
            
            if(memory_fetch_state == 0 &&  cache_hit == 0) begin
                memoryWait = 1;
            end
            else if(memory_fetch_state == 0 && cache_hit == 1) begin
                memoryWait = 0;
                read_data = cache_read_data;
            end
        end
        else if(isWrite) begin
            cache_read = 1;
            if(memory_fetch_state == 0) memoryWait = 1;
        end
        else memoryWait = 0;
    end
    
    always @(posedge clk) begin
        if(reset_n == 1) begin
            if(isRead) begin
                if(memory_fetch_state == 0) begin   // cache checked
                    if(cache_hit == 1) memory_fetch_state = 0;
                    else begin
                        memory_fetch_state = 1;
                        cache_read = 0;
                        d_readM = 1;
                    end
                end
                else if(memory_fetch_state < 4) begin   // now waiting for memory...
                    memory_fetch_state = memory_fetch_state + 1;
                    cache_write = 0;
                end
                else if(memory_fetch_state == 4) begin
                    cache_write = 1;
                    memory_fetch_state = memory_fetch_state + 1;
                    read_data = d_data[`LINE_SIZE-1:`LINE_SIZE-`WORD_SIZE];
                    memoryWait = 0;
                end
                else if(memory_fetch_state == 5) begin  // i_data is real instruction
                    cache_write = 0;
                    memory_fetch_state = 0;
                    cache_read = 1;
                    d_readM = 0;
                end
            end
            if(isWrite) begin
                if(memory_fetch_state == 0) begin
                    d_writeM = 1;
                    memory_fetch_state = memory_fetch_state + 1;
                end
                else if(memory_fetch_state < 4) memory_fetch_state = memory_fetch_state + 1;
                else if(memory_fetch_state == 4) begin
                    memory_fetch_state = memory_fetch_state + 1;
                    if(cache_hit) begin
                        cache_write = 1;
                        cache_writeWord = 1;
                    end 
                    cache_read = 0;
                    memoryWait = 0;
                end
                else if(memory_fetch_state == 5) begin
                    cache_write = 0;
                    cache_writeWord = 0;
                    memory_fetch_state = 0;
                    d_writeM = 0;
                end
            end
        end
    end
    
endmodule
