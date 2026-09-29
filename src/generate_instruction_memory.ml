open Hardcaml

let () =
  let circuit =
    Circuit.create_with_interface
      (module Proteus.Instruction_memory.I)
      (module Proteus.Instruction_memory.O)
      ~name:"proteus_instruction_memory"
      (Proteus.Instruction_memory.create (Scope.create ()))
  in
  Rtl.print Verilog circuit
