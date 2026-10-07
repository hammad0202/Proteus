`timescale 1ns/1ps

module spi_master_tb;

    reg clk;
    reg reset;
    reg start;

    reg [7:0] data_in;
    reg [7:0] clock_period;

    wire sclk;
    wire mosi;
    wire cs_n;
    wire busy;
    wire done_;

    reg [7:0] received_data;
    integer bit_count;

    spi_master dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .data_in(data_in),
        .clock_period(clock_period),
        .sclk(sclk),
        .mosi(mosi),
        .cs_n(cs_n),
        .busy(busy),
        .done_(done_)
    );

    /*
     * 100 MHz system clock.
     *
     * One system-clock cycle = 10 ns.
     */
    always #5 clk = ~clk;

    /*
     * SPI Mode 0 receiver model.
     *
     * Mode 0 samples MOSI on the rising edge of SCLK.
     * Capture exactly eight bits.
     */
    always @(posedge sclk) begin
        if (!cs_n) begin
            received_data = {received_data[6:0], mosi};
            bit_count = bit_count + 1;

            $display(
                "SPI SAMPLE %0d: MOSI=%b  DATA=%h",
                bit_count,
                mosi,
                received_data
            );
        end
    end

    initial begin

        clk = 0;
        reset = 1;
        start = 0;

        data_in = 8'h00;
        clock_period = 8'd8;

        received_data = 8'h00;
        bit_count = 0;

        $dumpfile("sim/spi_master.vcd");
        $dumpvars(0, spi_master_tb);

        /*
         * Reset.
         */
        #20;
        reset = 0;

        #20;

        $display("");
        $display("========================================");
        $display("PROTEUS SPI MASTER TEST");
        $display("========================================");
        $display("");

        /*
         * Transmit:
         *
         * 0xA5 = 10100101
         *
         * Expected MOSI sequence:
         *
         * 1 0 1 0 0 1 0 1
         */

        data_in = 8'hA5;

        $display("Starting SPI transmission...");
        $display("TX DATA = 0x%h", data_in);
        $display("");

        /*
         * Pulse start for one system clock.
         */
        start = 1;

        @(posedge clk);
        #1;
        start = 0;

        /*
         * Wait for transaction to begin.
         */
        wait (busy == 1'b1);

        $display("SPI BUSY asserted.");
        $display("CS_N = %b", cs_n);
        $display("");

        /*
         * Wait for transaction to finish.
         */
        wait (busy == 1'b0);

        #20;

        $display("");
        $display("========================================");
        $display("SPI TRANSACTION COMPLETE");
        $display("========================================");

        $display("Bits captured : %0d", bit_count);
        $display("Expected      : 0xA5");
        $display("Received      : 0x%h", received_data);

        if (bit_count !== 8) begin

            $display("");
            $display("ERROR: Expected 8 SPI bits.");
            $display("Got %0d bits.", bit_count);

            $finish;

        end

        if (received_data !== 8'hA5) begin

            $display("");
            $display("ERROR: SPI DATA MISMATCH");

            $display(
                "Expected 0xA5, received 0x%h",
                received_data
            );

            $finish;

        end

        $display("");
        $display("========================================");
        $display("SPI MASTER SUCCESS");
        $display("0xA5 transmitted correctly.");
        $display("========================================");
        $display("");

        #50;

        $finish;

    end

endmodule
