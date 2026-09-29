open Hardcaml

let () =
  let circuit =
    Circuit.create_with_interface
      (module Proteus.Instruction.I)
      (module Proteus.Instruction.O)
      ~name:"proteus_instruction"
      (Proteus.Instruction.create (Scope.create ()))
  in
  Rtl.print Verilog circuit
