open Hardcaml

let () =
  let circuit =
    Circuit.create_with_interface
      (module Proteus.Gpio.I)
      (module Proteus.Gpio.O)
      ~name:"proteus_gpio"
      (Proteus.Gpio.create (Scope.create ()))
  in
  Rtl.print Verilog circuit
