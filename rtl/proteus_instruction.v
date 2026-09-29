module proteus_instruction (
    instruction,
    opcode,
    register,
    immediate
);

    input [15:0] instruction;
    output [3:0] opcode;
    output [3:0] register;
    output [7:0] immediate;

    wire [7:0] _6;
    wire [3:0] _7;
    wire [15:0] _4;
    wire [3:0] _8;
    assign _6 = _4[7:0];
    assign _7 = _4[11:8];
    assign _4 = instruction;
    assign _8 = _4[15:12];
    assign opcode = _8;
    assign register = _7;
    assign immediate = _6;

endmodule
