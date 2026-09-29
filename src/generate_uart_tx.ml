open Hardcaml

let () =
  let circuit =
    Circuit.create_with_interface
      (module Proteus.Uart_tx.I)
      (module Proteus.Uart_tx.O)
      ~name:"uart_tx"
      (Proteus.Uart_tx.create (Scope.create ()))
  in
  Rtl.print Verilog circuit
