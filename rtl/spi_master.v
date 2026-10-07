module spi_master (
    miso,
    data_in,
    clock_period,
    reset,
    clk,
    start,
    sclk,
    mosi,
    cs_n,
    busy,
    done_,
    data_out,
    valid
);

    input miso;
    input [7:0] data_in;
    input [7:0] clock_period;
    input reset;
    input clk;
    input start;
    output sclk;
    output mosi;
    output cs_n;
    output busy;
    output done_;
    output [7:0] data_out;
    output valid;

    wire _38;
    reg _40;
    wire _1;
    wire [7:0] _53;
    wire _4;
    wire [6:0] _43;
    wire [7:0] _44;
    wire _41;
    wire _42;
    wire [7:0] _45;
    wire [7:0] _47;
    reg [7:0] _50;
    wire [7:0] _5;
    wire [7:0] _51;
    reg [7:0] _54;
    wire [7:0] _6;
    wire _55;
    wire [7:0] _12;
    wire [6:0] _58;
    wire [7:0] _60;
    wire _56;
    wire _57;
    wire [7:0] _61;
    wire [7:0] _62;
    reg [7:0] _65;
    wire [7:0] _13;
    wire _66;
    wire _96;
    wire _97;
    wire [3:0] _34;
    wire _35;
    wire [7:0] _80;
    wire [7:0] _72;
    wire [7:0] _16;
    wire _71;
    wire [7:0] _73;
    wire [6:0] _74;
    wire gnd;
    wire [7:0] _75;
    wire _77;
    wire [7:0] _79;
    wire [7:0] _81;
    wire [7:0] _68;
    wire [7:0] _82;
    wire [7:0] _83;
    wire [7:0] _84;
    reg [7:0] _87;
    wire [7:0] _17;
    wire _31;
    wire [3:0] _27;
    wire vdd;
    wire _19;
    wire _21;
    wire [3:0] _91;
    wire [3:0] _89;
    wire [3:0] _90;
    wire [3:0] _92;
    reg [3:0] _95;
    wire [3:0] _22;
    wire _28;
    wire _29;
    wire _32;
    wire _33;
    wire _36;
    wire _98;
    wire _24;
    wire _99;
    reg _102;
    wire _25;
    assign _38 = 1'b0;
    always @(posedge _21 or posedge _19) begin
        if (_19)
            _40 <= _38;
        else
            _40 <= _36;
    end
    assign _1 = _40;
    assign _53 = 8'b00000000;
    assign _4 = miso;
    assign _43 = _5[6:0];
    assign _44 = { _43,
                   _4 };
    assign _41 = ~ _25;
    assign _42 = _32 & _41;
    assign _45 = _42 ? _44 : _5;
    assign _47 = _24 ? _53 : _45;
    always @(posedge _21 or posedge _19) begin
        if (_19)
            _50 <= _53;
        else
            _50 <= _47;
    end
    assign _5 = _50;
    assign _51 = _36 ? _5 : _6;
    always @(posedge _21 or posedge _19) begin
        if (_19)
            _54 <= _53;
        else
            _54 <= _51;
    end
    assign _6 = _54;
    assign _55 = ~ _29;
    assign _12 = data_in;
    assign _58 = _13[6:0];
    assign _60 = { _58,
                   _38 };
    assign _56 = ~ _35;
    assign _57 = _33 & _56;
    assign _61 = _57 ? _60 : _13;
    assign _62 = _24 ? _12 : _61;
    always @(posedge _21 or posedge _19) begin
        if (_19)
            _65 <= _53;
        else
            _65 <= _62;
    end
    assign _13 = _65;
    assign _66 = _13[7:7];
    assign _96 = ~ _25;
    assign _97 = _32 ? _96 : _25;
    assign _34 = 4'b0001;
    assign _35 = _22 == _34;
    assign _80 = 8'b00000001;
    assign _72 = 8'b00000010;
    assign _16 = clock_period;
    assign _71 = _16 == _53;
    assign _73 = _71 ? _72 : _16;
    assign _74 = _73[7:1];
    assign gnd = 1'b0;
    assign _75 = { gnd,
                   _74 };
    assign _77 = _75 == _53;
    assign _79 = _77 ? _80 : _75;
    assign _81 = _79 - _80;
    assign _68 = _17 - _80;
    assign _82 = _31 ? _81 : _68;
    assign _83 = _29 ? _82 : _17;
    assign _84 = _24 ? _81 : _83;
    always @(posedge _21 or posedge _19) begin
        if (_19)
            _87 <= _53;
        else
            _87 <= _84;
    end
    assign _17 = _87;
    assign _31 = _17 == _53;
    assign _27 = 4'b0000;
    assign vdd = 1'b1;
    assign _19 = reset;
    assign _21 = clk;
    assign _91 = 4'b1000;
    assign _89 = _22 - _34;
    assign _90 = _33 ? _89 : _22;
    assign _92 = _24 ? _91 : _90;
    always @(posedge _21 or posedge _19) begin
        if (_19)
            _95 <= _27;
        else
            _95 <= _92;
    end
    assign _22 = _95;
    assign _28 = _22 == _27;
    assign _29 = ~ _28;
    assign _32 = _29 & _31;
    assign _33 = _32 & _25;
    assign _36 = _33 & _35;
    assign _98 = _36 ? gnd : _97;
    assign _24 = start;
    assign _99 = _24 ? gnd : _98;
    always @(posedge _21 or posedge _19) begin
        if (_19)
            _102 <= _38;
        else
            _102 <= _99;
    end
    assign _25 = _102;
    assign sclk = _25;
    assign mosi = _66;
    assign cs_n = _55;
    assign busy = _29;
    assign done_ = _36;
    assign data_out = _6;
    assign valid = _1;

endmodule
