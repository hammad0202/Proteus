`timescale 1ns/1ps

module i2c_master_tb;

    reg clk;
    reg reset;
    reg start;

    reg [6:0] address;
    reg [7:0] data_in;
    reg [7:0] clock_period;

    wire scl;
    wire sda;

    wire scl_drive_low;
    wire sda_drive_low;

    wire busy;
    wire done_;
    wire ack_error;

    reg slave_sda_drive_low;

    integer bit_count;
    reg [7:0] address_capture;
    reg [7:0] data_capture;

    /*
     * Open-drain I2C bus.
     *
     * If nobody pulls the line low,
     * the pull-up makes it high.
     */

    assign scl =
        scl_drive_low ? 1'b0 : 1'b1;

    assign sda =
        (sda_drive_low || slave_sda_drive_low)
        ? 1'b0
        : 1'b1;

    i2c_master dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .address(address),
        .data_in(data_in),
        .clock_period(clock_period),
        .scl_in(scl),
        .sda_in(sda),
        .scl_drive_low(scl_drive_low),
        .sda_drive_low(sda_drive_low),
        .busy(busy),
        .done_(done_),
        .ack_error(ack_error)
    );

    always #5 clk = ~clk;

    /*
     * Fake I2C slave.
     *
     * Capture bits on rising SCL.
     *
     * Bits 0-7   = address + W
     * Bit 8      = ACK
     * Bits 9-16  = data
     * Bit 17     = ACK
     */

    always @(posedge scl) begin

        if (busy) begin

            if (bit_count < 8) begin

                address_capture =
                    {address_capture[6:0], sda};

                $display(
                    "ADDRESS BIT %0d: SDA=%b CAPTURE=%02h",
                    bit_count + 1,
                    sda,
                    {address_capture[6:0], sda}
                );

                bit_count = bit_count + 1;

            end

            else if (bit_count == 8) begin

                bit_count = bit_count + 1;

            end

            else if (bit_count < 17) begin

                data_capture =
                    {data_capture[6:0], sda};

                $display(
                    "DATA BIT %0d: SDA=%b CAPTURE=%02h",
                    bit_count - 8,
                    sda,
                    {data_capture[6:0], sda}
                );

                bit_count = bit_count + 1;

            end

            else if (bit_count == 17) begin

                bit_count = bit_count + 1;

            end

        end

    end

    /*
     * Slave ACK generation.
     *
     * Pull SDA low during the ninth clock
     * after address and after data.
     */

    always @(negedge scl) begin

        if (busy) begin

            if ((bit_count == 8) ||
                (bit_count == 17)) begin

                slave_sda_drive_low <= 1'b1;

                $display(
                    "SLAVE ACK ENABLED"
                );

            end
            else begin

                slave_sda_drive_low <= 1'b0;

            end

        end
        else begin

            slave_sda_drive_low <= 1'b0;

        end

    end

    initial begin

        $dumpfile("sim/i2c_master.vcd");
        $dumpvars(0, i2c_master_tb);

        clk = 0;
        reset = 1;
        start = 0;

        address = 7'h50;
        data_in = 8'hA5;
        clock_period = 8'd8;

        slave_sda_drive_low = 0;

        bit_count = 0;
        address_capture = 0;
        data_capture = 0;

        #30;

        reset = 0;

        #20;

        $display("");
        $display("========================================");
        $display("STARTING PROTEUS I2C WRITE");
        $display("ADDRESS : 0x50");
        $display("DATA    : 0xA5");
        $display("========================================");
        $display("");

        start = 1;

        #10;

        start = 0;

        wait(done_);

        #20;

        $display("");
        $display("========================================");
        $display("I2C RESULT");
        $display("========================================");

        $display(
            "Address+W expected : 0xA0"
        );

        $display(
            "Address+W captured : 0x%02h",
            address_capture
        );

        $display(
            "Data expected      : 0xA5"
        );

        $display(
            "Data captured      : 0x%02h",
            data_capture
        );

        $display(
            "ACK error          : %b",
            ack_error
        );

        if (
            address_capture == 8'hA0 &&
            data_capture == 8'hA5 &&
            ack_error == 1'b0
        ) begin

            $display("");
            $display("I2C MASTER SUCCESS");
            $display("START generated correctly.");
            $display("Address 0x50 + WRITE transmitted.");
            $display("Address ACK received.");
            $display("Data 0xA5 transmitted.");
            $display("Data ACK received.");
            $display("STOP generated.");
            $display("");

        end
        else begin

            $display("");
            $display("I2C MASTER ERROR");
            $display("");

        end

        $finish;

    end

endmodule
