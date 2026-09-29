`timescale 1ns/1ps

module register_file_tb;

    reg clk;
    reg reset;
    reg write_enable;
    reg [1:0] write_register;
    reg [31:0] write_data;
    reg [1:0] read_register;

    wire [31:0] read_data;

    proteus_register_file dut (
        .clk(clk),
        .reset(reset),
        .write_enable(write_enable),
        .write_register(write_register),
        .write_data(write_data),
        .read_register(read_register),
        .read_data(read_data)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        write_enable = 0;
        write_register = 0;
        write_data = 0;
        read_register = 0;

        $monitor("time=%0t write_en=%b write_reg=%d write_data=%h read_reg=%d read_data=%h",
                 $time,
                 write_enable,
                 write_register,
                 write_data,
                 read_register,
                 read_data);

        #12 reset = 0;

        // R0 = 5
        #1;
        write_enable = 1;
        write_register = 0;
        write_data = 32'd5;

        #9;

        // R1 = 10
        write_register = 1;
        write_data = 32'd10;

        #10;

        // R2 = 20
        write_register = 2;
        write_data = 32'd20;

        #9;

        // Stop writing
        write_enable = 0;

        // Read R0
        #1;
        read_register = 0;
        #10;

        // Read R1
        read_register = 1;
        #10;

        // Read R2
        read_register = 2;
        #10;

        // Read R3
        read_register = 3;
        #10;

        $finish;
    end

endmodule
