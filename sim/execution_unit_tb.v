`timescale 1ns/1ps

module execution_unit_tb;

    reg [3:0] opcode;
    reg [3:0] register;
    reg [7:0] immediate;

    wire write_enable;
    wire [1:0] write_register;
    wire [31:0] write_data;

    proteus_execution_unit dut (
        .opcode(opcode),
        .register(register),
        .immediate(immediate),
        .write_enable(write_enable),
        .write_register(write_register),
        .write_data(write_data)
    );

    initial begin
        $monitor("opcode=%h register=%h immediate=%h | write_en=%b write_reg=%d write_data=%d",
                 opcode,
                 register,
                 immediate,
                 write_enable,
                 write_register,
                 write_data);

        // SET R0, 5
        opcode = 4'h1;
        register = 4'h0;
        immediate = 8'd5;
        #10;

        // SET R2, 20
        opcode = 4'h1;
        register = 4'h2;
        immediate = 8'd20;
        #10;

        // NOP
        opcode = 4'h0;
        register = 4'h0;
        immediate = 8'd0;
        #10;

        $finish;
    end

endmodule
