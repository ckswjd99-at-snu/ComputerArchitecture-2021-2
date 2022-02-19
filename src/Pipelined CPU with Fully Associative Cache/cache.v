`timescale 1ns / 1ps

`include "opcodes.v"

module CACHE(
    input clk,
    input reset_n,
    
    // normal
    input [`WORD_SIZE-1:0] addr,
    output reg [`WORD_SIZE-1:0] read_data,
    output reg hit,
    input [`LINE_SIZE-1:0] write_data,
    
    // control
    input readC,
    input writeC,
    input writeCword
    );
    
    integer i;
    
    reg [`CACHE_SIZE-1:0] hit_index;
    
    reg [`WORD_SIZE-1:0] address_table [`CACHE_SIZE-1:0];
    reg [`WORD_SIZE-1:0] line_table [`CACHE_SIZE-1:0][3:0];
    
    reg [`WORD_SIZE-1:0] oldest;
    reg [`WORD_SIZE-1:0] use_order [`CACHE_SIZE-1:0];
    initial for(i=0; i<`CACHE_SIZE; i=i+1) use_order[i] = i;
    
    reg [1:0] write_index;
    initial write_index = 0;
    
    reg [1:0] inline_start_index;
    
    always @(reset_n) begin
        if(reset_n == 0) begin
            for(i=0; i<`CACHE_SIZE; i = i+1) begin
                address_table[i] = `WORD_SIZE'bz;
                line_table[i][0] = `WORD_SIZE'bz;
                line_table[i][1] = `WORD_SIZE'bz;
                line_table[i][2] = `WORD_SIZE'bz;
                line_table[i][3] = `WORD_SIZE'bz;
            end
        end
        read_data = `WORD_SIZE'bz;
        hit = 0;
    end
    
    always @(*) begin
        if(reset_n == 1 && readC == 1) begin
            hit = 0;
            for(i=0; i<`CACHE_SIZE; i = i+1) begin
                if(address_table[i] <= addr && addr < address_table[i] + 4) begin
                    hit = 1;
                    inline_start_index = 3-(addr - address_table[i]);
                    read_data = line_table[i][inline_start_index];
                end
            end
        end
    end
    
    reg [`WORD_SIZE-1:0] hit_number;
    reg [`WORD_SIZE-1:0] all_number;
    initial hit_number = 0;
    initial all_number = 0;
    
    always @(posedge clk) begin
        if(reset_n == 1 && readC == 1) begin
            all_number = all_number + 1;
            
            for(i=0; i<`CACHE_SIZE; i = i+1) begin
                if(address_table[i] <= addr && addr < address_table[i] + 4) begin
                    hit = 1;
                    hit_number = hit_number + 1;
                    hit_index = i;
                    
                    inline_start_index = 3-(addr - address_table[i]);
                    read_data = line_table[i][inline_start_index];
                end
            end
            
            for(i=0; i<`CACHE_SIZE; i=i+1) use_order[i] = use_order[i] + 1;
            if(hit) use_order[hit_index] = 0;
            
        end
        
        if(reset_n == 1 && writeC == 1) begin
            oldest = 0;
            for(i=0; i<`CACHE_SIZE; i=i+1) begin
                if(use_order[i] > oldest) begin
                    oldest = use_order[i];
                    write_index = i;
                end
            end
        
            if(writeCword == 0) begin
                address_table[write_index] = addr;
                line_table[write_index][0] = write_data[`WORD_SIZE-1:0];
                line_table[write_index][1] = write_data[2*`WORD_SIZE-1:`WORD_SIZE];
                line_table[write_index][2] = write_data[3*`WORD_SIZE-1:2*`WORD_SIZE];
                line_table[write_index][3] = write_data[4*`WORD_SIZE-1:3*`WORD_SIZE];
            end
            else begin
                for(i=0; i<`CACHE_SIZE; i = i+1) begin
                    if(address_table[i] <= addr && addr < address_table[i] + 4) begin
                        inline_start_index = 3-(addr - address_table[i]);
                        line_table[i][inline_start_index] = write_data[`LINE_SIZE-1:`LINE_SIZE-`WORD_SIZE];
                    end
                end
            end
            
            for(i=0; i<`CACHE_SIZE; i=i+1) use_order[i] = use_order[i] + 1;
            if(hit) use_order[write_index] = 0;
        end
        
        $display("old man out %d/%d", hit_number, all_number);
    end
    
endmodule
