module proteus_gpio (
    reset,
    clk,
    write_data,
    write_enable,
    gpio_out
);

    input reset;
    input clk;
    input write_data;
    input write_enable;
    output gpio_out;

    wire vdd;
    wire _13;
    wire _2;
    wire _4;
    wire _6;
    wire _8;
    wire _11;
    reg _15;
    wire _9;
    assign vdd = 1'b1;
    assign _13 = 1'b0;
    assign _2 = reset;
    assign _4 = clk;
    assign _6 = write_data;
    assign _8 = write_enable;
    assign _11 = _8 ? _6 : _9;
    always @(posedge _4 or posedge _2) begin
        if (_2)
            _15 <= _13;
        else
            _15 <= _11;
    end
    assign _9 = _15;
    assign gpio_out = _9;

endmodule
