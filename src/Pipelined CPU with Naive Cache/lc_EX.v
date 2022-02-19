`timescale 1ns / 1ps

`include "opcodes.v"

module LC_EX(
        input [`WORD_SIZE-1:0] PC,
        input [`WORD_SIZE-1:0] instruction,
        input [`WORD_SIZE-1:0] A,
        input [`WORD_SIZE-1:0] B,
        
        output reg [`WORD_SIZE-1:0] realPC,
        output reg aluSrcA,
        output reg aluSrcB,
        output reg [5:0] func
    );
    
    // parse instruction
    wire [3:0] inst_opcode = instruction[15:12];
    wire [5:0] inst_func = instruction[5:0];
    
    reg realPC;
    
    always @(*) begin
        aluSrcA = 0;
        aluSrcB = 0;
        
        case(inst_opcode)
            `OPCODE_ADI:
            begin
                func = `FUNC_ADI;
                aluSrcA = 1;
                aluSrcB = 1;
                realPC = PC+1;
            end
            `OPCODE_ORI:
            begin
                func = `FUNC_ORI;
                aluSrcA = 1;
                aluSrcB = 1;
                realPC = PC+1;
            end
            `OPCODE_LHI:
            begin
                func = `FUNC_LHI;
                aluSrcA = 1;
                aluSrcB = 1;
                realPC = PC+1;
            end
            `OPCODE_LWD:
            begin
                func = `FUNC_LWD;
                aluSrcA = 1;
                aluSrcB = 1;
                realPC = PC+1;
            end
            `OPCODE_SWD:
            begin
                func = `FUNC_SWD;
                aluSrcA = 1;
                aluSrcB = 1;
                realPC = PC+1;
            end
            `OPCODE_BNE:
            begin
                func = `FUNC_BPC;
                aluSrcB = 1;
                if(A != B) realPC = PC + 1 + {{8{instruction[7]}}, instruction[7:0]};
                else realPC = PC + 1;
            end
            `OPCODE_BEQ:
            begin
                func = `FUNC_BPC;
                aluSrcB = 1;
                if(A == B) realPC = PC + 1 + {{8{instruction[7]}}, instruction[7:0]};
                else realPC = PC + 1;
            end
            `OPCODE_BGZ:
            begin
                func = `FUNC_BPC;
                aluSrcB = 1;
                if(A[15] == 0 && A[14:0] > 0) realPC = PC + 1 + {{8{instruction[7]}}, instruction[7:0]};
                else realPC = PC + 1;
            end
            `OPCODE_BLZ:
            begin
                func = `FUNC_BPC;
                aluSrcB = 1;
                if(A[15] == 1) realPC = PC + 1 + {{8{instruction[7]}}, instruction[7:0]};
                else realPC = PC + 1;
            end
            `OPCODE_JMP:
            begin
                realPC = {PC[15:12], instruction[11:0]};
            end
            `OPCODE_JAL:
            begin
                func = `FUNC_JPC;
                aluSrcA = 0;
                realPC = {PC[15:12], instruction[11:0]};
            end
            `OPCODE_RRR:
            begin
                if(inst_func == `FUNC_JPR) begin
                    func = `FUNC_A;
                    aluSrcA = 1;
                    realPC = A;
                end
                else if(inst_func == `FUNC_JRL) begin
                    func = `FUNC_JPC;
                    aluSrcA = 0;
                    realPC = A;
                end
                else if(inst_func == `FUNC_HLT) begin
                    
                end
                else if(inst_func == `FUNC_WWD) begin
                    func = `FUNC_A;
                    aluSrcA = 1;
                    realPC = PC + 1;
                end
                else begin
                    func = inst_func;
                    aluSrcA = 1;
                    aluSrcB = 0;
                    realPC = PC + 1;
                end
            end
            `OPCODE_NOP:
            begin
                realPC = `WORD_SIZE'bz;
            end
        endcase
        
    end
    
endmodule
