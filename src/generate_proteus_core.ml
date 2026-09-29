open Hardcaml

let () =
  let circuit =
    Circuit.create_with_interface
      (module Proteus.Proteus_core.I)
      (module Proteus.Proteus_core.O)
      ~name:"proteus_core"
      (Proteus.Proteus_core.create (Scope.create ()))
  in
  Rtl.print Verilog circuit
