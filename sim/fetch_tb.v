`timescale 1ns/1ps

module fetch_tb;

    reg clk;
    reg reset;
    reg enable;

    wire [7:0] pc;
    wire [15:0] instruction;
    wire [3:0] opcode;
    wire [3:0] register;
    wire [7:0] immediate;

    proteus_program_counter pc_unit (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .pc(pc)
    );

    proteus_instruction_memory memory (
        .address(pc),
        .instruction(instruction)
    );

    proteus_instruction decoder (
        .instruction(instruction),
        .opcode(opcode),
        .register(register),
        .immediate(immediate)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        enable = 0;

        $monitor("time=%0t PC=%d instruction=%h opcode=%h register=%h immediate=%h",
                 $time, pc, instruction, opcode, register, immediate);

        #20 reset = 0;
        #10 enable = 1;
        #60 enable = 0;
        #20 $finish;
    end

endmodule
