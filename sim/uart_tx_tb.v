`timescale 1ns/1ps

module uart_tx_tb;

    reg clk = 0;
    reg reset = 1;
    reg start = 0;
    reg [7:0] data_in = 8'hA5;
    reg [7:0] bit_period = 8'd8;

    wire tx;
    wire busy;
    wire done_;

    integer bit_index;
    integer done_count = 0;

    reg [9:0] expected_frame;

    uart_tx dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .data_in(data_in),
        .bit_period(bit_period),
        .tx(tx),
        .busy(busy),
        .done_(done_)
    );

    always #5 clk = ~clk;

    // Count completion pulses.
    always @(posedge clk) begin
        if (!reset && done_ === 1'b1)
            done_count = done_count + 1;
    end

    initial begin
        $dumpfile("sim/uart_tx.vcd");
        $dumpvars(0, uart_tx_tb);

        expected_frame = {1'b1, data_in, 1'b0};

        repeat (3) @(negedge clk);
        reset = 0;

        repeat (2) @(negedge clk);

        if (tx !== 1'b1)
            $fatal(1, "UART TX idle level incorrect");

        // Start the UART transmission.
        start = 1;
        @(negedge clk);
        start = 0;

        if (busy !== 1'b1)
            $fatal(1, "UART TX did not become busy");

        // We are now at the beginning of the start bit.
        // Move four cycles to its center.
        repeat (4) @(negedge clk);

        // Check all 10 frame bits at their centers.
        for (bit_index = 0; bit_index < 10; bit_index = bit_index + 1) begin

            if (tx !== expected_frame[bit_index]) begin
                $display(
                    "ERROR: Bit %0d expected %b got %b at %0t",
                    bit_index,
                    expected_frame[bit_index],
                    tx,
                    $time
                );
                $fatal(1, "UART TX frame mismatch");
            end

            // Advance one complete UART bit.
            repeat (8) @(negedge clk);
        end

        // Transmission should now be complete.
        if (busy !== 1'b0)
            $fatal(1, "UART TX remained busy");

        if (tx !== 1'b1)
            $fatal(1, "UART TX did not return to idle high");

        if (done_count !== 1)
            $fatal(
                1,
                "UART TX done count incorrect: %0d",
                done_count
            );

        $display("");
        $display("========================================");
        $display("          UART TX VERIFICATION");
        $display("========================================");
        $display("Transmitted byte : 0x%02h", data_in);
        $display("Frame bits       : 10");
        $display("Done count       : %0d", done_count);
        $display("========================================");
        $display("UART TX SUCCESS");
        $display("========================================");

        $finish;
    end

    initial begin
        #5000;
        $fatal(1, "UART TX simulation timeout");
    end

endmodule
