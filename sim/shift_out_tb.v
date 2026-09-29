`timescale 1ns/1ps

module shift_out_tb;

    reg clk;
    reg reset;
    reg load;
    reg shift;
    reg [7:0] data_in;

    wire data_out;
    wire busy;

    proteus_shift_out dut (
        .clk(clk),
        .reset(reset),
        .load(load),
        .shift(shift),
        .data_in(data_in),
        .data_out(data_out),
        .busy(busy)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        load = 0;
        shift = 0;
        data_in = 8'b10110010;

        $dumpfile("sim/shift_out.vcd");
        $dumpvars(1, shift_out_tb);

        $monitor(
            "time=%0t load=%b shift=%b data_in=%b | data_out=%b busy=%b",
            $time,
            load,
            shift,
            data_in,
            data_out,
            busy
        );

        #12 reset = 0;

        // Load 10110010
        #2;
        load = 1;

        #8;
        load = 0;

        // Shift 8 bits
        #8; shift = 1;
        #10; shift = 0;

        #8; shift = 1;
        #10; shift = 0;

        #8; shift = 1;
        #10; shift = 0;

        #8; shift = 1;
        #10; shift = 0;

        #8; shift = 1;
        #10; shift = 0;

        #8; shift = 1;
        #10; shift = 0;

        #8; shift = 1;
        #10; shift = 0;

        #8; shift = 1;
        #10; shift = 0;

        #20 $finish;
    end

endmodule
