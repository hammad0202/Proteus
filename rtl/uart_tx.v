module uart_tx (
    data_in,
    bit_period,
    reset,
    clk,
    start,
    tx,
    busy,
    done_
);

    input [7:0] data_in;
    input [7:0] bit_period;
    input reset;
    input clk;
    input start;
    output tx;
    output busy;
    output done_;

    wire [3:0] _23;
    wire _24;
    wire _25;
    wire [9:0] _53;
    wire _49;
    wire [7:0] _4;
    wire _48;
    wire [9:0] _50;
    wire [8:0] _44;
    wire [9:0] _46;
    wire [7:0] _20;
    wire [7:0] _28;
    wire [7:0] _6;
    wire [7:0] _29;
    wire [7:0] _27;
    wire [7:0] _30;
    wire [7:0] _31;
    reg [7:0] _35;
    wire [7:0] _7;
    wire _21;
    wire [3:0] _17;
    wire vdd;
    wire _9;
    wire _11;
    wire [3:0] _39;
    wire [3:0] _37;
    wire [3:0] _38;
    wire [3:0] _40;
    reg [3:0] _43;
    wire [3:0] _12;
    wire _18;
    wire _19;
    wire _22;
    wire [9:0] _47;
    wire _14;
    wire [9:0] _51;
    reg [9:0] _54;
    wire [9:0] _15;
    wire _55;
    assign _23 = 4'b0001;
    assign _24 = _12 == _23;
    assign _25 = _22 & _24;
    assign _53 = 10'b0000000000;
    assign _49 = 1'b0;
    assign _4 = data_in;
    assign _48 = 1'b1;
    assign _50 = { _48,
                   _4,
                   _49 };
    assign _44 = _15[8:0];
    assign _46 = { _44,
                   _48 };
    assign _20 = 8'b00000000;
    assign _28 = 8'b00000001;
    assign _6 = bit_period;
    assign _29 = _6 - _28;
    assign _27 = _7 - _28;
    assign _30 = _22 ? _29 : _27;
    assign _31 = _14 ? _29 : _30;
    always @(posedge _11 or posedge _9) begin
        if (_9)
            _35 <= _20;
        else
            _35 <= _31;
    end
    assign _7 = _35;
    assign _21 = _7 == _20;
    assign _17 = 4'b0000;
    assign vdd = 1'b1;
    assign _9 = reset;
    assign _11 = clk;
    assign _39 = 4'b1010;
    assign _37 = _12 - _23;
    assign _38 = _22 ? _37 : _12;
    assign _40 = _14 ? _39 : _38;
    always @(posedge _11 or posedge _9) begin
        if (_9)
            _43 <= _17;
        else
            _43 <= _40;
    end
    assign _12 = _43;
    assign _18 = _12 == _17;
    assign _19 = ~ _18;
    assign _22 = _19 & _21;
    assign _47 = _22 ? _46 : _15;
    assign _14 = start;
    assign _51 = _14 ? _50 : _47;
    always @(posedge _11 or posedge _9) begin
        if (_9)
            _54 <= _53;
        else
            _54 <= _51;
    end
    assign _15 = _54;
    assign _55 = _15[0:0];
    assign tx = _55;
    assign busy = _19;
    assign done_ = _25;

endmodule
