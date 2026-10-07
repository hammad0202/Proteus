module spi_master (
    data_in,
    clock_period,
    reset,
    clk,
    start,
    sclk,
    mosi,
    cs_n,
    busy,
    done_
);

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

    wire _30;
    wire [7:0] _39;
    wire [7:0] _5;
    wire _34;
    wire [6:0] _33;
    wire [7:0] _35;
    wire _31;
    wire _32;
    wire [7:0] _36;
    wire [7:0] _37;
    reg [7:0] _41;
    wire [7:0] _6;
    wire _42;
    wire _72;
    wire _73;
    wire [3:0] _27;
    wire _28;
    wire [7:0] _56;
    wire [7:0] _48;
    wire [7:0] _9;
    wire _47;
    wire [7:0] _49;
    wire [6:0] _50;
    wire gnd;
    wire [7:0] _51;
    wire _53;
    wire [7:0] _55;
    wire [7:0] _57;
    wire [7:0] _44;
    wire [7:0] _58;
    wire [7:0] _59;
    wire [7:0] _60;
    reg [7:0] _63;
    wire [7:0] _10;
    wire _24;
    wire [3:0] _20;
    wire vdd;
    wire _12;
    wire _14;
    wire [3:0] _67;
    wire [3:0] _65;
    wire [3:0] _66;
    wire [3:0] _68;
    reg [3:0] _71;
    wire [3:0] _15;
    wire _21;
    wire _22;
    wire _25;
    wire _26;
    wire _29;
    wire _74;
    wire _17;
    wire _75;
    reg _78;
    wire _18;
    assign _30 = ~ _22;
    assign _39 = 8'b00000000;
    assign _5 = data_in;
    assign _34 = 1'b0;
    assign _33 = _6[6:0];
    assign _35 = { _33,
                   _34 };
    assign _31 = ~ _28;
    assign _32 = _26 & _31;
    assign _36 = _32 ? _35 : _6;
    assign _37 = _17 ? _5 : _36;
    always @(posedge _14 or posedge _12) begin
        if (_12)
            _41 <= _39;
        else
            _41 <= _37;
    end
    assign _6 = _41;
    assign _42 = _6[7:7];
    assign _72 = ~ _18;
    assign _73 = _25 ? _72 : _18;
    assign _27 = 4'b0001;
    assign _28 = _15 == _27;
    assign _56 = 8'b00000001;
    assign _48 = 8'b00000010;
    assign _9 = clock_period;
    assign _47 = _9 == _39;
    assign _49 = _47 ? _48 : _9;
    assign _50 = _49[7:1];
    assign gnd = 1'b0;
    assign _51 = { gnd,
                   _50 };
    assign _53 = _51 == _39;
    assign _55 = _53 ? _56 : _51;
    assign _57 = _55 - _56;
    assign _44 = _10 - _56;
    assign _58 = _24 ? _57 : _44;
    assign _59 = _22 ? _58 : _10;
    assign _60 = _17 ? _57 : _59;
    always @(posedge _14 or posedge _12) begin
        if (_12)
            _63 <= _39;
        else
            _63 <= _60;
    end
    assign _10 = _63;
    assign _24 = _10 == _39;
    assign _20 = 4'b0000;
    assign vdd = 1'b1;
    assign _12 = reset;
    assign _14 = clk;
    assign _67 = 4'b1000;
    assign _65 = _15 - _27;
    assign _66 = _26 ? _65 : _15;
    assign _68 = _17 ? _67 : _66;
    always @(posedge _14 or posedge _12) begin
        if (_12)
            _71 <= _20;
        else
            _71 <= _68;
    end
    assign _15 = _71;
    assign _21 = _15 == _20;
    assign _22 = ~ _21;
    assign _25 = _22 & _24;
    assign _26 = _25 & _18;
    assign _29 = _26 & _28;
    assign _74 = _29 ? gnd : _73;
    assign _17 = start;
    assign _75 = _17 ? gnd : _74;
    always @(posedge _14 or posedge _12) begin
        if (_12)
            _78 <= _34;
        else
            _78 <= _75;
    end
    assign _18 = _78;
    assign sclk = _18;
    assign mosi = _42;
    assign cs_n = _30;
    assign busy = _22;
    assign done_ = _29;

endmodule
