`timescale 1ns/1ps

module uart_error_recovery_tb;

    reg clk = 0;
    reg reset = 1;
    reg rx = 1;
    reg consume = 0;
    reg [7:0] bit_period = 8;

    wire [7:0] data_out;
    wire valid;
    wire busy;
    wire frame_error;

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

    task send_bit;
        input value;
        begin
            rx = value;
            repeat (8) @(negedge clk);
        end
    endtask

    task send_frame;
        input [7:0] data;
        input stop_bit;
        integer k;
        begin
            send_bit(1'b0);

            for (k = 0; k < 8; k = k + 1)
                send_bit(data[k]);

            send_bit(stop_bit);
            rx = 1'b1;

            // Allow receiver to return to IDLE.
            repeat (5) @(negedge clk);
        end
    endtask

    initial begin
        $dumpfile("sim/uart_error_recovery.vcd");
        $dumpvars(0, uart_error_recovery_tb);

        repeat (3) @(negedge clk);
        reset = 0;

        repeat (5) @(negedge clk);

        $display("========================================");
        $display("      UART ERROR RECOVERY TEST");
        $display("========================================");

        $display("Sending malformed frame: 0x41");

        send_frame(8'h41, 1'b0);

        if (frame_error !== 1'b1)
            $fatal(1, "Expected framing error was not detected");

        if (valid !== 1'b0)
            $fatal(1, "Malformed frame incorrectly marked valid");

        $display("PASS: Framing error detected");

        $display("Sending valid frame: 0x55");

        send_frame(8'h55, 1'b1);

        if (valid !== 1'b1)
            $fatal(1, "Receiver failed to recover valid data");

        if (data_out !== 8'h55)
            $fatal(1,
                "Expected 0x55, received 0x%02h",
                data_out
            );

        $display("PASS: Valid byte received after malformed frame");

        if (frame_error !== 1'b0)
            $fatal(1,
                "Framing error remained asserted after valid frame"
            );

        $display("PASS: Framing error cleared");

        $display("========================================");
        $display("UART ERROR RECOVERY SUCCESS");
        $display("========================================");

        $finish;
    end

    initial begin
        #10000;
        $fatal(1, "UART recovery simulation timeout");
    end

endmodule
