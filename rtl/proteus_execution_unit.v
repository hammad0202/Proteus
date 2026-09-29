module proteus_execution_unit (
    immediate,
    register,
    opcode,
    write_enable,
    write_register,
    write_data
);

    input [7:0] immediate;
    input [3:0] register;
    input [3:0] opcode;
    output write_enable;
    output [1:0] write_register;
    output [31:0] write_data;

    wire [7:0] _2;
    wire [23:0] _13;
    wire [31:0] _14;
    wire [31:0] _12;
    wire [31:0] _15;
    wire [3:0] _5;
    wire [1:0] _16;
    wire [3:0] _17;
    wire _18;
    wire [3:0] _10;
    wire [3:0] _8;
    wire _11;
    wire _19;
    assign _2 = immediate;
    assign _13 = 24'b000000000000000000000000;
    assign _14 = { _13,
                   _2 };
    assign _12 = 32'b00000000000000000000000000000000;
    assign _15 = _11 ? _14 : _12;
    assign _5 = register;
    assign _16 = _5[1:0];
    assign _17 = 4'b0010;
    assign _18 = _8 == _17;
    assign _10 = 4'b0001;
    assign _8 = opcode;
    assign _11 = _8 == _10;
    assign _19 = _11 | _18;
    assign write_enable = _19;
    assign write_register = _16;
    assign write_data = _15;

endmodule
