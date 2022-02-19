`timescale 1ns / 1ps

`include "constants.v"

module datapath(
        input clk,
        input reset_n,
        
        // memory communication
        inout [`WORD_SIZE-1:0] memory_data,
        output [`WORD_SIZE-1:0] memory_addr,
        input inputReady,
        
        // WWD output
        output [`WORD_SIZE-1:0] output_port,
        
        // control signal inputs/outputs
        output [`WORD_SIZE-1:0] instruction,
        input pcWrite,
        input pcWriteCond,
        input [1:0] pcSrc,
        input getI,
        input readM,
        input writeM,
        input IRWrite,
        input [1:0] regSrc,
        input [1:0] regData,
        input regWrite,
        input srcA,
        input [1:0] srcB,
        input [5:0] ALUoper,
        input isWWD,
        output reg bEqual,
        output reg bAGZ,
        output reg bALZ
    );
    
    // architectural registers
    reg [`WORD_SIZE-1:0] PC;
    reg [`WORD_SIZE-1:0] memory_register;
    reg [`WORD_SIZE-1:0] inst_register;
    reg [`WORD_SIZE-1:0] data_register;
    reg [`WORD_SIZE-1:0] rfA_register;
    reg [`WORD_SIZE-1:0] rfB_register;
    reg [`WORD_SIZE-1:0] aluout_register;
    
    // instruction split
    wire [3:0] inst_opcode = inst_register[15:12];
    wire [1:0] inst_rs = inst_register[11:10];
    wire [1:0] inst_rt = inst_register[9:8];
    wire [1:0] inst_rd = inst_register[7:6];
    wire [11:0] inst_offset = inst_register[11:0];
    wire [15:0] inst_immedi = {8'b0, inst_register[7:0]};
    wire [5:0] inst_func = inst_register[5:0];
    
    // wires for PC
    wire [`WORD_SIZE-1:0] pc_next;
    
    // wires for register
    wire [1:0] rf_addr1 = inst_rs;
    wire [1:0] rf_addr2 = inst_rt;
    wire [1:0] rf_writeaddr;
    wire [`WORD_SIZE-1:0] rf_data1;
    wire [`WORD_SIZE-1:0] rf_data2;
    wire [`WORD_SIZE-1:0] rf_writedata;
    
    // wires for ALU
    wire [`WORD_SIZE-1:0] alu_A;
    wire [`WORD_SIZE-1:0] alu_B;
    wire [`WORD_SIZE-1:0] alu_out;
    wire bcond;
    
    // control signal
    wire pcUpdate;
    assign pcUpdate = pcWrite | (bcond & pcWriteCond);
    assign instruction = inst_register;
    
    // MUX control
    assign memory_data = writeM ? rfB_register : `WORD_SIZE'bz;
    assign memory_addr = getI == 1'b0 ? PC : aluout_register;
    assign rf_writeaddr = regSrc == 2'b00 ? inst_rt : regSrc == 2'b01 ? inst_rd : 2'b10;
    assign rf_writedata = regData == 2'b00 ? data_register : regData == 2'b01 ? aluout_register : alu_out;
    assign alu_A = srcA == 1'b0 ? PC : rfA_register;
    assign alu_B = srcB == 2'b0 ? rfB_register : srcB == 2'b01 ? inst_immedi : `WORD_SIZE'd1;
    assign pc_next = pcSrc[1] ? (pcSrc[0] ? rf_data1 : {PC[15:12], inst_offset}) : (pcSrc[0] ? alu_out : aluout_register);
    assign output_port = isWWD == 1'b0 ? `WORD_SIZE'bz : rf_data1;
    
    // ALU
    ALU alu(
        .A(alu_A),
        .B(alu_B),
        .OP(ALUoper),
        .C(alu_out),
        .bcond(bcond)
    );
    
    // register file 
    RF registerFile(
        .write(regWrite),
        .clk(clk),
        .reset_n(reset_n),
        .addr1(rf_addr1),
        .addr2(rf_addr2),
        .addr3(rf_writeaddr),
        .data1(rf_data1),
        .data2(rf_data2),
        .data3(rf_writedata)
    );
    
    // initialize
    initial begin
        PC = `WORD_SIZE'b0;
        inst_register = `WORD_SIZE'b0;
        data_register = `WORD_SIZE'b0;
        rfA_register = `WORD_SIZE'b0;
        rfB_register = `WORD_SIZE'b0;
        aluout_register = `WORD_SIZE'b0;
        bEqual = rf_data1 == rf_data2 ? 1'b1 : 1'b0;
        bAGZ = rf_data1 > 0 ? 1'b1 : 1'b0;
        bALZ = rf_data1 < 0 ? 1'b1 : 1'b0;
    end
    
    // reset
    always @(reset_n) begin
        if(reset_n == 1'b0) begin
            PC = `WORD_SIZE'b0;
            inst_register = `WORD_SIZE'b0;
            data_register = `WORD_SIZE'b0;
            rfA_register = `WORD_SIZE'b0;
            rfB_register = `WORD_SIZE'b0;
            aluout_register = `WORD_SIZE'b0;
            bEqual = rf_data1 == rf_data2 ? 1'b1 : 1'b0;
            bAGZ = rf_data1 > 0 ? 1'b1 : 1'b0;
            bALZ = rf_data1 < 0 ? 1'b1 : 1'b0;
        end
    end
    
    // clock
    always @(posedge clk) begin
        if(reset_n != 1'b0) begin
            if(pcUpdate) PC = pc_next;
            if(IRWrite) inst_register = memory_register;
            data_register = memory_register;
            rfA_register = rf_data1;
            rfB_register = rf_data2;
            aluout_register = alu_out;
        end
    end
    
    always @(IRWrite, memory_register) if(IRWrite) inst_register = memory_register;
    
    // comparator
    always @(rf_data1, rf_data2) begin
        bEqual = rf_data1 == rf_data2 ? 1'b1 : 1'b0;
        bAGZ = rf_data1[`WORD_SIZE-1] == 1'b0 && rf_data1[`WORD_SIZE-2:0] > 0 ? 1'b1 : 1'b0;
        bALZ = rf_data1[`WORD_SIZE-1] == 1'b1 ? 1'b1 : 1'b0;
    end
    
    // memory read
    always @(inputReady) begin
        if(inputReady == 1'b1) begin
            memory_register = memory_data;
        end
    end
endmodule
