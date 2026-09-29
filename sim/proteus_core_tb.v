`timescale 1ns/1ps

module proteus_core_tb;

    reg clk;
    reg reset;

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

    proteus_core dut (
        .clk(clk),
        .reset(reset),
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

    initial begin
        clk = 0;
        reset = 1;

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

        #12 reset = 0;

        // Let the CPU execute SET + UART_TX.
        #1000 $finish;
    end

endmodule
