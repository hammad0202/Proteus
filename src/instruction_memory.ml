open Hardcaml
open Signal

module I = struct
  type 'a t =
    { address : 'a [@bits 8]
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { instruction : 'a [@bits 16]
    }
  [@@deriving hardcaml]
end

let create (_scope : Scope.t) (i : _ I.t) =
  let memory =
    Array.init 256 (fun address ->
      match address with

      (* H *)
      | 0 -> of_int ~width:16 0x1048  (* SET R0, 0x48 *)
      | 1 -> of_int ~width:16 0xB000  (* UART_TX R0 *)

      (* I *)
      | 2 -> of_int ~width:16 0x1049  (* SET R0, 0x49 *)
      | 3 -> of_int ~width:16 0xB000  (* UART_TX R0 *)

      (* ! *)
      | 4 -> of_int ~width:16 0x1021  (* SET R0, 0x21 *)
      | 5 -> of_int ~width:16 0xB000  (* UART_TX R0 *)

      (* NOP *)
      | _ -> of_int ~width:16 0x0000)
  in

  { O.instruction = mux i.address (Array.to_list memory) }

