//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/11 14:08:04
// Design Name: 
// Module Name: Controll
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
`define FUNC_ADD 6'd0
`define FUNC_SUB 6'd1
`define FUNC_AND 6'd2
`define FUNC_ORR 6'd3
`define FUNC_NOT 6'd4
`define FUNC_TCP 6'd5
`define FUNC_SHL 6'd6
`define FUNC_SHR 6'd7

`define OPCODE_ADI 4'd4
`define OPCODE_ORI 4'd5
`define OPCODE_LHI 4'd6
`define OPCODE_LWD 4'd7
`define OPCODE_SWD 4'd8
`define OPCODE_BNE 4'd0
`define OPCODE_BEQ 4'd1
`define OPCODE_BGZ 4'd2
`define OPCODE_BLZ 4'd3
`define OPCODE_JMP 4'd9
`define OPCODE_JAL 4'd10

`define OPCODE_R 4'd15
`define FUNC_WWD 6'd28

`define WORD_SIZE 16    // data and address word size

module ControlUnit(
    input [3:0] opcode,
    input [5:0] func,
    output reg isR,
    output reg [5:0] aluFunc,
    output reg isADI,
    output reg isLHI,
    output reg isJMP,
    output reg isOUT,
    output reg regWrite
    );
    
    always @(*) begin
        // init every output port
        isR = 0;
        aluFunc = 6'b0;
        isADI = 0;
        isLHI = 0;
        isJMP = 0;
        isOUT = 0;
        regWrite = 0;
        
        // modify output by case
        if(opcode == `OPCODE_R && func != `FUNC_WWD) begin
            isR = 1'b1;
            aluFunc = func[3:0];
            regWrite = 1;
        end
        else if (opcode == `OPCODE_ADI) begin
            aluFunc = `FUNC_ADD;
            isADI = 1;
            regWrite = 1;
        end
        else if (opcode == `OPCODE_LHI) begin
            isLHI = 1;
            regWrite = 1;
        end
        else if (opcode == `OPCODE_JMP) begin
            isJMP = 1;
        end
        else if (opcode == `OPCODE_R && func == `FUNC_WWD) begin
            isOUT = 1;
        end
    end
    
    
endmodule
