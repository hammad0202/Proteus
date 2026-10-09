`timescale 1ns/1ps

module proteus_uart_timing_tb;

    reg clk = 0;
    reg reset = 1;
    reg uart_rx = 1;
    reg spi_miso = 0;
    reg i2c_scl_in = 1;
    reg i2c_sda_in = 1;

    wire [7:0] pc;
    wire [15:0] instruction;
    wire [3:0] opcode, register;
    wire [7:0] immediate;
    wire [31:0] r0, r1, r2, r3;

    wire gpio_out, shift_busy, uart_busy;
    wire spi_sclk, spi_mosi, spi_cs_n, spi_busy;
    wire [7:0] spi_data_out;
    wire spi_valid;
    wire i2c_scl_drive_low, i2c_sda_drive_low;
    wire i2c_busy, i2c_done, i2c_ack_error;

    reg [7:0] captured_byte;
    integer k;

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
            repeat (16) @(negedge clk);
        end
    endtask

    task send_uart_byte;
        input [7:0] data;
        integer bit_index;
        begin
            send_bit(1'b0);

            for (bit_index = 0; bit_index < 8; bit_index = bit_index + 1)
                send_bit(data[bit_index]);

            send_bit(1'b1);
            uart_rx = 1'b1;
        end
    endtask

    task capture_uart_byte;
        output [7:0] data;
        integer bit_index;
        begin
            data = 8'h00;

            wait (uart_busy === 1'b1);

            repeat (8) @(negedge clk);

            if (gpio_out !== 1'b0)
                $fatal(1, "Incorrect UART TX start bit");

            for (bit_index = 0; bit_index < 8; bit_index = bit_index + 1) begin
                repeat (16) @(negedge clk);
                data[bit_index] = gpio_out;
            end

            repeat (16) @(negedge clk);

            if (gpio_out !== 1'b1)
                $fatal(1, "Incorrect UART TX stop bit");
        end
    endtask

    initial begin
        $dumpfile("sim/proteus_uart_timing.vcd");
        $dumpvars(0, proteus_uart_timing_tb);

        repeat (3) @(negedge clk);
        reset = 0;

        wait (pc == 8'd1);
        repeat (4) @(negedge clk);

        $display("========================================");
        $display("     CPU UART TIMING TEST");
        $display("========================================");

        if (r1 !== 32'd16)
            $fatal(1, "CPU did not configure UART period to 16");

        if (instruction !== 16'hC000)
            $fatal(1, "CPU is not waiting at UART_RX");

        $display("PASS: CPU configured R1=16");
        $display("Sending UART byte 0xA5");

        fork
            begin
                send_uart_byte(8'hA5);
            end
            begin
                capture_uart_byte(captured_byte);
            end
        join

        repeat (3) @(negedge clk);

        if (captured_byte !== 8'hA5)
            $fatal(
                1,
                "UART TX mismatch: expected A5, got %02h",
                captured_byte
            );

        if (r0 !== 32'h000000A5)
            $fatal(
                1,
                "UART RX register mismatch: expected A5, got %08h",
                r0
            );

        $display("PASS: CPU received 0xA5");
        $display("PASS: CPU transmitted 0xA5");
        $display("PASS: UART timing=16 clock cycles");

        $display("========================================");
        $display("CPU UART TIMING SUCCESS");
        $display("========================================");

        $finish;
    end

    initial begin
        #15000;
        $fatal(1, "CPU UART timing simulation timeout");
    end

endmodule
