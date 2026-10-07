open Hardcaml
open Signal

module I = struct
  type 'a t =
    { opcode : 'a [@bits 4]
    ; immediate : 'a [@bits 8]
    ; register_value : 'a [@bits 32]
    ; wait_busy : 'a
    ; wait_done : 'a
    ; uart_busy : 'a
    ; uart_done : 'a
    ; uart_rx_valid : 'a
    ; spi_busy : 'a
    ; spi_valid : 'a
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { pc_enable : 'a
    ; pc_jump : 'a
    ; pc_target : 'a [@bits 8]
    ; wait_load : 'a
    }
  [@@deriving hardcaml]
end

let create (_scope : Scope.t) (i : _ I.t) =
  let is_wait = i.opcode ==:. 3 in
  let is_jmp = i.opcode ==:. 4 in
  let is_jnz = i.opcode ==:. 5 in
  let is_uart_tx = i.opcode ==:. 11 in
  let is_uart_rx = i.opcode ==:. 12 in
  let is_spi_xfer = i.opcode ==:. 13 in

  let register_nonzero =
    i.register_value <>:. 0
  in

  let jnz_taken =
    is_jnz &: register_nonzero
  in

  let pc_jump =
    is_jmp |: jnz_taken
  in

  let wait_load =
    is_wait &: (i.wait_busy ==:. 0)
  in

  let wait_active =
    is_wait &: i.wait_busy
  in

  let wait_finished =
    is_wait &: i.wait_done
  in

  let uart_tx_active =
    is_uart_tx
  in

  let uart_tx_finished =
    is_uart_tx &: i.uart_done
  in

  let uart_rx_active =
    is_uart_rx
  in

  let uart_rx_finished =
    is_uart_rx &: i.uart_rx_valid
  in

  (*
   * SPI_XFER does not advance when the SPI engine merely
   * finishes clocking.
   *
   * It advances when spi_valid says the received byte has
   * been registered and is ready to write into the CPU register.
   *)
  let spi_xfer_active =
    is_spi_xfer
  in

  let spi_xfer_finished =
    is_spi_xfer &: i.spi_valid
  in

  let pc_enable =
    ((~:wait_active) |: wait_finished)
    &: ((~:uart_tx_active) |: uart_tx_finished)
    &: ((~:uart_rx_active) |: uart_rx_finished)
    &: ((~:spi_xfer_active) |: spi_xfer_finished)
  in

  let pc_target =
    i.immediate
  in

  { O.pc_enable
  ; pc_jump
  ; pc_target
  ; wait_load
  }
