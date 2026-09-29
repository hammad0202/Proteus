module proteus_shift_out (
    reset,
    clk,
    data_in,
    shift,
    load,
    data_out,
    busy
);

    input reset;
    input clk;
    input [7:0] data_in;
    input shift;
    input load;
    output data_out;
    output busy;

    wire [3:0] _24;
    wire [3:0] _18;
    wire [3:0] _15;
    wire [3:0] _16;
    wire [3:0] _17;
    wire [3:0] _19;
    reg [3:0] _23;
    wire [3:0] _1;
    wire _25;
    wire _26;
    wire vdd;
    wire [7:0] _33;
    wire _4;
    wire _6;
    wire [7:0] _8;
    wire _28;
    wire [6:0] _27;
    wire [7:0] _29;
    wire _10;
    wire [7:0] _30;
    wire _12;
    wire [7:0] _31;
    reg [7:0] _34;
    wire [7:0] _13;
    wire _35;
    assign _24 = 4'b0000;
    assign _18 = 4'b1000;
    assign _15 = 4'b0001;
    assign _16 = _1 - _15;
    assign _17 = _10 ? _16 : _1;
    assign _19 = _12 ? _18 : _17;
    always @(posedge _6 or posedge _4) begin
        if (_4)
            _23 <= _24;
        else
            _23 <= _19;
    end
    assign _1 = _23;
    assign _25 = _1 == _24;
    assign _26 = ~ _25;
    assign vdd = 1'b1;
    assign _33 = 8'b00000000;
    assign _4 = reset;
    assign _6 = clk;
    assign _8 = data_in;
    assign _28 = 1'b0;
    assign _27 = _13[6:0];
    assign _29 = { _27,
                   _28 };
    assign _10 = shift;
    assign _30 = _10 ? _29 : _13;
    assign _12 = load;
    assign _31 = _12 ? _8 : _30;
    always @(posedge _6 or posedge _4) begin
        if (_4)
            _34 <= _33;
        else
            _34 <= _31;
    end
    assign _13 = _34;
    assign _35 = _13[7:7];
    assign data_out = _35;
    assign busy = _26;

endmodule
