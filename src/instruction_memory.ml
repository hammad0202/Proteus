
open Hardcaml
open Signal

module I = struct
  type 'a t =
    { address : 'a [@bits 8] }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { instruction : 'a [@bits 16] }
  [@@deriving hardcaml]
end

type program =
  | I2c_read
  | I2c_write
  | Spi_transfer

let selected_program = ref I2c_read

let set_program program =
  selected_program := program

let instruction_at program address =
  match program, address with
  | I2c_read, 0 -> 0x1108
  | I2c_read, 1 -> 0x1250
  | I2c_read, 2 -> 0xF000
  | I2c_read, 3 -> 0x4003

  | I2c_write, 0 -> 0x10A5
  | I2c_write, 1 -> 0x1108
  | I2c_write, 2 -> 0x1250
  | I2c_write, 3 -> 0xE000
  | I2c_write, 4 -> 0x4004

  | Spi_transfer, 0 -> 0x10A5
  | Spi_transfer, 1 -> 0x1108
  | Spi_transfer, 2 -> 0xD000
  | Spi_transfer, 3 -> 0x4003

  | _ -> 0x0000

let create (_scope : Scope.t) (i : _ I.t) =
  let memory =
    Array.init 256 (fun address ->
      of_int
        ~width:16
        (instruction_at !selected_program address))
  in

  { O.instruction =
      mux i.address (Array.to_list memory) }
