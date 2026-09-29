module proteus_program_counter (
    reset,
    clk,
    enable,
    pc
);

    input reset;
    input clk;
    input enable;
    output [7:0] pc;

    wire vdd;
    wire [7:0] _13;
    wire _2;
    wire _4;
    wire [7:0] _9;
    wire [7:0] _10;
    wire _6;
    wire [7:0] _11;
    reg [7:0] _15;
    wire [7:0] _7;
    assign vdd = 1'b1;
    assign _13 = 8'b00000000;
    assign _2 = reset;
    assign _4 = clk;
    assign _9 = 8'b00000001;
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
    assign pc = _7;

endmodule
