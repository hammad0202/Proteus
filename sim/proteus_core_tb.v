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

    localparam integer BIT_PERIOD = 8;
    localparam integer CLOCK_NS = 10;
    localparam integer BIT_NS = BIT_PERIOD * CLOCK_NS;

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
        .uart_busy(uart_busy)
    );

    always #5 clk = ~clk;

    task send_uart_byte;
        input [7:0] data;
        integer i;
        begin
            // Idle
            uart_rx = 1'b1;
            #(BIT_NS);

            // Start bit
            uart_rx = 1'b0;
            #(BIT_NS);

            // Data bits, LSB first
            for (i = 0; i < 8; i = i + 1) begin
                uart_rx = data[i];
                #(BIT_NS);
            end

            // Stop bit
            uart_rx = 1'b1;
            #(BIT_NS);

            // Extra idle time
            #(BIT_NS);
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        uart_rx = 1;

        $dumpfile("sim/proteus_core.vcd");
        $dumpvars(0, proteus_core_tb);

        $monitor(
            "time=%0t PC=%d INST=%h OP=%h REG=%h IMM=%h | R0=%h R1=%h R2=%h R3=%h | GPIO=%b SHIFT_BUSY=%b UART_BUSY=%b",
            $time,
            pc,
            instruction,
            opcode,
            register,
            immediate,
            r0,
            r1,
            r2,
            r3,
            gpio_out,
            shift_busy,
            uart_busy
        );

        #20;
        reset = 0;

        #100;

        if (r1 !== 32'h00000008) begin
            $display("");
            $display("ERROR: UART BIT PERIOD REGISTER FAILED");
            $display("Expected R1 = 0x00000008");
            $display("Got R1 = 0x%h", r1);
            $finish;
        end

        $display("");
        $display("========================================");
        $display("UART BIT PERIOD CONFIGURED");
        $display("R1 = %0d cycles", r1);
        $display("========================================");
        $display("");

        $display("");
        $display("========================================");
        $display("Sending UART byte 0x41 ('A') to PROTEUS");
        $display("========================================");
        $display("");

        send_uart_byte(8'h41);

        #100;

        if (r0 !== 32'h00000041) begin
            $display("ERROR: R0 expected 0x00000041, got 0x%h", r0);
            $finish;
        end

        $display("");
        $display("========================================");
        $display("UART RX SUCCESS");
        $display("R0 = 0x%h", r0);
        $display("========================================");
        $display("");

        wait (uart_busy == 1'b1);
        $display("UART TX started.");

        wait (uart_busy == 1'b0);
        $display("UART TX completed.");

        $display("");
        $display("========================================");
        $display("EXPECTED ECHO: 0x41 ('A')");
        $display("========================================");
        $display("");

        #100;

        $finish;
    end

endmodule
