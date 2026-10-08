
`timescale 1ns/1ps

module proteus_i2c_read_tb;

    reg clk = 0;
    reg reset = 1;
    reg uart_rx = 1;
    reg spi_miso = 1;

    wire i2c_scl;
    wire i2c_sda;
    wire i2c_scl_drive_low;
    wire i2c_sda_drive_low;

    reg slave_sda_drive_low = 0;

    wire [7:0] pc;
    wire [15:0] instruction;
    wire [3:0] opcode;
    wire [3:0] register;
    wire [7:0] immediate;

    wire [31:0] r0, r1, r2, r3;
    wire gpio_out;
    wire shift_busy, uart_busy;
    wire spi_sclk, spi_mosi, spi_cs_n;
    wire spi_busy, spi_valid;
    wire [7:0] spi_data_out;

    wire i2c_busy;
    wire i2c_done;
    wire i2c_ack_error;

    reg [7:0] slave_data = 8'h3C;
    reg [7:0] address_capture = 0;

    integer bit_count = 0;
    integer transaction_count = 0;
    integer done_count = 0;
    integer busy_cycles = 0;
    integer errors = 0;

    reg transaction_active = 0;
    reg saw_start = 0;
    reg saw_stop = 0;
    reg master_nack = 0;
    reg pc_stall_error = 0;

    assign i2c_scl =
        i2c_scl_drive_low ? 1'b0 : 1'b1;

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

        .gpio_out(gpio_out),
        .shift_busy(shift_busy),
        .uart_busy(uart_busy),

        .spi_sclk(spi_sclk),
        .spi_mosi(spi_mosi),
        .spi_cs_n(spi_cs_n),
        .spi_busy(spi_busy),
        .spi_data_out(spi_data_out),
        .spi_valid(spi_valid),

        .i2c_scl_drive_low(i2c_scl_drive_low),
        .i2c_sda_drive_low(i2c_sda_drive_low),
        .i2c_busy(i2c_busy),
        .i2c_done(i2c_done),
        .i2c_ack_error(i2c_ack_error)
    );

    always #5 clk = ~clk;

    // Detect START.
    always @(negedge i2c_sda) begin
        if (!reset && i2c_scl && !transaction_active) begin
            saw_start = 1;
            transaction_active = 1;
            transaction_count = transaction_count + 1;
            $display("I2C START detected");
        end
    end

    // Detect STOP.
    always @(posedge i2c_sda) begin
        if (!reset && i2c_scl && transaction_active) begin
            saw_stop = 1;
            transaction_active = 0;
            $display("I2C STOP detected");
        end
    end

    // Capture address and master NACK.
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
                bit_count = bit_count + 1;
            end
            else if (bit_count == 17) begin
                master_nack = (i2c_sda === 1'b1);
                bit_count = bit_count + 1;
            end
        end
    end

    // Slave drives ACK and the 8-bit response.
    always @(negedge i2c_scl) begin
        if (!reset && transaction_active) begin
            if (bit_count == 8) begin
                slave_sda_drive_low <= 1'b1;
            end
            else if (bit_count >= 9 && bit_count < 17) begin
                slave_sda_drive_low <=
                    ~slave_data[16 - bit_count];
            end
            else begin
                slave_sda_drive_low <= 1'b0;
            end
        end
        else begin
            slave_sda_drive_low <= 1'b0;
        end
    end

    // Monitor CPU execution and stalling.
    always @(posedge clk) begin
        if (!reset) begin
            if (i2c_busy) begin
                busy_cycles = busy_cycles + 1;

                if (pc !== 8'd2)
                    pc_stall_error = 1;
            end

            if (i2c_done)
                done_count = done_count + 1;
        end
    end

    initial begin
        $dumpfile("sim/proteus_i2c_read.vcd");
        $dumpvars(0, proteus_i2c_read_tb);

        #30;
        reset = 0;

        $display("========================================");
        $display("PROTEUS CPU I2C READ TEST");
        $display("========================================");

        wait(i2c_done);
        repeat (8) @(negedge clk);

        $display("");
        $display("========================================");
        $display("RESULTS");
        $display("========================================");

        $display("Expected address : A1");
        $display("Captured address : %02h", address_capture);
        $display("Expected data    : 3C");
        $display("R0 received      : %08h", r0);
        $display("R1 timing        : %08h", r1);
        $display("R2 address       : %08h", r2);
        $display("Final PC         : %0d", pc);
        $display("Master NACK      : %b", master_nack);
        $display("ACK error        : %b", i2c_ack_error);
        $display("Transactions     : %0d", transaction_count);
        $display("Done pulses      : %0d", done_count);
        $display("Busy cycles      : %0d", busy_cycles);

        if (address_capture !== 8'hA1)
            errors = errors + 1;

        if (r0 !== 32'h0000003C)
            errors = errors + 1;

        if (r1 !== 32'h00000008)
            errors = errors + 1;

        if (r2 !== 32'h00000050)
            errors = errors + 1;

        if (pc !== 8'd3)
            errors = errors + 1;

        if (!master_nack)
            errors = errors + 1;

        if (i2c_ack_error !== 1'b0)
            errors = errors + 1;

        if (transaction_count != 1)
            errors = errors + 1;

        if (done_count != 1)
            errors = errors + 1;

        if (busy_cycles == 0 || pc_stall_error)
            errors = errors + 1;

        if (!saw_start || !saw_stop)
            errors = errors + 1;

        if (errors == 0) begin
            $display("");
            $display("========================================");
            $display("PROTEUS CPU I2C READ SUCCESS");
            $display("========================================");
            $display("Opcode 0xF executed correctly.");
            $display("CPU stalled during I2C read.");
            $display("Address and received data verified.");
            $display("R0 updated with 0x3C.");
            $display("CPU resumed after completion.");
        end
        else begin
            $display("");
            $display("PROTEUS CPU I2C READ FAILED: %0d errors", errors);
            $fatal(1, "CPU I2C read verification failed");
        end

        $finish;
    end

    initial begin
        #100000;
        $fatal(1, "CPU I2C read simulation timeout");
    end

endmodule
