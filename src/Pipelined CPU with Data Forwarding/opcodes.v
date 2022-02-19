`define FUNC_ADD 6'd0
`define FUNC_SUB 6'd1
`define FUNC_AND 6'd2
`define FUNC_ORR 6'd3
`define FUNC_NOT 6'd4
`define FUNC_TCP 6'd5
`define FUNC_SHL 6'd6
`define FUNC_SHR 6'd7
`define FUNC_WWD 6'd28
`define FUNC_JPR 6'd25
`define FUNC_JRL 6'd26
`define FUNC_HLT 6'd29

`define FUNC_ADI 6'd10
`define FUNC_ORI 6'd12
`define FUNC_LHI 6'd13
`define FUNC_LWD 6'd14
`define FUNC_SWD 6'd15
`define FUNC_BPC 6'd16
`define FUNC_JPC 6'd17
`define FUNC_A 6'd18

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
`define OPCODE_RRR 4'd15
`define OPCODE_NOP 4'd14

`define WORD_SIZE 16
`define BTB_SIZE 6