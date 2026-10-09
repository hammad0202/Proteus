`timescale 1ns/1ps

module proteus_uart_gap_tb;

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

    integer tx_count = 0;
    integer passing_scenarios = 0;
    integer limited_scenarios = 0;
    integer minimum_passing_gap = -1;

    integer gap_values [0:5];
    integer scenario;

    reg [7:0] tx_bytes [0:1];
    reg monitor_enabled = 0;

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

    // Capture transmissions continuously.
    // Sampling begins halfway through the start bit.
    always @(posedge uart_busy) begin : tx_capture
        integer k;
        reg [7:0] captured;

        if (monitor_enabled) begin
            captured = 8'h00;

            repeat (4) @(negedge clk);

            if (gpio_out !== 1'b0)
                $display("WARNING: Unexpected TX start bit");

            for (k = 0; k < 8; k = k + 1) begin
                repeat (8) @(negedge clk);
                captured[k] = gpio_out;
            end

            if (tx_count < 2)
                tx_bytes[tx_count] = captured;

            tx_count = tx_count + 1;
        end
    end

    task run_scenario;
        input integer gap_cycles;
        begin
            monitor_enabled = 0;
            reset = 1'b1;
            uart_rx = 1'b1;

            repeat (5) @(negedge clk);

            tx_count = 0;
            tx_bytes[0] = 8'h00;
            tx_bytes[1] = 8'h00;

            reset = 1'b0;

            wait (pc == 8'd1);
            repeat (4) @(negedge clk);

            if (r1 !== 32'd8)
                $fatal(1, "UART configuration incorrect");

            $display("");
            $display("Testing gap = %0d cycles", gap_cycles);

            monitor_enabled = 1;

            send_uart_byte(8'h41);

            repeat (gap_cycles) @(negedge clk);

            send_uart_byte(8'h55);

            // Both input frames have now completed.
            // Give the CPU time to finish any pending TX.
            repeat (250) @(negedge clk);

            monitor_enabled = 0;

            $display(
                "Observed: TX_count=%0d TX0=%02h TX1=%02h R0=%08h PC=%0d",
                tx_count,
                tx_bytes[0],
                tx_bytes[1],
                r0,
                pc
            );

            if (
                tx_count == 2 &&
                tx_bytes[0] === 8'h41 &&
                tx_bytes[1] === 8'h55 &&
                r0 === 32'h00000055
            ) begin
                passing_scenarios = passing_scenarios + 1;

                if (
                    minimum_passing_gap == -1 ||
                    gap_cycles < minimum_passing_gap
                )
                    minimum_passing_gap = gap_cycles;

                $display(
                    "PASS: gap=%0d both bytes echoed correctly",
                    gap_cycles
                );
            end
            else begin
                limited_scenarios = limited_scenarios + 1;

                $display(
                    "LIMITATION: gap=%0d did not produce two verified echoes",
                    gap_cycles
                );
            end
        end
    endtask

    initial begin
        $dumpfile("sim/proteus_uart_gap.vcd");
        $dumpvars(0, proteus_uart_gap_tb);

        gap_values[0] = 0;
        gap_values[1] = 8;
        gap_values[2] = 40;
        gap_values[3] = 80;
        gap_values[4] = 160;
        gap_values[5] = 240;

        $display("========================================");
        $display("  CPU UART INTER-FRAME GAP TEST");
        $display("========================================");

        for (scenario = 0; scenario < 6; scenario = scenario + 1)
            run_scenario(gap_values[scenario]);

        $display("");
        $display("========================================");
        $display("       GAP CHARACTERIZATION");
        $display("========================================");
        $display("Passing scenarios: %0d", passing_scenarios);
        $display("Limited scenarios: %0d", limited_scenarios);
        $display(
            "Smallest passing tested gap: %0d cycles",
            minimum_passing_gap
        );
        $display("========================================");
        $display("CPU UART GAP CHARACTERIZATION COMPLETE");
        $display("========================================");

        $finish;
    end

    initial begin
        #100000;
        $fatal(1, "UART gap characterization timeout");
    end

endmodule
