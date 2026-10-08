open Hardcaml
open Signal

module I = struct
  type 'a t =
    { opcode : 'a [@bits 4]
    ; register : 'a [@bits 4]
    ; immediate : 'a [@bits 8]
    ; register_value : 'a [@bits 32]
    ; uart_busy : 'a
    ; uart_rx_valid : 'a
    ; uart_rx_data : 'a [@bits 8]
    ; spi_busy : 'a
    ; spi_valid : 'a
    ; spi_data_out : 'a [@bits 8]
    ; i2c_busy : 'a
    ; i2c_done : 'a
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { write_enable : 'a
    ; write_register : 'a [@bits 2]
    ; write_data : 'a [@bits 32]
    ; gpio_write_enable : 'a
    ; gpio_write_data : 'a
    ; shift_load : 'a
    ; shift_data : 'a [@bits 8]
    ; uart_start : 'a
    ; uart_data : 'a [@bits 8]
    ; uart_rx_consume : 'a
    ; spi_start : 'a
    ; spi_data : 'a [@bits 8]
    ; i2c_start : 'a
    ; i2c_data : 'a [@bits 8]
    }
  [@@deriving hardcaml]
end

let create (_scope : Scope.t) (i : _ I.t) =
  let is_set = i.opcode ==:. 1 in
  let is_clr = i.opcode ==:. 2 in
  let is_dec = i.opcode ==:. 6 in
  let is_set_pin = i.opcode ==:. 7 in
  let is_clr_pin = i.opcode ==:. 8 in
  let is_shift_out = i.opcode ==:. 9 in
  let is_uart_tx = i.opcode ==:. 11 in
  let is_uart_rx = i.opcode ==:. 12 in
  let is_spi_xfer = i.opcode ==:. 13 in
  let is_i2c_write = i.opcode ==:. 14 in

  let uart_rx_complete =
    is_uart_rx &: i.uart_rx_valid
  in

  let spi_xfer_complete =
    is_spi_xfer &: i.spi_valid
  in

  let write_enable =
    is_set
    |: is_clr
    |: is_dec
    |: uart_rx_complete
    |: spi_xfer_complete
  in

  let write_register =
    select i.register 1 0
  in

  let set_data = uresize i.immediate 32 in
  let clr_data = zero 32 in
  let dec_data = i.register_value -:. 1 in
  let uart_rx_data = uresize i.uart_rx_data 32 in
  let spi_rx_data = uresize i.spi_data_out 32 in

  let write_data =
    mux2 is_set
      set_data
      (mux2 is_clr
        clr_data
        (mux2 is_dec
          dec_data
          (mux2 uart_rx_complete
            uart_rx_data
            spi_rx_data)))
  in

  let gpio_write_enable = is_set_pin |: is_clr_pin in
  let gpio_write_data = is_set_pin in
  let shift_load = is_shift_out in
  let shift_data = select i.register_value 7 0 in

  let uart_start =
    is_uart_tx &: (~:(i.uart_busy))
  in

  let uart_data =
    select i.register_value 7 0
  in

  let uart_rx_consume = uart_rx_complete in

  let spi_start =
    is_spi_xfer
    &: (~:(i.spi_busy))
    &: (~:(i.spi_valid))
  in

  let spi_data =
    select i.register_value 7 0
  in

  let i2c_start =
    is_i2c_write
    &: (~:(i.i2c_busy))
    &: (~:(i.i2c_done))
  in

  let i2c_data =
    select i.register_value 7 0
  in

  { O.write_enable
  ; write_register
  ; write_data
  ; gpio_write_enable
  ; gpio_write_data
  ; shift_load
  ; shift_data
  ; uart_start
  ; uart_data
  ; uart_rx_consume
  ; spi_start
  ; spi_data
  ; i2c_start
  ; i2c_data
  }

