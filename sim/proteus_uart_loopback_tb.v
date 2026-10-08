`timescale 1ns/1ps

module proteus_uart_loopback_tb;

    reg clk = 0;
    reg reset = 1;
    reg uart_rx = 1;
    reg spi_miso = 0;
    reg i2c_scl_in = 1;
    reg i2c_sda_in = 1;

    wire [7:0] pc;
    wire [15:0] instruction;
    wire [3:0] opcode;
    wire [3:0] register;
    wire [7:0] immediate;

    wire [31:0] r0, r1, r2, r3;

    wire gpio_out;
    wire shift_busy;
    wire uart_busy;

    wire spi_sclk;
    wire spi_mosi;
    wire spi_cs_n;
    wire spi_busy;
    wire [7:0] spi_data_out;
    wire spi_valid;

    wire i2c_scl_drive_low;
    wire i2c_sda_drive_low;
    wire i2c_busy;
    wire i2c_done;
    wire i2c_ack_error;

    reg [7:0] captured_byte;

    proteus_core dut (
        .clk(clk),
        .reset(reset),
        .uart_rx(uart_rx),
        .spi_miso(spi_miso),
        .i2c_scl_in(i2c_scl_in),
        .i2c_sda_in(i2c_sda_in),

        .pc(pc),
        .instruction(instruction),
        .opcode(opcode),
        .register(register),
        .immediate(immediate),

        .r0(r0),
        .r1(r1),
        .r2(r2),
        .r3(r3),

        .gpio_out(gpio_out),
        .shift_busy(shift_busy),
        .uart_busy(uart_busy),

        .spi_sclk(spi_sclk),
        .spi_mosi(spi_mosi),
        .spi_cs_n(spi_cs_n),
        .spi_busy(spi_busy),
        .spi_data_out(spi_data_out),
        .spi_valid(spi_valid),

        .i2c_scl_drive_low(i2c_scl_drive_low),
        .i2c_sda_drive_low(i2c_sda_drive_low),
        .i2c_busy(i2c_busy),
        .i2c_done(i2c_done),
        .i2c_ack_error(i2c_ack_error)
    );

    always #5 clk = ~clk;

    // Send one UART bit for exactly 8 clock cycles.
    task send_bit;
        input value;
        begin
            uart_rx = value;
            repeat (8) @(negedge clk);
        end
    endtask

    // Send a complete UART frame, LSB first.
    task send_uart_byte;
        input [7:0] data;
        integer k;
        begin
            send_bit(1'b0);

            for (k = 0; k < 8; k = k + 1)
                send_bit(data[k]);

            send_bit(1'b1);
            uart_rx = 1'b1;
        end
    endtask

    // Capture the CPU's transmitted UART byte.
    task capture_uart_byte;
        output [7:0] data;
        integer k;
        begin
            data = 8'h00;

            wait (uart_busy === 1'b1);

            // Sample halfway through the start bit.
            repeat (4) @(negedge clk);

            if (gpio_out !== 1'b0)
                $fatal(1, "UART TX start bit incorrect");

            // Sample the eight data bits.
            for (k = 0; k < 8; k = k + 1) begin
                repeat (8) @(negedge clk);
                data[k] = gpio_out;
            end

            // Check the stop bit.
            repeat (8) @(negedge clk);

            if (gpio_out !== 1'b1)
                $fatal(1, "UART TX stop bit incorrect");
        end
    endtask

    initial begin

        $dumpfile("sim/proteus_uart_loopback.vcd");
        $dumpvars(0, proteus_uart_loopback_tb);

        repeat (3) @(negedge clk);
        reset = 0;

        // Wait for the CPU to reach UART_RX.
        wait (pc == 8'd1);
        repeat (4) @(negedge clk);

        if (r1 !== 32'd8)
            $fatal(1, "UART bit period register incorrect");

        if (uart_busy !== 1'b0)
            $fatal(1, "UART transmitter unexpectedly busy");

        $display("");
        $display("========================================");
        $display("       CPU UART LOOPBACK TEST");
        $display("========================================");
        $display("Sending UART byte 0x41 ('A')");

        // Send input and capture output concurrently.
        fork

            begin
                send_uart_byte(8'h41);
            end

            begin
                capture_uart_byte(captured_byte);
            end

        join

        repeat (3) @(negedge clk);

        if (captured_byte !== 8'h41)
            $fatal(
                1,
                "UART loopback mismatch: expected 41, got %h",
                captured_byte
            );

        if (r0 !== 32'h00000041)
            $fatal(
                1,
                "CPU register mismatch: expected 00000041, got %h",
                r0
            );

        $display("");
        $display("Received by CPU  : 0x%02h", r0[7:0]);
        $display("Transmitted back : 0x%02h", captured_byte);
        $display("R0               : 0x%08h", r0);

        $display("========================================");
        $display("CPU UART LOOPBACK SUCCESS");
        $display("========================================");

        $finish;
    end

    initial begin
        #10000;
        $fatal(1, "CPU UART loopback simulation timeout");
    end

endmodule
