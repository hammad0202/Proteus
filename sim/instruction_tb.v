`timescale 1ns/1ps

module instruction_tb;

    reg [15:0] instruction;
    wire [3:0] opcode;
    wire [3:0] register;
    wire [7:0] immediate;

    proteus_instruction dut (
        .instruction(instruction),
        .opcode(opcode),
        .register(register),
        .immediate(immediate)
    );

    initial begin
        $monitor("instruction=%h opcode=%h register=%h immediate=%h",
                 instruction, opcode, register, immediate);

        // SET R2, 0x55
        instruction = 16'h1255;
        #10;

        // WAIT R1, 0x20
        instruction = 16'h3100;
        #10;

        // JNZ R3, 0x80
        instruction = 16'h4380;
        #10;

        $finish;
    end

endmodule
