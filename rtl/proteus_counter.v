module proteus_counter (
    reset,
    clk,
    enable,
    count
);

    input reset;
    input clk;
    input enable;
    output [31:0] count;

    wire vdd;
    wire [31:0] _13;
    wire _2;
    wire _4;
    wire [31:0] _9;
    wire [31:0] _10;
    wire _6;
    wire [31:0] _11;
    reg [31:0] _15;
    wire [31:0] _7;
    assign vdd = 1'b1;
    assign _13 = 32'b00000000000000000000000000000000;
    assign _2 = reset;
    assign _4 = clk;
    assign _9 = 32'b00000000000000000000000000000001;
    assign _10 = _7 + _9;
    assign _6 = enable;
    assign _11 = _6 ? _10 : _7;
    always @(posedge _4 or posedge _2) begin
        if (_2)
            _15 <= _13;
        else
            _15 <= _11;
    end
    assign _7 = _15;
    assign count = _7;

endmodule
