`timescale 1ns/1ps

module uart_rx_tb;

    reg clk = 0;
    reg reset = 1;
    reg rx = 1;
    reg [7:0] bit_period = 8'd8;
    reg consume = 0;

    wire [7:0] data_out;
    wire valid;
    wire busy;
    wire frame_error;

    integer k;

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

    // Each UART bit lasts exactly 8 clock cycles.
    task send_bit;
        input value;
        begin
            rx = value;
            repeat (8) @(negedge clk);
        end
    endtask

    // Transmit an 8N1 UART frame, LSB first.
    task send_uart_byte;
        input [7:0] data;
        begin
            send_bit(1'b0);

            for (k = 0; k < 8; k = k + 1)
                send_bit(data[k]);

            send_bit(1'b1);
            rx = 1'b1;
        end
    endtask

    initial begin
        $dumpfile("sim/uart_rx.vcd");
        $dumpvars(0, uart_rx_tb);

        repeat (3) @(negedge clk);
        reset = 0;

        repeat (4) @(negedge clk);

        if (valid !== 1'b0)
            $fatal(1, "UART RX valid asserted during idle");

        $display("Sending UART byte 0x41");

        send_uart_byte(8'h41);

        repeat (5) @(negedge clk);

        if (data_out !== 8'h41)
            $fatal(
                1,
                "UART RX data mismatch: expected 41, got %h",
                data_out
            );

        if (valid !== 1'b1)
            $fatal(1, "UART RX valid not asserted");

        if (frame_error !== 1'b0)
            $fatal(1, "UART RX unexpected frame error");

        if (busy !== 1'b0)
            $fatal(1, "UART RX remained busy");

        // Consume the received byte.
        consume = 1;
        @(negedge clk);
        consume = 0;

        if (valid !== 1'b0)
            $fatal(1, "UART RX valid did not clear");

        $display("");
        $display("========================================");
        $display("          UART RX VERIFICATION");
        $display("========================================");
        $display("Received byte : 0x%02h", data_out);
        $display("Frame error   : %b", frame_error);
        $display("========================================");
        $display("UART RX SUCCESS");
        $display("========================================");

        $finish;
    end

    initial begin
        #5000;
        $fatal(1, "UART RX simulation timeout");
    end

endmodule
