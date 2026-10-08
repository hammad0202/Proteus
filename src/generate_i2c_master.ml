open Hardcaml

let () =
  let circuit =
    Circuit.create_with_interface
      (module Proteus.I2c_master.I)
      (module Proteus.I2c_master.O)
      ~name:"i2c_master"
      (Proteus.I2c_master.create (Scope.create ()))
  in
  Rtl.print Verilog circuit

