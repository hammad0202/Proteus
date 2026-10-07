open Hardcaml

let () =
  let circuit =
    Circuit.create_with_interface
      (module Proteus.Spi_master.I)
      (module Proteus.Spi_master.O)
      ~name:"spi_master"
      (Proteus.Spi_master.create (Scope.create ()))
  in
  Rtl.print Verilog circuit
