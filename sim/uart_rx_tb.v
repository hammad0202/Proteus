`timescale 1ns/1ps

module uart_rx_tb;

    reg clk;
    reg reset;
    reg rx;
    reg [7:0] bit_period;
    reg consume;

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

    // Send one UART bit.
    task send_bit;
        input bit_value;
        begin
            rx = bit_value;
            #(80);
        end
    endtask

    // Send one UART byte, 8N1, LSB first.
    task send_uart_byte;
        input [7:0] data;
        integer k;
        begin
            // Start bit
            send_bit(1'b0);

            // Data bits, LSB first
            for (k = 0; k < 8; k = k + 1)
                send_bit(data[k]);

            // Stop bit
            send_bit(1'b1);

            // Return to idle
            rx = 1'b1;
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        rx = 1;
        bit_period = 8;
        consume = 0;

        $dumpfile("sim/uart_rx.vcd");
        $dumpvars(0, uart_rx_tb);

        $monitor(
            "time=%0t RX=%b BUSY=%b VALID=%b DATA=%h FRAME_ERR=%b",
            $time,
            rx,
            busy,
            valid,
            data_out,
            frame_error
        );

        // Reset
        #20;
        reset = 0;

        // Idle before transmission
        #40;

        $display("=== Sending byte 0x41 ('A') ===");

        send_uart_byte(8'h41);

        // Give receiver time to finish
        #100;

        $display("=== RX RESULT ===");
        $display("DATA = 0x%h", data_out);
        $display("VALID = %b", valid);
        $display("FRAME_ERROR = %b", frame_error);

        // Consume received byte
        consume = 1;
        #10;
        consume = 0;

        #20;

        $finish;
    end

endmodule
