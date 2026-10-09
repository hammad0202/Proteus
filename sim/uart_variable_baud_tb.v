`timescale 1ns/1ps

module uart_variable_baud_tb;

    reg clk = 0;
    reg reset = 1;
    reg rx = 1;
    reg consume = 0;
    reg [7:0] bit_period = 8'd8;

    wire [7:0] data_out;
    wire valid;
    wire busy;
    wire frame_error;

    integer passed = 0;

    uart_rx dut (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .bit_period(bit_period),
        .consume(consume),
        .data_out(data_out),
        .valid(valid),
        .busy(busy),
        .frame_error(frame_error)
    );

    always #5 clk = ~clk;

    // Send one UART bit at the configured bit period.
    task send_bit;
        input value;
        begin
            rx = value;
            repeat (bit_period) @(negedge clk);
        end
    endtask

    // Send a complete 8N1 UART frame.
    task send_uart_byte;
        input [7:0] data;
        integer k;
        begin
            send_bit(1'b0);

            for (k = 0; k < 8; k = k + 1)
                send_bit(data[k]);

            send_bit(1'b1);
            rx = 1'b1;
        end
    endtask

    // Verify reception at a particular bit period.
    task test_baud;
        input [7:0] period;
        input [7:0] expected;
        begin

            // Change speed only while the receiver is idle.
            if (busy !== 1'b0)
                $fatal(1, "Receiver busy before baud change");

            if (valid !== 1'b0)
                $fatal(1, "Previous byte not consumed");

            rx = 1'b1;
            bit_period = period;

            repeat (5) @(negedge clk);

            $display("");
            $display(
                "Testing bit period=%0d, byte=0x%02h",
                period,
                expected
            );

            send_uart_byte(expected);

            repeat (5) @(negedge clk);

            if (data_out !== expected)
                $fatal(
                    1,
                    "Data mismatch at period %0d: expected %02h, got %02h",
                    period,
                    expected,
                    data_out
                );

            if (valid !== 1'b1)
                $fatal(
                    1,
                    "Valid not asserted at period %0d",
                    period
                );

            if (frame_error !== 1'b0)
                $fatal(
                    1,
                    "Unexpected framing error at period %0d",
                    period
                );

            if (busy !== 1'b0)
                $fatal(
                    1,
                    "Receiver remained busy at period %0d",
                    period
                );

            passed = passed + 1;

            $display(
                "PASS %0d: period=%0d RX=0x%02h",
                passed,
                period,
                data_out
            );

            // Acknowledge the received byte.
            consume = 1'b1;
            @(negedge clk);
            consume = 1'b0;

            if (valid !== 1'b0)
                $fatal(
                    1,
                    "Valid flag failed to clear after consume"
                );

            repeat (5) @(negedge clk);
        end
    endtask

    initial begin

        $dumpfile("sim/uart_variable_baud.vcd");
        $dumpvars(0, uart_variable_baud_tb);

        repeat (3) @(negedge clk);
        reset = 0;

        repeat (5) @(negedge clk);

        $display("========================================");
        $display("    UART VARIABLE BAUD-RATE TEST");
        $display("========================================");

        test_baud(8'd8,  8'h41);
        test_baud(8'd12, 8'h55);
        test_baud(8'd16, 8'hA5);
        test_baud(8'd32, 8'h3C);

        if (passed !== 4)
            $fatal(
                1,
                "Expected 4 successful baud-rate tests"
            );

        $display("");
        $display("========================================");
        $display("UART VARIABLE BAUD SUCCESS");
        $display("Bit periods verified: 4");
        $display("========================================");

        $finish;
    end

    initial begin
        #20000;
        $fatal(1, "UART variable baud simulation timeout");
    end

endmodule
