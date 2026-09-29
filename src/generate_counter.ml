open Hardcaml

let () =
  let circuit =
    Circuit.create_with_interface
      (module Proteus.Counter.I)
      (module Proteus.Counter.O)
      ~name:"proteus_counter"
      (Proteus.Counter.create (Scope.create ()))
  in
  Rtl.print Verilog circuit
