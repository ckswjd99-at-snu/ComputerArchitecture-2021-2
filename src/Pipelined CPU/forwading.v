`timescale 1ns / 1ps

`include "opcodes.v"

module FORWARD_UNIT(
        input [`WORD_SIZE-1:0] Instruction,
        input [`WORD_SIZE-1:0] EX_Instruction,
        input [`WORD_SIZE-1:0] MEM_Instruction,
        input [`WORD_SIZE-1:0] WB_Instruction,
        output reg data_hazard
    );
    
    wire [1:0] rs = Instruction[11:10];
    wire [1:0] rt = Instruction[9:8];
    
    reg EX_wb;
    reg [1:0] EX_target;
    
    wire [3:0] EX_opcode = EX_Instruction[15:12];
    wire [5:0] EX_func = EX_Instruction[5:0];
    
    reg MEM_wb;
    reg [1:0] MEM_target;
    
    wire [3:0] MEM_opcode = MEM_Instruction[15:12];
    wire [5:0] MEM_func = MEM_Instruction[5:0];
    
    reg WB_wb;
    reg [1:0] WB_target;
    
    wire [3:0] WB_opcode = WB_Instruction[15:12];
    wire [5:0] WB_func = WB_Instruction[5:0];
    
    always @(*) begin
    // EX writeback?
        if(EX_opcode === `OPCODE_RRR) begin
            if(EX_func === `FUNC_WWD || EX_func === `FUNC_JPR || EX_func === `FUNC_HLT) begin
                EX_wb = 0;
            end
            else if(EX_func === `FUNC_JRL) begin
                EX_wb = 1;
                EX_target = 2'b10;
            end
            else begin
                EX_wb = 1;
                EX_target = EX_Instruction[7:6];
            end
        end
        else if(EX_opcode === `OPCODE_ADI || EX_opcode === `OPCODE_ORI || EX_opcode === `OPCODE_LHI) begin
            EX_wb = 1;
            EX_target = EX_Instruction[9:8];
        end
        else if(EX_opcode === `OPCODE_LWD) begin
            EX_wb = 1;
            EX_target = EX_Instruction[9:8];
        end
        else if(EX_opcode === `OPCODE_JAL) begin
            EX_wb = 1;
            EX_target = 2'b10;
        end
        else if(EX_opcode === `OPCODE_NOP) begin
            EX_wb = 0;
        end
        
        // MEM writeback?
        if(MEM_opcode === `OPCODE_RRR) begin
            if(MEM_func === `FUNC_WWD || MEM_func === `FUNC_JPR || MEM_func === `FUNC_HLT) begin
                MEM_wb = 0;
            end
            else if(MEM_func === `FUNC_JRL) begin
                MEM_wb = 1;
                MEM_target = 2'b10;
            end
            else begin
                MEM_wb = 1;
                MEM_target = MEM_Instruction[7:6];
            end
        end
        else if(MEM_opcode === `OPCODE_ADI || MEM_opcode === `OPCODE_ORI || MEM_opcode === `OPCODE_LHI) begin
            MEM_wb = 1;
            MEM_target = MEM_Instruction[9:8];
        end
        else if(MEM_opcode === `OPCODE_LWD) begin
            MEM_wb = 1;
            MEM_target = MEM_Instruction[9:8];
        end
        else if(MEM_opcode === `OPCODE_JAL) begin
            MEM_wb = 1;
            MEM_target = 2'b10;
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
            end
            else begin
                WB_wb = 1;
                WB_target = WB_Instruction[7:6];
            end
        end
        else if(WB_opcode === `OPCODE_ADI || WB_opcode === `OPCODE_ORI || WB_opcode === `OPCODE_LHI) begin
            WB_wb = 1;
            WB_target = WB_Instruction[9:8];
        end
        else if(WB_opcode === `OPCODE_LWD) begin
            WB_wb = 1;
            WB_target = WB_Instruction[9:8];
        end
        else if(WB_opcode === `OPCODE_JAL) begin
            WB_wb = 1;
            WB_target = 2'b10;
        end
        else if(WB_opcode === `OPCODE_NOP) begin
            WB_wb = 0;
        end
        
        //if(rs === MEM_target && MEM_wb === 1) realA = MEM_data;
        //else if(rs === WB_target && WB_wb === 1) realA = WB_data;
        
        //if(rt === MEM_target && MEM_wb === 1) realB = MEM_data;
        //else if(rt === WB_target && WB_wb === 1) realB = WB_data;
        
        data_hazard = (EX_wb === 1 || MEM_wb === 1 || WB_wb === 1 ? 1 : 0);
    end
    
    
endmodule
