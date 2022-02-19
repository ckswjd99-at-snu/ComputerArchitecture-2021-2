//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/11 14:08:04
// Design Name: 
// Module Name: DataPath
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "opcodes.v"

module DataPath(
    input clk,
    input reset_n,
    
    // control signal inputs
    input [`WORD_SIZE-1: 0] instruction,
    input isR,
    input [5:0] aluFunc,
    input isADI,
    input isLHI,
    input isJMP,
    input isOUT,
    input regWrite,
    
    // address for next instruction
    output reg [`WORD_SIZE-1:0] addr,
    output reg [`WORD_SIZE-1:0] outSignal
    );
    
    // declare PC
    reg [`WORD_SIZE-1:0] PC;
    
    // wires parsing instruction
    wire [3:0] opcode = instruction[15:12];
    wire [1:0] rs = instruction[11:10];
    wire [1:0] rt = instruction[9:8];
    wire [1:0] rd = instruction[7:6];
    wire [5:0] r_function = instruction[5:0];
    wire [7:0] i_immediate = instruction[7:0];
    wire [11:0] j_immediate = instruction[11:0];
    wire [15:0] lshift = {instruction[7:0], 8'b0};
    wire [15:0] sign_extend = {{8{instruction[7]}}, instruction[7:0]};
    
    // wires connected to register file
    reg [1:0] addr1;
    reg [1:0] addr2;
    reg [1:0] addr3;
    wire [`WORD_SIZE-1:0] data1;
    wire [`WORD_SIZE-1:0] data2;
    reg [`WORD_SIZE-1:0] data3;
    
    // wires connected to ALU
    reg [`WORD_SIZE-1:0] aluA;
    reg [`WORD_SIZE-1:0] aluB;
    wire [`WORD_SIZE-1:0] aluResult;
    
    // straight connections or MUX connection
    always @(*) begin
        addr1 = rs;
        addr2 = rt;
        addr3 = isR ? rd : rt;  // watch
        data3 = isLHI ? lshift : aluResult;
        aluA = data1;
        aluB = isADI ? sign_extend : data2;
    end
    
    // create submodules
    RF registerFile(
        regWrite,clk,reset_n,
        addr1,addr2,addr3,
        data1,data2,data3
    );
    
    ALU alu(aluA, aluB, aluFunc, aluResult);
    
    // manage PC
    initial begin
        PC = `WORD_SIZE'b0;
        addr = PC;
    end
    always @(posedge clk) begin
        if(reset_n != 0) begin
            PC = isJMP ? j_immediate : PC+1;
            addr = PC;
            outSignal = isOUT ? data1 : `WORD_SIZE'b0;
        end
    end
    always @(reset_n) begin
        if(reset_n == 1'b0) begin
            PC = `WORD_SIZE'b0;
            addr = PC;
        end
    end
    
endmodule
