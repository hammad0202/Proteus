`timescale 1ns/1ps

module uart_tx_tb;

    reg clk;
    reg reset;
    reg start;
    reg [7:0] data_in;
    reg [7:0] bit_period;

    wire tx;
    wire busy;
    wire done;

    uart_tx dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .data_in(data_in),
        .bit_period(bit_period),
        .tx(tx),
        .busy(busy),
        .done_(done)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        start = 0;
        data_in = 8'hA5;
        bit_period = 8'd8;

        $dumpfile("sim/uart_tx.vcd");
        $dumpvars(0, uart_tx_tb);

        $monitor(
            "time=%0t TX=%b BUSY=%b DONE=%b",
            $time,
            tx,
            busy,
            done
        );

        #12 reset = 0;

        // Start UART transmission of 0xA5
        #8 start = 1;
        #10 start = 0;

        // 10 bits × 8 clock cycles × 10 ns = 800 ns
        #900 $finish;
    end

endmodule
