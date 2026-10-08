
`timescale 1ns/1ps

module proteus_i2c_tb;

    reg clk = 0;
    reg reset = 1;
    reg uart_rx = 1;
    reg spi_miso = 0;

    wire i2c_scl;
    wire i2c_sda;

    wire i2c_scl_drive_low;
    wire i2c_sda_drive_low;
    wire i2c_busy;
    wire i2c_done;
    wire i2c_ack_error;

    wire [7:0] pc;
    wire [15:0] instruction;
    wire [3:0] opcode;
    wire [3:0] register;
    wire [7:0] immediate;

    wire [31:0] r0, r1, r2, r3;

    reg slave_sda_drive_low = 0;

    integer bit_count = 0;
    integer transaction_count = 0;
    integer done_count = 0;
    integer busy_cycles = 0;
    integer errors = 0;

    reg [7:0] address_capture = 0;
    reg [7:0] data_capture = 0;

    reg saw_pc3 = 0;
    reg saw_pc4 = 0;
    reg saw_start = 0;
    reg saw_stop = 0;
    reg transaction_active = 0;

    assign i2c_scl = i2c_scl_drive_low ? 1'b0 : 1'b1;
    assign i2c_sda =
        (i2c_sda_drive_low || slave_sda_drive_low)
        ? 1'b0 : 1'b1;

    proteus_core dut (
        .clk(clk),
        .reset(reset),
        .uart_rx(uart_rx),
        .spi_miso(spi_miso),
        .i2c_scl_in(i2c_scl),
        .i2c_sda_in(i2c_sda),

        .pc(pc),
        .instruction(instruction),
        .opcode(opcode),
        .register(register),
        .immediate(immediate),

        .r0(r0),
        .r1(r1),
        .r2(r2),
        .r3(r3),

        .gpio_out(),
        .shift_busy(),
        .uart_busy(),

        .spi_sclk(),
        .spi_mosi(),
        .spi_cs_n(),
        .spi_busy(),
        .spi_data_out(),
        .spi_valid(),

        .i2c_scl_drive_low(i2c_scl_drive_low),
        .i2c_sda_drive_low(i2c_sda_drive_low),
        .i2c_busy(i2c_busy),
        .i2c_done(i2c_done),
        .i2c_ack_error(i2c_ack_error)
    );

    always #5 clk = ~clk;

    // Detect I2C START and STOP conditions.
    always @(negedge i2c_sda) begin
        if (!reset && i2c_scl && !transaction_active) begin
            saw_start = 1;
            transaction_active = 1;
            transaction_count = transaction_count + 1;
            $display("I2C START detected");
        end
    end

    always @(posedge i2c_sda) begin
        if (!reset && i2c_scl && transaction_active) begin
            saw_stop = 1;
            transaction_active = 0;
            $display("I2C STOP detected");
        end
    end

    // Capture address and data on rising SCL.
    always @(posedge i2c_scl) begin
        if (!reset && transaction_active) begin
            if (bit_count < 8) begin
                address_capture =
                    {address_capture[6:0], i2c_sda};
                bit_count = bit_count + 1;
            end
            else if (bit_count == 8) begin
                bit_count = bit_count + 1;
            end
            else if (bit_count < 17) begin
                data_capture =
                    {data_capture[6:0], i2c_sda};
                bit_count = bit_count + 1;
            end
            else if (bit_count == 17) begin
                bit_count = bit_count + 1;
            end
        end
    end

    // Simulated slave acknowledges both bytes.
    always @(negedge i2c_scl) begin
        if (!reset && transaction_active) begin
            if (bit_count == 8 || bit_count == 17)
                slave_sda_drive_low <= 1;
            else
                slave_sda_drive_low <= 0;
        end
        else begin
            slave_sda_drive_low <= 0;
        end
    end

    // Monitor CPU progress.
    always @(posedge clk) begin
        if (!reset) begin
            if (pc == 8'd3) begin
                saw_pc3 = 1;

                if (i2c_busy)
                    busy_cycles = busy_cycles + 1;
            end

            if (pc == 8'd4)
                saw_pc4 = 1;

            if (i2c_done)
                done_count = done_count + 1;

            if (i2c_busy && pc != 8'd3) begin
                $display("ERROR: CPU left PC 3 while I2C busy");
                errors = errors + 1;
            end
        end
    end

    initial begin
        $dumpfile("sim/proteus_i2c.vcd");
        $dumpvars(0, proteus_i2c_tb);

        #30;
        reset = 0;

        $display("========================================");
        $display("PROTEUS CPU I2C INTEGRATION TEST");
        $display("========================================");

        wait(saw_pc4);

        // Allow time to detect unintended repeated transactions.
        repeat (40) @(posedge clk);

        $display("");
        $display("========================================");
        $display("RESULTS");
        $display("========================================");

        $display("R0 data          : %02h", r0[7:0]);
        $display("R1 timing        : %02h", r1[7:0]);
        $display("R2 address       : %02h", r2[7:0]);
        $display("Address captured : %02h", address_capture);
        $display("Data captured    : %02h", data_capture);
        $display("Transaction count: %0d", transaction_count);
        $display("Done count       : %0d", done_count);
        $display("Busy cycles      : %0d", busy_cycles);
        $display("Final PC         : %0d", pc);
        $display("ACK error        : %b", i2c_ack_error);

        if (r0[7:0] !== 8'hA5) errors = errors + 1;
        if (r1[7:0] !== 8'h08) errors = errors + 1;
        if (r2[7:0] !== 8'h50) errors = errors + 1;

        if (address_capture !== 8'hA0)
            errors = errors + 1;

        if (data_capture !== 8'hA5)
            errors = errors + 1;

        if (transaction_count != 1)
            errors = errors + 1;

        if (done_count != 1)
            errors = errors + 1;

        if (busy_cycles == 0)
            errors = errors + 1;

        if (!saw_pc3 || !saw_pc4)
            errors = errors + 1;

        if (!saw_start || !saw_stop)
            errors = errors + 1;

        if (pc !== 8'd4)
            errors = errors + 1;

        if (i2c_ack_error)
            errors = errors + 1;

        if (errors == 0) begin
            $display("");
            $display("PROTEUS CPU I2C SUCCESS");
            $display("Opcode 0xE executed correctly.");
            $display("CPU stalled during I2C transaction.");
            $display("Address and data verified.");
            $display("CPU resumed after completion.");
        end
        else begin
            $display("");
            $display("PROTEUS CPU I2C FAILED: %0d errors", errors);
        end

        $finish;
    end

    initial begin
        #100000;
        $display("ERROR: Simulation timeout");
        $finish;
    end

endmodule
