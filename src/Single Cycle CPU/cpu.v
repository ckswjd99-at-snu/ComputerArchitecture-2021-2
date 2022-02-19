///////////////////////////////////////////////////////////////////////////
// MODULE: CPU for TSC microcomputer: cpu.v
// Author: 
// Description: 

`include "opcodes.v"

// MODULE DECLARATION
module cpu (
  output readM,                       // read from memory
  output [`WORD_SIZE-1:0] address,    // current address for data
  inout [`WORD_SIZE-1:0] data,        // data being input or output
  input inputReady,                   // indicates that data is ready from the input port
  input reset_n,                      // active-low RESET signal
  input clk,                          // clock signal

  // for debuging/testing purpose
  output [15:0] num_inst,   // number of instruction during execution
  output [15:0] output_port // this will be used for a "WWD" instruction
);

// wires connecting DP and CU
wire isR;
wire [5:0] aluFunc;
wire isADI;
wire isLHI;
wire isJMP;
wire isOUT;
wire regWrite;

// for fetching instruction
reg readM;
wire addr_wire;
reg [`WORD_SIZE-1:0] instruction;
reg [`WORD_SIZE-1:0] num_inst;

// submodules
DataPath DP(
    clk, reset_n, instruction, isR, aluFunc, isADI, isLHI, isJMP, isOUT, regWrite, address, output_port
);

ControlUnit CU(
    instruction[15:12], instruction[5:0], isR, aluFunc, isADI, isLHI, isJMP, isOUT, regWrite
);

// initial and reset
initial begin
    num_inst = 0;
end
always @(reset_n) begin
    num_inst = 0;
end

// at posedge, fetch one instruction and store
always @(posedge clk) begin
    num_inst = num_inst+1;
    readM = 1;
end

always @(inputReady) begin
    if(inputReady == 1) begin
        instruction = data;
        readM = 0;
    end
end

  // ... fill in the rest of the code

endmodule
//////////////////////////////////////////////////////////////////////////
