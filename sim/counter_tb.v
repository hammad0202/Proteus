`timescale 1ns/1ps

module counter_tb;

    reg clk;
    reg reset;
    reg enable;
    wire [31:0] count;

    proteus_counter dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .count(count)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        enable = 0;

        $dumpfile("sim/counter.vcd");
        $dumpvars(0, counter_tb);
        $monitor("time=%0t reset=%b enable=%b count=%d",
                 $time, reset, enable, count);

        #20 reset = 0;
        #20 enable = 1;
        #100 enable = 0;
        #30 $finish;
    end

endmodule
