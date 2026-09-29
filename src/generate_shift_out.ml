open Hardcaml

let () =
  let circuit =
    Circuit.create_with_interface
      (module Proteus.Shift_out.I)
      (module Proteus.Shift_out.O)
      ~name:"proteus_shift_out"
      (Proteus.Shift_out.create (Scope.create ()))
  in
  Rtl.print Verilog circuit

