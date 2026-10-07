`timescale 1ns/1ps

module proteus_core_tb;

    reg clk;
    reg reset;
    reg uart_rx;

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

    reg [7:0] spi_received;
    integer spi_bit_count;
    integer transaction_count;

    proteus_core dut (
        .clk(clk),
        .reset(reset),
        .uart_rx(uart_rx),

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
        .spi_busy(spi_busy)
    );

    /*
     * 100 MHz CPU clock.
     */
    always #5 clk = ~clk;

    /*
     * SPI Mode 0 receiver.
     *
     * Capture MOSI on rising SCLK.
     */
    always @(posedge spi_sclk) begin

        if (!spi_cs_n) begin

            spi_received =
                {spi_received[6:0], spi_mosi};

            spi_bit_count =
                spi_bit_count + 1;

            $display(
                "SPI BIT %0d: MOSI=%b DATA=%h",
                spi_bit_count,
                spi_mosi,
                spi_received
            );

        end

    end

    /*
     * Detect completed SPI transactions.
     */
    always @(posedge spi_cs_n) begin

        if (!reset && spi_bit_count != 0) begin

            transaction_count =
                transaction_count + 1;

            $display("");
            $display(
                "SPI TRANSACTION %0d COMPLETE",
                transaction_count
            );

            $display(
                "Captured byte = 0x%h",
                spi_received
            );

            $display("");

        end

    end

    initial begin

        clk = 0;
        reset = 1;

        /*
         * UART is unused during this test,
         * so leave the RX line idle high.
         */
        uart_rx = 1;

        spi_received = 8'h00;
        spi_bit_count = 0;
        transaction_count = 0;

        $dumpfile("sim/proteus_core.vcd");
        $dumpvars(0, proteus_core_tb);

        $monitor(
            "time=%0t PC=%d INST=%h OP=%h | R0=%h R1=%h | SPI_BUSY=%b CS=%b SCLK=%b MOSI=%b",
            $time,
            pc,
            instruction,
            opcode,
            r0,
            r1,
            spi_busy,
            spi_cs_n,
            spi_sclk,
            spi_mosi
        );

        /*
         * Reset CPU.
         */
        #20;
        reset = 0;

        /*
         * Give CPU time to execute:
         *
         * SET R0, 0xA5
         * SET R1, 8
         * SPI_TX R0
         */
        wait (spi_busy == 1'b1);

        $display("");
        $display("========================================");
        $display("CPU STARTED SPI TRANSACTION");
        $display("========================================");

        $display("R0 = 0x%h", r0);
        $display("R1 = %0d cycles", r1);

        $display("");

        /*
         * Wait for first transaction.
         */
        wait (spi_busy == 1'b0);

        #20;

        $display("");
        $display("========================================");
        $display("CPU SPI RESULT");
        $display("========================================");

        $display(
            "Bits captured : %0d",
            spi_bit_count
        );

        $display(
            "Expected      : 0xA5"
        );

        $display(
            "Received      : 0x%h",
            spi_received
        );

        /*
         * Verify exactly eight bits.
         */
        if (spi_bit_count !== 8) begin

            $display("");
            $display(
                "ERROR: Expected 8 SPI bits, got %0d",
                spi_bit_count
            );

            $finish;

        end

        /*
         * Verify transmitted byte.
         */
        if (spi_received !== 8'hA5) begin

            $display("");
            $display("ERROR: SPI DATA MISMATCH");

            $display(
                "Expected 0xA5, got 0x%h",
                spi_received
            );

            $finish;

        end

        $display("");
        $display("========================================");
        $display("CPU SPI_TX SUCCESS");
        $display("PROTEUS EXECUTED SPI_TX R0");
        $display("0xA5 TRANSMITTED CORRECTLY");
        $display("========================================");
        $display("");

        #50;

        $finish;

    end

endmodule
