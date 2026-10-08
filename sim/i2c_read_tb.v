
`timescale 1ns/1ps

module i2c_read_tb;

    reg clk = 0;
    reg reset = 1;
    reg start = 0;
    reg read_mode = 1;

    reg [6:0] address = 7'h50;
    reg [7:0] data_in = 8'h00;
    reg [7:0] clock_period = 8'd8;

    wire scl, sda;
    wire scl_drive_low, sda_drive_low;
    wire busy, done_, ack_error;
    wire [7:0] data_out;

    reg slave_sda_drive_low = 0;

    reg [7:0] slave_data = 8'h3C;
    reg [7:0] address_capture = 0;

    integer bit_count = 0;
    integer transaction_count = 0;
    integer done_count = 0;
    integer errors = 0;

    reg transaction_active = 0;
    reg saw_start = 0;
    reg saw_stop = 0;
    reg master_nack = 0;

    assign scl = scl_drive_low ? 1'b0 : 1'b1;
    assign sda =
        (sda_drive_low || slave_sda_drive_low)
        ? 1'b0 : 1'b1;

    i2c_master dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .read_mode(read_mode),
        .address(address),
        .data_in(data_in),
        .clock_period(clock_period),
        .scl_in(scl),
        .sda_in(sda),
        .scl_drive_low(scl_drive_low),
        .sda_drive_low(sda_drive_low),
        .busy(busy),
        .done_(done_),
        .ack_error(ack_error),
        .data_out(data_out)
    );

    always #5 clk = ~clk;

    // START detection
    always @(negedge sda) begin
        if (!reset && scl && !transaction_active) begin
            saw_start = 1;
            transaction_active = 1;
            transaction_count = transaction_count + 1;
            $display("I2C START detected");
        end
    end

    // STOP detection
    always @(posedge sda) begin
        if (!reset && scl && transaction_active) begin
            saw_stop = 1;
            transaction_active = 0;
            $display("I2C STOP detected");
        end
    end

    // Capture address and verify master NACK.
    always @(posedge scl) begin
        if (!reset && transaction_active) begin
            if (bit_count < 8) begin
                address_capture =
                    {address_capture[6:0], sda};
                bit_count = bit_count + 1;
            end
            else if (bit_count == 8) begin
                bit_count = bit_count + 1;
            end
            else if (bit_count < 17) begin
                bit_count = bit_count + 1;
            end
            else if (bit_count == 17) begin
                master_nack = (sda === 1'b1);
                bit_count = bit_count + 1;
            end
        end
    end

    // Slave drives ACK and data while SCL is low.
    always @(negedge scl) begin
        if (!reset && transaction_active) begin
            if (bit_count == 8) begin
                slave_sda_drive_low <= 1'b1;
                $display("Slave ACK");
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

    always @(posedge clk) begin
        if (!reset && done_)
            done_count = done_count + 1;
    end

    initial begin
        $dumpfile("sim/i2c_read.vcd");
        $dumpvars(0, i2c_read_tb);

        #30;
        reset = 0;

        #20;
        $display("========================================");
        $display("PROTEUS STANDALONE I2C READ TEST");
        $display("========================================");

        start = 1;
        #10;
        start = 0;

        wait(done_);
        repeat (5) @(posedge clk);

        $display("");
        $display("========================================");
        $display("RESULTS");
        $display("========================================");

        $display("Address expected : A1");
        $display("Address captured : %02h", address_capture);
        $display("Data expected    : 3C");
        $display("Data received    : %02h", data_out);
        $display("Master NACK      : %b", master_nack);
        $display("ACK error        : %b", ack_error);
        $display("Transactions     : %0d", transaction_count);
        $display("Done pulses      : %0d", done_count);

        if (address_capture !== 8'hA1)
            errors = errors + 1;

        if (data_out !== 8'h3C)
            errors = errors + 1;

        if (!master_nack)
            errors = errors + 1;

        if (ack_error !== 1'b0)
            errors = errors + 1;

        if (transaction_count != 1)
            errors = errors + 1;

        if (done_count != 1)
            errors = errors + 1;

        if (!saw_start || !saw_stop)
            errors = errors + 1;

        if (errors == 0) begin
            $display("");
            $display("I2C READ SUCCESS");
            $display("Address+R transmitted correctly.");
            $display("Slave ACK received.");
            $display("Data 0x3C received correctly.");
            $display("Master NACK generated.");
            $display("STOP generated.");
        end
        else begin
            $display("");
            $display("I2C READ FAILED: %0d errors", errors);
        end

        $finish;
    end

    initial begin
        #100000;
        $display("ERROR: I2C read simulation timeout");
        $finish;
    end

endmodule

