`timescale 1ns/100ps

`include "opcodes.v"
`include "constants.v"

module cpu (
    output readM, // read from memory
    output writeM, // write to memory
    output [`WORD_SIZE-1:0] address, // current address for data
    inout [`WORD_SIZE-1:0] data, // data being input or output
    input inputReady, // indicates that data is ready from the input port
    input reset_n, // active-low RESET signal
    input clk, // clock signal
    
    // for debuging/testing purpose
    output [`WORD_SIZE-1:0] num_inst, // number of instruction during execution
    output [`WORD_SIZE-1:0] output_port, // this will be used for a "WWD" instruction
    output is_halted // 1 if the cpu is halted
);
    // ... fill in the rest of the code
    reg [`WORD_SIZE-1:0] memory_register;
    reg [`WORD_SIZE-1:0] num_inst;
    
    // wires between DP & CU
    wire [`WORD_SIZE-1:0] instruction;
    wire pcWrite;
    wire pcWriteCond;
    wire [1:0] pcSrc;
    wire getI;
    wire readM_w;
    wire writeM_w;
    wire IRWrite;
    wire [1:0] regSrc;
    wire [1:0] regData;
    wire regWrite;
    wire srcA;
    wire [1:0] srcB;
    wire [5:0] ALUoper;
    wire isWWD;
    wire bEqual;
    wire bAGZ;
    wire bALZ;
    
    // wire for CU num_inst
    wire new_inst;
    
    assign readM = readM_w;
    assign writeM = writeM_w;
    
    datapath DP(
        .clk(clk),
        .reset_n(reset_n),
        .memory_data(data),
        .memory_addr(address),
        .inputReady(inputReady),
        .output_port(output_port),
        .instruction(instruction),
        .pcWrite(pcWrite),
        .pcWriteCond(pcWriteCond),
        .pcSrc(pcSrc),
        .getI(getI),
        .readM(readM_w),
        .writeM(writeM_w),
        .IRWrite(IRWrite),
        .regSrc(regSrc),
        .regData(regData),
        .regWrite(regWrite),
        .srcA(srcA),
        .srcB(srcB),
        .ALUoper(ALUoper),
        .isWWD(isWWD),
        .bEqual(bEqual),
        .bAGZ(bAGZ),
        .bALZ(bALZ)
    );
    
    control CU(
        .clk(clk),
        .reset_n(reset_n),
        .instruction(instruction),

        .pcWrite(pcWrite),
        .pcWriteCond(pcWriteCond),
        .pcSrc(pcSrc),
        .getI(getI),
        .readM(readM_w),
        .writeM(writeM_w),
        .IRWrite(IRWrite),
        .regSrc(regSrc),
        .regData(regData),
        .regWrite(regWrite),
        .srcA(srcA),
        .srcB(srcB),
        .ALUoper(ALUoper),
        .isWWD(isWWD),
        .bEqual(bEqual),
        .bAGZ(bAGZ),
        .bALZ(bALZ),
        .halted(is_halted),
        .new_inst(new_inst)
    );
    
    always @(reset_n) begin
        if(reset_n == 0) begin
            num_inst = `WORD_SIZE'b0;
        end
    end
    
    always @(data) begin
        if(readM == 1'b1) memory_register = data; 
    end
    
    always @(posedge new_inst) begin
        num_inst = num_inst + 1;
    end
    
endmodule
