module proteus_register_file (
    reset,
    clk,
    write_data,
    write_register,
    write_enable,
    read_register,
    read_data
);

    input reset;
    input clk;
    input [31:0] write_data;
    input [1:0] write_register;
    input write_enable;
    input [1:0] read_register;
    output [31:0] read_data;

    wire [31:0] _23;
    wire [1:0] _18;
    wire _19;
    wire _20;
    wire [31:0] _21;
    reg [31:0] _25;
    wire [31:0] _1;
    wire [1:0] _26;
    wire _27;
    wire _28;
    wire [31:0] _29;
    reg [31:0] _32;
    wire [31:0] _2;
    wire [1:0] _33;
    wire _34;
    wire _35;
    wire [31:0] _36;
    reg [31:0] _39;
    wire [31:0] _3;
    wire vdd;
    wire _5;
    wire _7;
    wire [31:0] _9;
    wire [1:0] _40;
    wire [1:0] _11;
    wire _41;
    wire _13;
    wire _42;
    wire [31:0] _43;
    reg [31:0] _46;
    wire [31:0] _14;
    wire [1:0] _16;
    reg [31:0] _47;
    assign _23 = 32'b00000000000000000000000000000000;
    assign _18 = 2'b11;
    assign _19 = _11 == _18;
    assign _20 = _13 & _19;
    assign _21 = _20 ? _9 : _1;
    always @(posedge _7 or posedge _5) begin
        if (_5)
            _25 <= _23;
        else
            _25 <= _21;
    end
    assign _1 = _25;
    assign _26 = 2'b10;
    assign _27 = _11 == _26;
    assign _28 = _13 & _27;
    assign _29 = _28 ? _9 : _2;
    always @(posedge _7 or posedge _5) begin
        if (_5)
            _32 <= _23;
        else
            _32 <= _29;
    end
    assign _2 = _32;
    assign _33 = 2'b01;
    assign _34 = _11 == _33;
    assign _35 = _13 & _34;
    assign _36 = _35 ? _9 : _3;
    always @(posedge _7 or posedge _5) begin
        if (_5)
            _39 <= _23;
        else
            _39 <= _36;
    end
    assign _3 = _39;
    assign vdd = 1'b1;
    assign _5 = reset;
    assign _7 = clk;
    assign _9 = write_data;
    assign _40 = 2'b00;
    assign _11 = write_register;
    assign _41 = _11 == _40;
    assign _13 = write_enable;
    assign _42 = _13 & _41;
    assign _43 = _42 ? _9 : _14;
    always @(posedge _7 or posedge _5) begin
        if (_5)
            _46 <= _23;
        else
            _46 <= _43;
    end
    assign _14 = _46;
    assign _16 = read_register;
    always @* begin
        case (_16)
        0:
            _47 <= _14;
        1:
            _47 <= _3;
        2:
            _47 <= _2;
        default:
            _47 <= _1;
        endcase
    end
    assign read_data = _47;

endmodule
