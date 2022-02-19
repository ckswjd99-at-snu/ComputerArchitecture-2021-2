`timescale 1ns / 1ps

`include "opcodes.v"

`define WAIT_DMA_BEGIN 0
`define WAIT_BUS_REQUEST_START 1
`define WAIT_BUS_REQUEST_END 2
`define WAIT_DMA_END 3

`define DMA_ADDRESS `WORD_SIZE'h1f4

module DMA_MANAGER(
        input clk,
        input reset_n,
        input if_memoryWait,
        input mem_memoryWait,
        input dma_begin,
        output reg [`WORD_SIZE-1:0] dma_command,
        input bus_request,
        output reg dma_using,
        output reg bus_grant,
        input dma_end
    );
    
    reg [1:0] state;
    initial dma_command = `WORD_SIZE'bz;
    
    always @(posedge clk) begin
        if(reset_n == 0) begin
            state = `WAIT_DMA_BEGIN;
            dma_command = `WORD_SIZE'bz;
            dma_using = 0;
            bus_grant = 0;
        end
        else begin
            case(state)
                `WAIT_DMA_BEGIN: begin
                    if(dma_begin == 1) begin
                        state = `WAIT_BUS_REQUEST_START;
                        dma_command = `DMA_ADDRESS;
                    end
                end
                `WAIT_BUS_REQUEST_START: begin
                    if(bus_request == 1 && if_memoryWait == 0 && mem_memoryWait == 0) begin
                        state = `WAIT_BUS_REQUEST_END;
                        dma_command = `WORD_SIZE'bz;
                        dma_using = 1;
                    end
                end
                `WAIT_BUS_REQUEST_END: begin
                    bus_grant = 1;
                    if(bus_request == 0) begin
                        state = `WAIT_DMA_END;
                        bus_grant = 0;
                    end
                end
                `WAIT_DMA_END: begin
                    if(dma_end) begin
                        state = `WAIT_DMA_BEGIN;
                        dma_command = `WORD_SIZE'bz;
                        dma_using = 0;
                        bus_grant = 0;
                    end
                end
            endcase
        end
    end
endmodule
