`timescale 1ns/1ps

module proteus_uart_stream_tb;

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
    wire gpio_out, shift_busy, uart_busy;

    wire spi_sclk, spi_mosi, spi_cs_n, spi_busy;
    wire [7:0] spi_data_out;
    wire spi_valid;

    wire i2c_scl_drive_low, i2c_sda_drive_low;
    wire i2c_busy, i2c_done, i2c_ack_error;

    reg [7:0] captured_byte;
    integer passed = 0;

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
        .r0(r0), .r1(r1), .r2(r2), .r3(r3),
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

    task send_bit;
        input value;
        begin
            uart_rx = value;
            repeat (8) @(negedge clk);
        end
    endtask

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

    task capture_uart_byte;
        output [7:0] data;
        integer k;
        begin
            data = 8'h00;

            wait (uart_busy === 1'b1);

            repeat (4) @(negedge clk);

            if (gpio_out !== 1'b0)
                $fatal(1, "UART TX start bit incorrect");

            for (k = 0; k < 8; k = k + 1) begin
                repeat (8) @(negedge clk);
                data[k] = gpio_out;
            end

            repeat (8) @(negedge clk);

            if (gpio_out !== 1'b1)
                $fatal(1, "UART TX stop bit incorrect");
        end
    endtask

    task test_byte;
        input [7:0] expected;
        begin
            // Ensure the previous transmission has finished
            // and the CPU is waiting for another received byte.
            wait (uart_busy === 1'b0);
            wait (pc == 8'd1);
            repeat (4) @(negedge clk);

            $display("Sending: 0x%02h", expected);

            fork
                begin
                    send_uart_byte(expected);
                end
                begin
                    capture_uart_byte(captured_byte);
                end
            join

            repeat (3) @(negedge clk);

            if (captured_byte !== expected)
                $fatal(
                    1,
                    "Loopback mismatch: expected %02h, got %02h",
                    expected,
                    captured_byte
                );

            if (r0 !== {24'h000000, expected})
                $fatal(
                    1,
                    "Register mismatch: expected %02h, got %08h",
                    expected,
                    r0
                );

            passed = passed + 1;

            $display(
                "PASS %0d: RX=0x%02h TX=0x%02h R0=0x%08h",
                passed,
                expected,
                captured_byte,
                r0
            );
        end
    endtask

    initial begin
        $dumpfile("sim/proteus_uart_stream.vcd");
        $dumpvars(0, proteus_uart_stream_tb);

        repeat (3) @(negedge clk);
        reset = 0;

        wait (pc == 8'd1);
        repeat (4) @(negedge clk);

        if (r1 !== 32'd8)
            $fatal(1, "UART bit period configuration incorrect");

        $display("");
        $display("========================================");
        $display("     CPU UART STREAM TEST");
        $display("========================================");

        test_byte(8'h41);
        test_byte(8'h55);
        test_byte(8'hA5);
        test_byte(8'h00);

        if (passed !== 4)
            $fatal(1, "Expected four successful loopbacks");

        $display("");
        $display("========================================");
        $display("CPU UART STREAM SUCCESS");
        $display("Bytes verified: %0d", passed);
        $display("========================================");

        $finish;
    end

    initial begin
        #20000;
        $fatal(1, "CPU UART stream simulation timeout");
    end

endmodule
