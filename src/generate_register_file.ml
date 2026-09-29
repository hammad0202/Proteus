open Hardcaml

let () =
  let circuit =
    Circuit.create_with_interface
      (module Proteus.Register_file.I)
      (module Proteus.Register_file.O)
      ~name:"proteus_register_file"
      (Proteus.Register_file.create (Scope.create ()))
  in
  Rtl.print Verilog circuit
