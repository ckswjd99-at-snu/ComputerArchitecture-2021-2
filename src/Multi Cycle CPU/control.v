`timescale 1ns / 1ps

`define STATE_IF 3'd0
`define STATE_ID 3'd1
`define STATE_EX 3'd2
`define STATE_MEM 3'd3
`define STATE_WB 3'd4
`define STATE_HLT 3'd5

`include "opcodes.v"
`include "constants.v"

module control(
        input clk,
        input reset_n,
        
        input [15:0] instruction,
        
        // control signal input/outputs
        output reg pcWrite,
        output reg pcWriteCond,
        output reg [1:0] pcSrc,
        output reg getI,
        output reg readM,
        output reg writeM,
        output reg IRWrite,
        output reg [1:0] regSrc,
        output reg [1:0] regData,
        output reg regWrite,
        output reg srcA,
        output reg [1:0] srcB,
        output reg [5:0] ALUoper,
        output reg isWWD,
        input bEqual,
        input bAGZ,
        input bALZ,
        output reg halted,
        output reg new_inst
    );
    
    reg [2:0] state;
    reg [2:0] nextState;
    wire [3:0] opcode = instruction[15:12];
    wire [5:0] func = instruction[5:0];
    
    initial begin
        // initialize stage
        state = `STATE_IF;
        nextState = `STATE_IF;
        
        // initialize output
        pcWrite = 1'b0;
        pcWriteCond = 1'b0;
        pcSrc = 2'b00;
        getI = 1'b0;
        readM = 1'b0;
        writeM = 1'b0;
        IRWrite = 1'b0;
        regSrc = 2'b00;
        regData = 2'b00;
        regWrite = 1'b0;
        srcA = 1'b0;
        srcB = 2'b00;
        ALUoper = 6'd0;
        isWWD = 1'b0;
        halted = 1'b0;
    end
    
    always @(reset_n) begin
        if(reset_n == 0) begin
            state = `STATE_IF;
            nextState = `STATE_IF;
            readM = 1'b1;
            IRWrite = 1'b1;
            halted = 1'b0;
        end
    end
    
    always @(posedge clk) begin
        if(reset_n != 0) begin
            // update state
            state = nextState;
            new_inst = state == `STATE_IF;
            
            // every output to zero
            pcWrite = 1'b0;
            pcWriteCond = 1'b0;
            pcSrc = 2'b00;
            getI = 1'b0;
            readM = 1'b0;
            writeM = 1'b0;
            IRWrite = 1'b0;
            regSrc = 2'b00;
            regData = 2'b00;
            regWrite = 1'b0;
            srcA = 1'b0;
            srcB = 2'b00;
            ALUoper = 6'd0;
            isWWD = 1'b0;
        
            case(opcode)
                `OPCODE_RRR:
                begin
                    if(func == `FUNC_WWD) begin
                        // IF - ID
                        if(state == `STATE_IF) begin
                            readM = 1;
                            IRWrite = 1;
                            nextState = `STATE_ID;
                        end
                        else if(state == `STATE_ID) begin
                            pcWrite = 1;
                            pcSrc = 1;
                            srcB = 2;
                            isWWD = 1;
                            nextState = `STATE_IF;
                        end
                    end
                    else if(func == `FUNC_JPR) begin
                        // IF - ID
                        if(state == `STATE_IF) begin
                            readM = 1;
                            IRWrite = 1;
                            nextState = `STATE_ID;
                        end
                        else if(state == `STATE_ID) begin
                            pcWrite = 1;
                            pcSrc = 2'b11;
                            nextState = `STATE_IF;
                        end
                    end
                    else if(func == `FUNC_JRL) begin
                        // IF - ID
                        if(state == `STATE_IF) begin
                            // for instruction read
                            readM = 1;
                            IRWrite = 1;
                            nextState = `STATE_ID;
                        end
                        else if(state == `STATE_ID) begin
                            // for next pc store
                            srcA = 1'b0;
                            srcB = 2'b10;
                            ALUoper = `FUNC_ADD;
                            regWrite = 1'b1;
                            regSrc = 2'b10;
                            regData = 2'b10;
                            // jump pc
                            pcWrite = 1;
                            pcSrc = 2'b11;
                            nextState = `STATE_IF;
                        end
                    end
                    else if(func == `FUNC_HLT) begin
                        // IF - ID
                        if(state == `STATE_IF) begin
                            readM = 1;
                            IRWrite = 1;
                            nextState = `STATE_ID;
                        end
                        else if(state == `STATE_ID) begin
                            // stop here
                            nextState = `STATE_ID;
                            halted = 1'b1;
                        end
                    end
                    else begin  // normal R instruction
                        // IF - ID - EX - WB
                        if(state == `STATE_IF) begin
                            readM = 1;
                            IRWrite = 1;
                            nextState = `STATE_ID;
                        end
                        else if(state == `STATE_ID) begin
                            
                            nextState = `STATE_EX;
                        end
                        else if(state == `STATE_EX) begin
                            srcA = 1;
                            srcB = 0;
                            ALUoper = func;
                            nextState = `STATE_WB;
                        end
                        else if(state == `STATE_WB) begin
                            regWrite = 1;
                            regSrc = 1;
                            regData = 1;
                            // nextPC
                            srcB = 2;
                            pcWrite = 1;
                            pcSrc = 1;
                            ALUoper = `FUNC_ADD;
                            nextState = `STATE_IF;
                        end
                    end
                end
                `OPCODE_ADI:
                begin
                    // IF - ID - EX - WB
                    if(state == `STATE_IF) begin
                        readM = 1;
                        IRWrite = 1;
                        nextState = `STATE_ID;
                    end
                    else if(state == `STATE_ID) begin
                        
                        nextState = `STATE_EX;
                    end
                    else if(state == `STATE_EX) begin
                        srcA = 1;
                        srcB = 1;
                        ALUoper = `FUNC_ADI;
                        nextState = `STATE_WB;
                    end
                    else if(state == `STATE_WB) begin
                        regWrite = 1;
                        regSrc = 0;
                        regData = 1;
                        // nextPC
                        srcB = 2;
                        pcWrite = 1;
                        pcSrc = 1;
                        ALUoper = `FUNC_ADD;
                        nextState = `STATE_IF;
                    end
                end
                `OPCODE_ORI:
                begin
                    // IF - ID - EX - WB
                    if(state == `STATE_IF) begin
                        readM = 1;
                        IRWrite = 1;
                        nextState = `STATE_ID;
                    end
                    else if(state == `STATE_ID) begin
                        
                        nextState = `STATE_EX;
                    end
                    else if(state == `STATE_EX) begin
                        srcA = 1;
                        srcB = 1;
                        ALUoper = `FUNC_ORI;
                        nextState = `STATE_WB;
                    end
                    else if(state == `STATE_WB) begin
                        regWrite = 1;
                        regSrc = 0;
                        regData = 1;
                        // nextPC
                        srcB = 2;
                        pcWrite = 1;
                        pcSrc = 1;
                        ALUoper = `FUNC_ADD;
                        nextState = `STATE_IF;
                    end
                end
                `OPCODE_LHI:
                begin
                    // IF - ID - EX - WB
                    if(state == `STATE_IF) begin
                        readM = 1;
                        IRWrite = 1;
                        nextState = `STATE_ID;
                    end
                    else if(state == `STATE_ID) begin
                        
                        nextState = `STATE_EX;
                    end
                    else if(state == `STATE_EX) begin
                        srcA = 1;
                        srcB = 1;
                        ALUoper = `FUNC_LHI;
                        nextState = `STATE_WB;
                    end
                    else if(state == `STATE_WB) begin
                        regWrite = 1;
                        regSrc = 0;
                        regData = 1;
                        // nextPC
                        srcB = 2;
                        pcWrite = 1;
                        pcSrc = 1;
                        ALUoper = `FUNC_ADD;
                        nextState = `STATE_IF;
                    end
                end
                `OPCODE_LWD:
                begin
                    // IF - ID - EX - MEM - WB
                    if(state == `STATE_IF) begin
                        readM = 1;
                        IRWrite = 1;
                        nextState = `STATE_ID;
                    end
                    else if(state == `STATE_ID) begin
                        
                        nextState = `STATE_EX;
                    end
                    else if(state == `STATE_EX) begin
                        srcA = 1;
                        srcB = 1;
                        ALUoper = `FUNC_LWD;
                        nextState = `STATE_MEM;
                    end
                    else if(state == `STATE_MEM) begin
                        getI = 1;
                        readM = 1;
                        nextState = `STATE_WB;
                    end
                    else if(state == `STATE_WB) begin
                        regSrc = 0;
                        regWrite = 1;
                        // nextPC
                        srcB = 2;
                        pcWrite = 1;
                        pcSrc = 1;
                        ALUoper = `FUNC_ADD;
                        nextState = `STATE_IF;
                    end
                end
                `OPCODE_SWD:
                begin
                    // IF - ID - EX - MEM
                    if(state == `STATE_IF) begin
                        readM = 1;
                        IRWrite = 1;
                        nextState = `STATE_ID;
                    end
                    else if(state == `STATE_ID) begin
                        
                        nextState = `STATE_EX;
                    end
                    else if(state == `STATE_EX) begin
                        srcA = 1;
                        srcB = 1;
                        ALUoper = `FUNC_SWD;
                        nextState = `STATE_MEM;
                    end
                    else if(state == `STATE_MEM) begin
                        getI = 1;
                        writeM = 1;
                        // nextPC
                        srcB = 2;
                        pcWrite = 1;
                        pcSrc = 1;
                        ALUoper = `FUNC_ADD;
                        nextState = `STATE_IF;
                    end
                end
                `OPCODE_BNE:
                begin
                    // IF - ID - EX
                    if(state == `STATE_IF) begin
                        readM = 1;
                        IRWrite = 1;
                        nextState = `STATE_ID;
                    end
                    else if(state == `STATE_ID) begin
                        // compute jump pc
                        srcB = 1;
                        ALUoper = `FUNC_BPC;
                        nextState = `STATE_EX;
                    end
                    else if(state == `STATE_EX) begin
                        srcB = 2;
                        pcWrite = 1;
                        pcSrc = bEqual == 1'b0 ? 2'b0 : 2'b1;
                        ALUoper = `FUNC_ADD;
                        nextState = `STATE_IF;
                    end
                end
                `OPCODE_BEQ:
                begin
                    // IF - ID - EX
                    if(state == `STATE_IF) begin
                        readM = 1;
                        IRWrite = 1;
                        nextState = `STATE_ID;
                    end
                    else if(state == `STATE_ID) begin
                        // compute jump pc
                        srcB = 1;
                        ALUoper = `FUNC_BPC;
                        nextState = `STATE_EX;
                    end
                    else if(state == `STATE_EX) begin
                        // compute next pc
                        srcB = 2;
                        pcWrite = 1;
                        pcSrc = bEqual == 1'b1 ? 0 : 1;
                        ALUoper = `FUNC_ADD;
                        nextState = `STATE_IF;
                    end
                end
                `OPCODE_BGZ:
                begin
                    // IF - ID - EX
                    if(state == `STATE_IF) begin
                        readM = 1;
                        IRWrite = 1;
                        nextState = `STATE_ID;
                    end
                    else if(state == `STATE_ID) begin
                        // compute jump pc
                        srcB = 1;
                        ALUoper = `FUNC_BPC;
                        nextState = `STATE_EX;
                    end
                    else if(state == `STATE_EX) begin
                        // compute next pc
                        srcB = 2;
                        pcWrite = 1;
                        pcSrc = bAGZ == 1'b1 ? 0 : 1;
                        ALUoper = `FUNC_ADD;
                        nextState = `STATE_IF;
                    end
                end
                `OPCODE_BLZ:
                begin
                    // IF - ID - EX
                    if(state == `STATE_IF) begin
                        readM = 1;
                        IRWrite = 1;
                        nextState = `STATE_ID;
                    end
                    else if(state == `STATE_ID) begin
                        // compute jump pc
                        srcB = 1;
                        ALUoper = `FUNC_BPC;
                        nextState = `STATE_EX;
                    end
                    else if(state == `STATE_EX) begin
                        // compute next pc
                        srcB = 2;
                        pcWrite = 1;
                        pcSrc = bALZ == 1'b1 ? 0 : 1;
                        ALUoper = `FUNC_ADD;
                        nextState = `STATE_IF;
                    end
                end
                `OPCODE_JMP:
                begin
                    // IF - ID
                    if(state == `STATE_IF) begin
                        readM = 1;
                        IRWrite = 1;
                        nextState = `STATE_ID;
                    end
                    else if(state == `STATE_ID) begin
                        pcWrite = 1;
                        pcSrc = 2;
                        nextState = `STATE_IF;
                    end
                end
                `OPCODE_JAL:
                begin
                    // IF - ID
                    if(state == `STATE_IF) begin
                        readM = 1;
                        IRWrite = 1;
                        nextState = `STATE_ID;
                    end
                    else if(state == `STATE_ID) begin
                        pcWrite = 1;
                        pcSrc = 2;
                        regSrc = 2;
                        regData = 2;
                        regWrite = 1;
                        srcB = 2;
                        nextState = `STATE_IF;
                    end
                end
            endcase
        end
    end
    
endmodule
