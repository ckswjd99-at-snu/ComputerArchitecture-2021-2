`timescale 1ns/1ns	

`define WORD_SIZE 16
/*************************************************
* DMA module (DMA.v)
* input: clock (CLK), bus request (BR) signal, 
*        data from the device (edata), and DMA command (cmd)
* output: bus grant (BG) signal 
*         WRITE signal
*         memory address (addr) to be written by the device, 
*         offset device offset (0 - 2)
*         data that will be written to the memory
*         interrupt to notify DMA is end
* You should NOT change the name of the I/O ports and the module name
* You can (or may have to) change the type and length of I/O ports 
* (e.g., wire -> reg) if you want 
* Do not add more ports! 
*************************************************/

`include "opcodes.v"

`define WAIT_DMA_COMMAND 0
`define WAIT_BUS_GRANT_START 1
`define WRITE_MEMORY 2
`define WAIT_BUS_GRANT_END 3

module DMA (
    input CLK,
    input BG,
    input [4 * `WORD_SIZE - 1 : 0] edata,
    input [`WORD_SIZE-1:0] cmd,
    output reg BR,
    output reg WRITE,
    output reg [`WORD_SIZE - 1 : 0] addr, 
    output reg [4 * `WORD_SIZE - 1 : 0] data,
    output reg [1:0] offset,
    output reg interrupt
);

    /* Implement your own logic */
    
    // NOTATION
    wire clk = CLK;
    
    reg [1:0] state;
    reg [`WORD_SIZE-1:0] command_addr;
    reg [1:0] offset_count;
    reg [2:0] data_count;
    
    initial begin
        state = `WAIT_DMA_COMMAND;
        command_addr = `WORD_SIZE'bz;
        BR = 0;
        WRITE = 0;
        addr = `WORD_SIZE'bz;
        data = 4*`WORD_SIZE-1'bz;
        offset = 2'bz;
        interrupt = 0;
    end
    
    always @(*) begin
        if(BG) data = edata;
        offset = offset_count;
        addr = command_addr + offset_count * 4;
    end
    
    always @(posedge clk) begin
        if(state == `WAIT_DMA_COMMAND) begin
            interrupt = 0;
            if(cmd !== `WORD_SIZE'bz) begin
                command_addr = cmd;
                state = `WAIT_BUS_GRANT_START;
                BR = 1;
            end
        end
        else if(state == `WAIT_BUS_GRANT_START) begin
            if(BG == 1) begin
                state = `WRITE_MEMORY;
                offset_count = 0;
                data_count = 0;
            end
        end
        else if(state == `WRITE_MEMORY) begin
            if(offset_count == 3) begin
                offset_count = 2'bz;
                state = `WAIT_BUS_GRANT_END;
                BR = 0;
            end
            data_count = data_count + 1;
            if(data_count == 4) begin
                offset_count = offset_count + 1;
                data_count = 0;
            end
        end
        else if(state == `WAIT_BUS_GRANT_END) begin
            if(BG == 0) begin
                state = `WAIT_DMA_COMMAND;
                interrupt = 1;
            end
        end
    end

endmodule


