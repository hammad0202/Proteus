open Hardcaml

let () =
  let circuit =
    Circuit.create_with_interface
      (module Proteus.Execution_unit.I)
      (module Proteus.Execution_unit.O)
      ~name:"proteus_execution_unit"
      (Proteus.Execution_unit.create (Scope.create ()))
  in
  Rtl.print Verilog circuit
