open Hardcaml

let () =
  let program =
    match Array.to_list Sys.argv with
    | [_] ->
        Proteus.Instruction_memory.I2c_read

    | [_; "i2c_read"] ->
        Proteus.Instruction_memory.I2c_read

    | [_; "i2c_write"] ->
        Proteus.Instruction_memory.I2c_write

    | [_; "spi"] ->
        Proteus.Instruction_memory.Spi_transfer

    | [_; "uart_loopback"] ->
        Proteus.Instruction_memory.Uart_loopback

    | [_; "uart_loopback_16"] ->
        Proteus.Instruction_memory.Uart_loopback_16

    | _ ->
        prerr_endline
          "Usage: generate_proteus_core.exe [i2c_read|i2c_write|spi|uart_loopback]";
        exit 1
  in

  Proteus.Instruction_memory.set_program program;

  let circuit =
    Circuit.create_with_interface
      (module Proteus.Proteus_core.I)
      (module Proteus.Proteus_core.O)
      ~name:"proteus_core"
      (Proteus.Proteus_core.create (Scope.create ()))
  in

  Rtl.print Verilog circuit
