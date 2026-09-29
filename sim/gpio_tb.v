`timescale 1ns/1ps

module gpio_tb;

    reg clk;
    reg reset;
    reg write_enable;
    reg write_data;

    wire gpio_out;

    proteus_gpio dut (
        .clk(clk),
        .reset(reset),
        .write_enable(write_enable),
        .write_data(write_data),
        .gpio_out(gpio_out)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        write_enable = 0;
        write_data = 0;

        $dumpfile("sim/gpio.vcd");
        $dumpvars(1, gpio_tb);

        $monitor(
            "time=%0t reset=%b write_enable=%b write_data=%b | gpio_out=%b",
            $time,
            reset,
            write_enable,
            write_data,
            gpio_out
        );

#12 reset = 0;

// Write 1
#2;
write_enable = 1;
write_data = 1;

#8;
write_enable = 0;

// Hold 1
#10;

// Write 0
write_enable = 1;
write_data = 0;

#8;
write_enable = 0;

#10;
    end

endmodule
