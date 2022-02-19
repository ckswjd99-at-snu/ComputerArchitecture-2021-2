`timescale 1ns/1ns

`include "opcodes.v"

module cpu(
        input Clk, 
        input Reset_N, 

	// Instruction memory interface
        output i_readM, 
        output i_writeM, 
        output [`WORD_SIZE-1:0] i_address, 
        inout [`LINE_SIZE-1:0] i_data, 

	// Data memory interface
        output d_readM, 
        output d_writeM, 
        output [`WORD_SIZE-1:0] d_address, 
        inout [`LINE_SIZE-1:0] d_data, 

        output [`WORD_SIZE-1:0] num_inst, 
        output [`WORD_SIZE-1:0] output_port, 
        output is_halted
);

	// TODO : Implement your multi-cycle CPU!
	
	// Notation
	wire reset_n = Reset_N;
	
	// Virtual Clock
	reg v_clk;
	wire if_memoryWait;
	wire mem_memoryWait;
	always @(posedge Clk) begin
	   if(if_memoryWait == 0 && mem_memoryWait == 0) v_clk = 1;
	end
	always @(negedge Clk) v_clk = 0;
	wire clk = v_clk;
	
	// PIPELINE REGISTERS
	/* IF_ID */
	reg [`WORD_SIZE-1:0] IF_ID_PC;
	reg [`WORD_SIZE-1:0] IF_ID_Instruction;
	/* ID_EX */
	reg [`WORD_SIZE-1:0] ID_EX_PC;
	reg [`WORD_SIZE-1:0] ID_EX_Instruction;
	reg [`WORD_SIZE-1:0] ID_EX_A;
	reg [`WORD_SIZE-1:0] ID_EX_B;
	/* EX_MEM */
	reg [`WORD_SIZE-1:0] EX_MEM_PC;
	reg [`WORD_SIZE-1:0] EX_MEM_Instruction;
	reg [`WORD_SIZE-1:0] EX_MEM_AluOut;
	reg [`WORD_SIZE-1:0] EX_MEM_B;
	/* MEM_WB */
	reg [`WORD_SIZE-1:0] MEM_WB_PC;
	reg [`WORD_SIZE-1:0] MEM_WB_Instruction;
	reg [`WORD_SIZE-1:0] MEM_WB_MemoryData;
	reg [`WORD_SIZE-1:0] MEM_WB_AluOut;
	
	// Instruction Count
	reg [`WORD_SIZE-1:0] num_inst_reg;
	initial num_inst_reg = 0;
	always @(reset_n) if(reset_n == 0) num_inst_reg = `WORD_SIZE'h0;
	always @(MEM_WB_Instruction) if(MEM_WB_Instruction !== 16'he000) num_inst_reg = num_inst_reg + 1;
	assign num_inst = num_inst_reg;
	
	// HALT DETECTOR
	HALT_DETECTOR hd(
	   .clk(clk),
	   .reset_n(reset_n),
	   .instruction(MEM_WB_Instruction),
	   .is_halted(is_halted)
	);
	
	// CONTROL HAZARD DETECTOR
	wire forcePC;
	wire [`WORD_SIZE-1:0] forcePCdata;
	wire [`WORD_SIZE-1:0] realPC;
	wire isJumping;
	CONTROL_HAZARD_UNIT chu(
	    .ID_PC(IF_ID_PC),
        .realPC(realPC),
        .forcePC(forcePC),
        .forcePCdata(forcePCdata)
	);
	
	// FORWARDING UNIT
	wire [`WORD_SIZE-1:0] realA;
	wire [`WORD_SIZE-1:0] realB;
	wire MEM_wb;
	wire [1:0] MEM_target;
	wire [`WORD_SIZE-1:0] MEM_data;
	wire WB_wb;
	wire [1:0] WB_target;
	wire [`WORD_SIZE-1:0] WB_data;
	wire [`WORD_SIZE-1:0] mem_read_data;
	wire data_hazard;
	FORWARD_UNIT fu(
	   .A(ID_EX_A),
	   .B(ID_EX_B),
	   .Instruction(ID_EX_Instruction),
	   .MEM_Instruction(EX_MEM_Instruction),
	   .MEM_aluOut(EX_MEM_AluOut),
	   .MEM_memoryReadData(mem_read_data),
	   .WB_Instruction(MEM_WB_Instruction),
	   .WB_aluOut(MEM_WB_AluOut),
	   .WB_memoryReadData(MEM_WB_MemoryData),
	   .realA(realA),
	   .realB(realB),
	   .data_hazard(data_hazard)
	);
	
	// STAGES
	/* STAGE IF */
	wire [`WORD_SIZE-1:0] IF_PC;
	wire [`WORD_SIZE-1:0] IF_Instruction;
	STAGE_IF stage_IF(
	   .clk(Clk),
	   .v_clk(clk),
	   .reset_n(reset_n),
	   .instruction(IF_Instruction),
	   .PC_now(IF_PC),
	   .forcePC(forcePC),
	   .forcePCdata(forcePCdata),
	   .EX_PC(ID_EX_PC),
	   .i_readM(i_readM),
	   .i_writeM(i_writeM),
	   .i_address(i_address),
	   .i_data(i_data),
	   .memoryWait(if_memoryWait)
	);
	
	/* STAGE ID */
	wire [1:0] addr1 = IF_ID_Instruction[11:10];
	wire [1:0] addr2 = IF_ID_Instruction[9:8];
	wire [1:0] addr3;
	wire [`WORD_SIZE-1:0] data1;
	wire [`WORD_SIZE-1:0] data2;
	wire [`WORD_SIZE-1:0] data3;
	wire rfWrite;
	STAGE_ID stage_ID(
	   .clk(clk),
	   .reset_n(reset_n),
	   .addr1(addr1),
	   .addr2(addr2),
	   .addr3(addr3),
	   .data1(data1),
	   .data2(data2),
	   .data3(data3),
	   .rfWrite(rfWrite)
	);
	
	/* STAGE EX */
	wire aluSrcA, aluSrcB;
	wire [5:0] func;
	wire [`WORD_SIZE-1:0] aluOut;
	
	LC_EX lc_EX(
	    .PC(ID_EX_PC),
	    .instruction(ID_EX_Instruction),
	    .A(realA),
	    .B(realB),
        .realPC(realPC),
        .aluSrcA(aluSrcA),
        .aluSrcB(aluSrcB),
        .func(func)
	);
	
	STAGE_EX stage_EX(
	   .clk(clk),
	   .reset_n(reset_n),
	   .PC(ID_EX_PC),
	   .instruction(ID_EX_Instruction),
	   .A(realA),
	   .B(realB),
	   .aluOut(aluOut),
	   .aluSrcA(aluSrcA),
	   .aluSrcB(aluSrcB),
	   .func(func)
	);
	
	/* STAGE MEM */
	STAGE_MEM stage_MEM(
	   .clk(Clk),
	   .v_clk(clk),
	   .reset_n(reset_n),
	   .instruction(EX_MEM_Instruction),
	   .addr(EX_MEM_AluOut),
	   .write_data(EX_MEM_B),
	   .read_data(mem_read_data),
	   .d_readM(d_readM),
	   .d_writeM(d_writeM),
	   .d_address(d_address),
	   .d_data(d_data),
	   .memoryWait(mem_memoryWait)
	);
	
	/* STAGE WB */
	STAGE_WB stage_WB(
	   .clk(clk),
	   .reset_n(reset_n),
	   .instruction(MEM_WB_Instruction),
	   .m_data(MEM_WB_MemoryData),
	   .aluOut(MEM_WB_AluOut),
	   .addr3(addr3),
	   .data3(data3),
	   .rfWrite(rfWrite),
	   .output_port(output_port)
	);
	
	// clock
	always @(posedge clk) begin
        if(reset_n != 0) begin
            if(is_halted == 0) begin
                IF_ID_PC <= IF_PC;
                IF_ID_Instruction <= IF_Instruction;
                
                ID_EX_PC <= forcePC ? `WORD_SIZE'bz : IF_ID_PC;
                ID_EX_Instruction <= forcePC ? {`OPCODE_NOP, 12'b0} : IF_ID_Instruction;
                ID_EX_A <= data1;
                ID_EX_B <= data2;
                
                EX_MEM_PC <= ID_EX_PC;
                EX_MEM_Instruction <= ID_EX_Instruction;
                EX_MEM_AluOut <= aluOut;
                EX_MEM_B <= realB;
                
                MEM_WB_PC <= EX_MEM_PC;
                MEM_WB_Instruction <= EX_MEM_Instruction;
                MEM_WB_MemoryData <= mem_read_data;
                MEM_WB_AluOut <= EX_MEM_AluOut;
            end
            else begin
                IF_ID_PC <= `WORD_SIZE'bz;
                IF_ID_Instruction <= `WORD_SIZE'bz;
                
                ID_EX_PC <= `WORD_SIZE'bz;
                ID_EX_Instruction <= `WORD_SIZE'bz;
                ID_EX_A <= `WORD_SIZE'bz;
                ID_EX_B <= `WORD_SIZE'bz;
                
                EX_MEM_PC <= `WORD_SIZE'bz;
                EX_MEM_Instruction <= `WORD_SIZE'bz;
                EX_MEM_AluOut <= `WORD_SIZE'bz;
                EX_MEM_B <= `WORD_SIZE'bz;
                
                MEM_WB_PC <= `WORD_SIZE'bz;
                MEM_WB_Instruction <= `WORD_SIZE'bz;
                MEM_WB_MemoryData <= `WORD_SIZE'bz;
                MEM_WB_AluOut <= `WORD_SIZE'bz;
            end
        end
	end
	

endmodule
