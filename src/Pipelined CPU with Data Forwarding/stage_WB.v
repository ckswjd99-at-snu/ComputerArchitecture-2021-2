`timescale 1ns / 1ps

`include "opcodes.v"

module STAGE_WB(
        input clk,
        input reset_n,
        
        // normal input & output
        input [`WORD_SIZE-1:0] instruction,
        input [`WORD_SIZE-1:0] m_data,
        input [`WORD_SIZE-1:0] aluOut,
        output [1:0] addr3,
        output [`WORD_SIZE-1:0] data3,
        
        // control input & output
        output reg rfWrite,
        
        output [`WORD_SIZE-1:0] output_port
    );
    
    // parse instruction
    wire [3:0] inst_opcode = instruction[15:12];
    wire [5:0] inst_func = instruction[5:0];
    wire [1:0] inst_rt = instruction[9:8];
    wire [1:0] inst_rd = instruction[7:6];
    
    reg [1:0] rfWriteAddr;
    reg rfWriteSrc;
    
    assign addr3 = rfWriteAddr == 0 ? inst_rt : rfWriteAddr == 1? inst_rd : 2;
    assign data3 = rfWriteSrc == 0 ? m_data : aluOut;
    assign output_port = (inst_opcode == `OPCODE_RRR && inst_func == `FUNC_WWD) ? aluOut : `WORD_SIZE'bz;
    
    always @(*) begin
        case(inst_opcode)
            `OPCODE_ADI:
            begin
                rfWrite = 1;
                rfWriteAddr = 0;
                rfWriteSrc = 1;
            end
            `OPCODE_ORI:
            begin
                rfWrite = 1;
                rfWriteAddr = 0;
                rfWriteSrc = 1;
            end
            `OPCODE_LHI:
            begin
                rfWrite = 1;
                rfWriteAddr = 0;
                rfWriteSrc = 1;
            end
            `OPCODE_LWD:
            begin
                rfWrite = 1;
                rfWriteAddr = 0;
                rfWriteSrc = 0;
            end
            `OPCODE_SWD:
            begin
                rfWrite = 0;
            end
            `OPCODE_BNE:
            begin
                rfWrite = 0;
            end
            `OPCODE_BEQ:
            begin
                rfWrite = 0;
            end
            `OPCODE_BGZ:
            begin
                rfWrite = 0;
            end
            `OPCODE_BLZ:
            begin
                rfWrite = 0;
            end
            `OPCODE_JMP:
            begin
                rfWrite = 0;
            end
            `OPCODE_JAL:
            begin
                rfWrite = 1;
                rfWriteAddr = 2;
                rfWriteSrc = 1;
            end
            `OPCODE_RRR:
            begin
                if(inst_func == `FUNC_WWD) begin
                    rfWrite = 0;
                end
                else if(inst_func == `FUNC_JPR) begin
                    rfWrite = 0;
                end
                else if(inst_func == `FUNC_JRL) begin
                    rfWrite = 1;
                    rfWriteAddr = 2;
                    rfWriteSrc = 1;
                end
                else if(inst_func == `FUNC_HLT) begin
                    rfWrite = 0;
                end
                else begin
                    rfWrite = 1;
                    rfWriteAddr = 1;
                    rfWriteSrc = 1;
                end
            end
            `OPCODE_NOP:
            begin
                rfWrite = 0;
            end
        endcase
    end
    
    
    
endmodule
