module uart_rx (
    consume,
    bit_period,
    reset,
    clk,
    rx,
    data_out,
    valid,
    busy,
    frame_error
);

    input consume;
    input [7:0] bit_period;
    input reset;
    input clk;
    input rx;
    output [7:0] data_out;
    output valid;
    output busy;
    output frame_error;

    wire _35;
    wire _28;
    wire _29;
    wire _31;
    wire _33;
    reg _36;
    wire _1;
    wire _39;
    wire _40;
    wire _41;
    wire _5;
    wire _43;
    reg _46;
    wire _6;
    wire [7:0] _106;
    wire [6:0] _102;
    wire [7:0] _103;
    wire [1:0] _100;
    wire [3:0] _93;
    wire [3:0] _58;
    wire [3:0] _52;
    wire [3:0] _53;
    wire _51;
    wire [3:0] _55;
    wire [3:0] _56;
    reg [3:0] _59;
    wire [3:0] _8;
    wire _94;
    wire [1:0] _95;
    wire [1:0] _47;
    wire [1:0] _91;
    wire [1:0] _92;
    wire [1:0] _96;
    wire [7:0] _79;
    wire [6:0] _77;
    wire gnd;
    wire [7:0] _78;
    wire [7:0] _80;
    wire [7:0] _10;
    wire [7:0] _71;
    wire [7:0] _68;
    wire _65;
    wire _66;
    wire [7:0] _69;
    wire [1:0] _62;
    wire _63;
    wire _64;
    wire [7:0] _72;
    wire [7:0] _73;
    wire [7:0] _75;
    wire [7:0] _81;
    reg [7:0] _84;
    wire [7:0] _11;
    wire _26;
    wire [1:0] _23;
    wire _24;
    wire _27;
    wire [1:0] _97;
    wire vdd;
    wire _13;
    wire _15;
    wire _17;
    reg _87;
    wire _18;
    reg _90;
    wire _19;
    wire _60;
    wire _38;
    wire _61;
    wire [1:0] _98;
    reg [1:0] _101;
    wire [1:0] _20;
    wire _48;
    wire _49;
    wire [7:0] _104;
    reg [7:0] _107;
    wire [7:0] _21;
    assign _35 = 1'b0;
    assign _28 = ~ _19;
    assign _29 = _27 & _28;
    assign _31 = _29 ? vdd : _1;
    assign _33 = _5 ? _35 : _31;
    always @(posedge _15 or posedge _13) begin
        if (_13)
            _36 <= _35;
        else
            _36 <= _33;
    end
    assign _1 = _36;
    assign _39 = ~ _38;
    assign _40 = _27 & _19;
    assign _41 = _40 ? vdd : _6;
    assign _5 = consume;
    assign _43 = _5 ? _35 : _41;
    always @(posedge _15 or posedge _13) begin
        if (_13)
            _46 <= _35;
        else
            _46 <= _43;
    end
    assign _6 = _46;
    assign _106 = 8'b00000000;
    assign _102 = _21[7:1];
    assign _103 = { _19,
                    _102 };
    assign _100 = 2'b00;
    assign _93 = 4'b0111;
    assign _58 = 4'b0000;
    assign _52 = 4'b0001;
    assign _53 = _8 + _52;
    assign _51 = _8 == _93;
    assign _55 = _51 ? _58 : _53;
    assign _56 = _49 ? _55 : _8;
    always @(posedge _15 or posedge _13) begin
        if (_13)
            _59 <= _58;
        else
            _59 <= _56;
    end
    assign _8 = _59;
    assign _94 = _8 == _93;
    assign _95 = _94 ? _23 : _47;
    assign _47 = 2'b10;
    assign _91 = _19 ? _100 : _47;
    assign _92 = _64 ? _91 : _20;
    assign _96 = _49 ? _95 : _92;
    assign _79 = 8'b00000001;
    assign _77 = _10[7:1];
    assign gnd = 1'b0;
    assign _78 = { gnd,
                   _77 };
    assign _80 = _78 - _79;
    assign _10 = bit_period;
    assign _71 = _10 - _79;
    assign _68 = _11 - _79;
    assign _65 = _63 | _48;
    assign _66 = _65 | _24;
    assign _69 = _66 ? _68 : _11;
    assign _62 = 2'b01;
    assign _63 = _20 == _62;
    assign _64 = _63 & _26;
    assign _72 = _64 ? _71 : _69;
    assign _73 = _49 ? _71 : _72;
    assign _75 = _27 ? _106 : _73;
    assign _81 = _61 ? _80 : _75;
    always @(posedge _15 or posedge _13) begin
        if (_13)
            _84 <= _106;
        else
            _84 <= _81;
    end
    assign _11 = _84;
    assign _26 = _11 == _106;
    assign _23 = 2'b11;
    assign _24 = _20 == _23;
    assign _27 = _24 & _26;
    assign _97 = _27 ? _100 : _96;
    assign vdd = 1'b1;
    assign _13 = reset;
    assign _15 = clk;
    assign _17 = rx;
    always @(posedge _15 or posedge _13) begin
        if (_13)
            _87 <= _35;
        else
            _87 <= _17;
    end
    assign _18 = _87;
    always @(posedge _15 or posedge _13) begin
        if (_13)
            _90 <= _35;
        else
            _90 <= _18;
    end
    assign _19 = _90;
    assign _60 = ~ _19;
    assign _38 = _20 == _100;
    assign _61 = _38 & _60;
    assign _98 = _61 ? _62 : _97;
    always @(posedge _15 or posedge _13) begin
        if (_13)
            _101 <= _100;
        else
            _101 <= _98;
    end
    assign _20 = _101;
    assign _48 = _20 == _47;
    assign _49 = _48 & _26;
    assign _104 = _49 ? _103 : _21;
    always @(posedge _15 or posedge _13) begin
        if (_13)
            _107 <= _106;
        else
            _107 <= _104;
    end
    assign _21 = _107;
    assign data_out = _21;
    assign valid = _6;
    assign busy = _39;
    assign frame_error = _1;

endmodule
