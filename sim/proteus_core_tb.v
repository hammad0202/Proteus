`timescale 1ns/1ps

module proteus_core_tb;

    reg clk;
    reg reset;

    reg uart_rx;
    reg spi_miso;

    wire [7:0]  pc;
    wire [15:0] instruction;
    wire [3:0]  opcode;
    wire [3:0]  register;
    wire [7:0]  immediate;

    wire [31:0] r0;
    wire [31:0] r1;
    wire [31:0] r2;
    wire [31:0] r3;

    wire gpio_out;
    wire shift_busy;
    wire uart_busy;

    wire spi_sclk;
    wire spi_mosi;
    wire spi_cs_n;
    wire spi_busy;

    wire [7:0] spi_data_out;
    wire spi_valid;

    reg [7:0] captured_mosi;
    integer spi_bit_count;

    reg [7:0] slave_data;
    integer slave_bit_index;

    proteus_core dut (
        .clk(clk),
        .reset(reset),

        .uart_rx(uart_rx),
        .spi_miso(spi_miso),

        .pc(pc),
        .instruction(instruction),
        .opcode(opcode),
        .register(register),
        .immediate(immediate),

        .r0(r0),
        .r1(r1),
        .r2(r2),
        .r3(r3),

        .gpio_out(gpio_out),
        .shift_busy(shift_busy),
        .uart_busy(uart_busy),

        .spi_sclk(spi_sclk),
        .spi_mosi(spi_mosi),
        .spi_cs_n(spi_cs_n),
        .spi_busy(spi_busy),
        .spi_data_out(spi_data_out),
        .spi_valid(spi_valid)
    );

    /*
     * 100 MHz CPU clock.
     */
    always #5 clk = ~clk;

    /*
     * Capture the byte transmitted by PROTEUS.
     *
     * SPI Mode 0 samples MOSI on rising SCLK.
     */
    always @(posedge spi_sclk) begin

        if (!spi_cs_n) begin

            captured_mosi =
                {captured_mosi[6:0], spi_mosi};

            spi_bit_count =
                spi_bit_count + 1;

            $display(
                "SPI BIT %0d: MOSI=%b MISO=%b TX_CAPTURE=%h",
                spi_bit_count,
                spi_mosi,
                spi_miso,
                captured_mosi
            );

        end

    end

    /*
     * Fake SPI Mode 0 slave.
     *
     * It returns:
     *
     * 0x3C = 00111100
     *
     * First MISO bit is available before the first rising edge.
     */
    always @(negedge spi_cs_n) begin

        slave_bit_index = 7;
        spi_miso = slave_data[7];

    end

    /*
     * Advance slave data after each falling SCLK edge.
     */
    always @(negedge spi_sclk) begin

        if (!spi_cs_n) begin

            if (slave_bit_index > 0) begin

                slave_bit_index =
                    slave_bit_index - 1;

                spi_miso =
                    slave_data[slave_bit_index];

            end

        end

    end

    initial begin

        clk = 0;
        reset = 1;

        uart_rx = 1;
        spi_miso = 0;

        captured_mosi = 8'h00;
        spi_bit_count = 0;

        slave_data = 8'h3C;
        slave_bit_index = 7;

        $dumpfile("sim/proteus_core.vcd");
        $dumpvars(0, proteus_core_tb);

        $monitor(
            "time=%0t PC=%d INST=%h OP=%h | R0=%h R1=%h | SPI_BUSY=%b VALID=%b CS=%b SCLK=%b MOSI=%b MISO=%b RX=%h",
            $time,
            pc,
            instruction,
            opcode,
            r0,
            r1,
            spi_busy,
            spi_valid,
            spi_cs_n,
            spi_sclk,
            spi_mosi,
            spi_miso,
            spi_data_out
        );

        #20;
        reset = 0;

        /*
         * Program:
         *
         * PC 0: SET R0, 0xA5
         * PC 1: SET R1, 8
         * PC 2: SPI_XFER R0
         * PC 3: JMP 2
         */

        wait (spi_busy == 1'b1);

        $display("");
        $display("========================================");
        $display("CPU STARTED SPI_XFER");
        $display("========================================");

        $display(
            "R0 before transfer = 0x%h",
            r0
        );

        $display(
            "Slave response     = 0x%h",
            slave_data
        );

        $display("");

        /*
         * CPU must remain on SPI_XFER while transfer occurs.
         */
        if (pc !== 8'd2) begin

            $display(
                "ERROR: CPU did not stall at PC 2."
            );

            $finish;

        end

        /*
         * Wait until received byte becomes valid.
         */
        wait (spi_valid == 1'b1);

        $display("");
        $display("SPI result became valid.");
        $display(
            "SPI data_out = 0x%h",
            spi_data_out
        );

        /*
         * Wait for register-file write edge.
         */
        @(posedge clk);
        #1;

        $display("");
        $display("========================================");
        $display("CPU FULL-DUPLEX SPI RESULT");
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
            "SPI received  : 0x%h",
            spi_data_out
        );

        $display(
            "R0 after XFER : 0x%h",
            r0
        );

        $display(
            "Bits captured : %0d",
            spi_bit_count
        );

        /*
         * Verify MOSI.
         */
        if (captured_mosi !== 8'hA5) begin

            $display("");
            $display("ERROR: MOSI DATA MISMATCH");

            $finish;

        end

        /*
         * Verify MISO receive engine.
         */
        if (spi_data_out !== 8'h3C) begin

            $display("");
            $display("ERROR: SPI RX DATA MISMATCH");

            $finish;

        end

        /*
         * Most important CPU-level check:
         *
         * SPI_XFER R0 must replace R0 with the received byte.
         */
        if (r0 !== 32'h0000003C) begin

            $display("");
            $display("ERROR: CPU REGISTER WRITEBACK FAILED");

            $display(
                "Expected R0 = 0x0000003C, got 0x%h",
                r0
            );

            $finish;

        end

        if (spi_bit_count !== 8) begin

            $display("");
            $display(
                "ERROR: Expected 8 SPI bits, got %0d",
                spi_bit_count
            );

            $finish;

        end

        $display("");
        $display("========================================");
        $display("CPU SPI_XFER SUCCESS");
        $display("PROTEUS TRANSMITTED 0xA5");
        $display("PROTEUS RECEIVED    0x3C");
        $display("R0 UPDATED TO       0x0000003C");
        $display("========================================");
        $display("");

        $finish;

    end

endmodule
