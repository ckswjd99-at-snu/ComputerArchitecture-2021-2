`timescale 1ns / 1ps

`include "opcodes.v"

module FORWARD_UNIT(
        input [`WORD_SIZE-1:0] A,
        input [`WORD_SIZE-1:0] B,
        input [`WORD_SIZE-1:0] Instruction,
        input [`WORD_SIZE-1:0] MEM_Instruction,
        input [`WORD_SIZE-1:0] MEM_aluOut,
        input [`WORD_SIZE-1:0] MEM_memoryReadData,
        input [`WORD_SIZE-1:0] WB_Instruction,
        input [`WORD_SIZE-1:0] WB_aluOut,
        input [`WORD_SIZE-1:0] WB_memoryReadData,
        output reg [`WORD_SIZE-1:0] realA,
        output reg [`WORD_SIZE-1:0] realB,
        output reg data_hazard
    );
    
    wire [1:0] rs = Instruction[11:10];
    wire [1:0] rt = Instruction[9:8];
    
    reg MEM_wb;
    reg [1:0] MEM_target;
    reg [`WORD_SIZE-1:0] MEM_data;
    
    wire [3:0] MEM_opcode = MEM_Instruction[15:12];
    wire [5:0] MEM_func = MEM_Instruction[5:0];
    
    reg WB_wb;
    reg [1:0] WB_target;
    reg [`WORD_SIZE-1:0] WB_data;
    
    wire [3:0] WB_opcode = WB_Instruction[15:12];
    wire [5:0] WB_func = WB_Instruction[5:0];
    
    always @(*) begin
        // MEM writeback?
        if(MEM_opcode === `OPCODE_RRR) begin
            if(MEM_func === `FUNC_WWD || MEM_func === `FUNC_JPR || MEM_func === `FUNC_HLT) begin
                MEM_wb = 0;
            end
            else if(MEM_func === `FUNC_JRL) begin
                MEM_wb = 1;
                MEM_target = 2'b10;
                MEM_data = MEM_aluOut;
            end
            else begin
                MEM_wb = 1;
                MEM_target = MEM_Instruction[7:6];
                MEM_data = MEM_aluOut;
            end
        end
        else if(MEM_opcode === `OPCODE_ADI || MEM_opcode === `OPCODE_ORI || MEM_opcode === `OPCODE_LHI) begin
            MEM_wb = 1;
            MEM_target = MEM_Instruction[9:8];
            MEM_data = MEM_aluOut;
        end
        else if(MEM_opcode === `OPCODE_LWD) begin
            MEM_wb = 1;
            MEM_target = MEM_Instruction[9:8];
            MEM_data = MEM_memoryReadData;
        end
        else if(MEM_opcode === `OPCODE_JAL) begin
            MEM_wb = 1;
            MEM_target = 2'b10;
            MEM_data = MEM_aluOut;
        end
        else if(MEM_opcode === `OPCODE_NOP) begin
            MEM_wb = 0;
        end
        
        // WB writeback?
        if(WB_opcode === `OPCODE_RRR) begin
            if(WB_func === `FUNC_WWD || WB_func === `FUNC_JPR || WB_func === `FUNC_HLT) begin
                WB_wb = 0;
            end
            else if(WB_func === `FUNC_JRL) begin
                WB_wb = 1;
                WB_target = 2'b10;
                WB_data = WB_aluOut;
            end
            else begin
                WB_wb = 1;
                WB_target = WB_Instruction[7:6];
                WB_data = WB_aluOut;
            end
        end
        else if(WB_opcode === `OPCODE_ADI || WB_opcode === `OPCODE_ORI || WB_opcode === `OPCODE_LHI) begin
            WB_wb = 1;
            WB_target = WB_Instruction[9:8];
            WB_data = WB_aluOut;
        end
        else if(WB_opcode === `OPCODE_LWD) begin
            WB_wb = 1;
            WB_target = WB_Instruction[9:8];
            WB_data = WB_memoryReadData;
        end
        else if(WB_opcode === `OPCODE_JAL) begin
            WB_wb = 1;
            WB_target = 2'b10;
            WB_data = WB_aluOut;
        end
        else if(WB_opcode === `OPCODE_NOP) begin
            WB_wb = 0;
        end
        
        realA = A;
        if(rs === MEM_target && MEM_wb === 1) realA = MEM_data;
        else if(rs === WB_target && WB_wb === 1) realA = WB_data;
        
        realB = B;
        if(rt === MEM_target && MEM_wb === 1) realB = MEM_data;
        else if(rt === WB_target && WB_wb === 1) realB = WB_data;
        
        data_hazard = MEM_wb === 1 | WB_wb === 1 ? 1 : 0;
    end
    
    
endmodule
