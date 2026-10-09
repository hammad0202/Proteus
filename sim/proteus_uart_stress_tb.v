`timescale 1ns/1ps

module proteus_uart_stress_tb;

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

    reg monitor_enabled = 0;

    reg [7:0] received_tx [0:127];

    integer tx_count = 0;
    integer total_scenarios = 0;
    integer complete_scenarios = 0;
    integer limited_scenarios = 0;
    integer i;

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

    function [7:0] pattern;
        input integer index;
        input integer mode;
        begin
            case (mode)
                0: pattern = (index * 37 + 65) & 8'hFF;
                1: pattern = (index % 2) ? 8'hFF : 8'h00;
                2: pattern = (index * 73 + 19) & 8'hFF;
                3: pattern = 8'h55;
                default: pattern = index & 8'hFF;
            endcase
        end
    endfunction

    task send_bit;
        input value;
        begin
            uart_rx = value;
            repeat (8) @(negedge clk);
        end
    endtask

    task send_byte;
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

    // Capture each complete UART transmission.
    always @(posedge uart_busy) begin : tx_monitor
        integer bit_index;
        reg [7:0] captured;

        if (monitor_enabled) begin
            captured = 8'h00;

            repeat (4) @(negedge clk);

            for (bit_index = 0; bit_index < 8;
                 bit_index = bit_index + 1) begin
                repeat (8) @(negedge clk);
                captured[bit_index] = gpio_out;
            end

            if (tx_count < 128)
                received_tx[tx_count] = captured;

            tx_count = tx_count + 1;
        end
    end

    task run_scenario;
        input integer count;
        input integer gap;
        input integer mode;

        integer index;
        integer correct;
        integer mismatches;
        integer inspected;
        integer delay_cycles;

        begin
            total_scenarios = total_scenarios + 1;

            monitor_enabled = 0;
            reset = 1;
            uart_rx = 1;

            repeat (5) @(negedge clk);

            tx_count = 0;

            for (index = 0; index < 128;
                 index = index + 1)
                received_tx[index] = 8'h00;

            reset = 0;

            wait (pc == 8'd1);
            repeat (4) @(negedge clk);

            if (r1 !== 32'd8)
                $fatal(1, "CPU UART configuration failed");

            monitor_enabled = 1;

            $display("");
            $display("----------------------------------------");
            $display(
                "SCENARIO %0d: bytes=%0d gap=%0d pattern=%0d",
                total_scenarios, count, gap, mode
            );

            for (index = 0; index < count;
                 index = index + 1) begin

                send_byte(pattern(index, mode));

                delay_cycles = gap;

                repeat (delay_cycles) @(negedge clk);
            end

            // Wait long enough for any outstanding echo.
            repeat (1500) @(negedge clk);

            monitor_enabled = 0;

            correct = 0;
            mismatches = 0;

            inspected = tx_count;

            if (inspected > count)
                inspected = count;

            for (index = 0; index < inspected;
                 index = index + 1) begin

                if (
                    received_tx[index] ===
                    pattern(index, mode)
                )
                    correct = correct + 1;
                else
                    mismatches = mismatches + 1;
            end

            $display("Expected bytes : %0d", count);
            $display("Echoed bytes   : %0d", tx_count);
            $display("Correct echoes : %0d", correct);
            $display("Mismatches     : %0d", mismatches);
            $display("Final PC       : %0d", pc);
            $display("Final R0       : %08h", r0);

            if (
                tx_count == count &&
                correct == count &&
                mismatches == 0
            ) begin
                complete_scenarios =
                    complete_scenarios + 1;

                $display("RESULT: COMPLETE");
            end
            else begin
                limited_scenarios =
                    limited_scenarios + 1;

                $display("RESULT: THROUGHPUT LIMIT OBSERVED");
            end
        end
    endtask

    initial begin
        $dumpfile("sim/proteus_uart_stress.vcd");
        $dumpvars(0, proteus_uart_stress_tb);

        $display("========================================");
        $display("    PROTEUS UART STRESS TEST BATCH");
        $display("========================================");

        // Known-good baseline from Test 15.
        run_scenario(2, 0, 0);

        // Continuous streams.
        run_scenario(10, 0, 0);
        run_scenario(50, 0, 0);
        run_scenario(100, 0, 0);

        // Alternating extreme bit patterns.
        run_scenario(50, 0, 1);

        // Different data distribution.
        run_scenario(50, 0, 2);

        // Increasing inter-frame spacing.
        run_scenario(50, 40, 0);
        run_scenario(50, 80, 0);
        run_scenario(50, 160, 0);

        // Long spaced stream.
        run_scenario(100, 160, 2);

        $display("");
        $display("========================================");
        $display("     PROTEUS STRESS TEST SUMMARY");
        $display("========================================");
        $display("Scenarios tested  : %0d", total_scenarios);
        $display("Complete scenarios: %0d", complete_scenarios);
        $display("Limited scenarios : %0d", limited_scenarios);
        $display("========================================");
        $display("PROTEUS STRESS CHARACTERIZATION COMPLETE");
        $display("========================================");

        $finish;
    end

    initial begin
        #2000000;
        $fatal(1, "PROTEUS stress test timed out");
    end

endmodule
