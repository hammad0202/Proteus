open Hardcaml

let () =
  let circuit =
    Circuit.create_with_interface
      (module Proteus.Uart_rx.I)
      (module Proteus.Uart_rx.O)
      ~name:"uart_rx"
      (Proteus.Uart_rx.create (Scope.create ()))
  in
  Rtl.print Verilog circuit
