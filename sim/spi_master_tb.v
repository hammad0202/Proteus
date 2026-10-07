`timescale 1ns/1ps

module spi_master_tb;

    reg clk;
    reg reset;
    reg start;

    reg [7:0] data_in;
    reg [7:0] clock_period;

    reg miso;

    wire sclk;
    wire mosi;
    wire cs_n;
    wire busy;
    wire done_;

    wire [7:0] data_out;
    wire valid;

    reg [7:0] captured_mosi;
    integer bit_count;

    /*
     * Fake SPI slave response.
     *
     * Slave will return:
     *
     * 0x3C = 00111100
     */
    reg [7:0] slave_data;
    integer slave_bit_index;

    spi_master dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .data_in(data_in),
        .miso(miso),
        .clock_period(clock_period),

        .sclk(sclk),
        .mosi(mosi),
        .cs_n(cs_n),
        .busy(busy),
        .done_(done_),
        .data_out(data_out),
        .valid(valid)
    );

    /*
     * 100 MHz system clock.
     */
    always #5 clk = ~clk;

    /*
     * Capture MOSI exactly like a Mode 0 slave.
     *
     * Data is sampled on rising SCLK.
     */
    always @(posedge sclk) begin

        if (!cs_n) begin

            captured_mosi =
                {captured_mosi[6:0], mosi};

            bit_count =
                bit_count + 1;

            $display(
                "SPI SAMPLE %0d: MOSI=%b MISO=%b TX_CAPTURE=%h",
                bit_count,
                mosi,
                miso,
                captured_mosi
            );

        end

    end

    /*
     * SPI Mode 0 slave behavior.
     *
     * The first MISO bit must already be valid before
     * the first rising edge.
     *
     * After each falling edge, advance to the next bit.
     */
    always @(negedge cs_n) begin

        slave_bit_index = 7;
        miso = slave_data[7];

    end

    always @(negedge sclk) begin

        if (!cs_n) begin

            if (slave_bit_index > 0) begin

                slave_bit_index =
                    slave_bit_index - 1;

                miso =
                    slave_data[slave_bit_index];

            end

        end

    end

    initial begin

        clk = 0;
        reset = 1;
        start = 0;

        data_in = 8'h00;
        clock_period = 8'd8;

        miso = 0;

        captured_mosi = 8'h00;
        bit_count = 0;

        slave_data = 8'h3C;
        slave_bit_index = 7;

        $dumpfile("sim/spi_master.vcd");
        $dumpvars(0, spi_master_tb);

        #20;
        reset = 0;

        #20;

        $display("");
        $display("========================================");
        $display("PROTEUS FULL-DUPLEX SPI TEST");
        $display("========================================");
        $display("");

        data_in = 8'hA5;

        $display("Master TX : 0x%h", data_in);
        $display("Slave TX  : 0x%h", slave_data);
        $display("");

        start = 1;

        @(posedge clk);
        #1;

        start = 0;

        wait (busy == 1'b1);

        $display("SPI transaction started.");
        $display("");

        wait (busy == 1'b0);

        #20;

        $display("");
        $display("========================================");
        $display("FULL-DUPLEX RESULT");
        $display("========================================");

        $display(
            "MOSI expected : 0xA5"
        );

        $display(
            "MOSI captured : 0x%h",
            captured_mosi
        );

        $display(
            "MISO expected : 0x3C"
        );

        $display(
            "MISO received : 0x%h",
            data_out
        );

        $display(
            "Bits          : %0d",
            bit_count
        );

        if (bit_count !== 8) begin

            $display("");
            $display(
                "ERROR: Expected 8 bits, got %0d",
                bit_count
            );

            $finish;

        end

        if (captured_mosi !== 8'hA5) begin

            $display("");
            $display("ERROR: MOSI DATA MISMATCH");

            $display(
                "Expected 0xA5, got 0x%h",
                captured_mosi
            );

            $finish;

        end

        if (data_out !== 8'h3C) begin

            $display("");
            $display("ERROR: MISO DATA MISMATCH");

            $display(
                "Expected 0x3C, got 0x%h",
                data_out
            );

            $finish;

        end

        $display("");
        $display("========================================");
        $display("FULL-DUPLEX SPI SUCCESS");
        $display("MOSI: 0xA5 transmitted correctly.");
        $display("MISO: 0x3C received correctly.");
        $display("========================================");
        $display("");

        #50;

        $finish;

    end

endmodule
