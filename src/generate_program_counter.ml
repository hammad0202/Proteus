open Hardcaml

let () =
  let circuit =
    Circuit.create_with_interface
      (module Proteus.Program_counter.I)
      (module Proteus.Program_counter.O)
      ~name:"proteus_program_counter"
      (Proteus.Program_counter.create (Scope.create ()))
  in
  Rtl.print Verilog circuit
