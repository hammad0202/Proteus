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

      (* UART configuration *)
      | 0 -> of_int ~width:16 0x1108  (* SET R1, 8 *)

      (* UART echo program *)
      | 1 -> of_int ~width:16 0xC000  (* UART_RX R0 *)
      | 2 -> of_int ~width:16 0xB000  (* UART_TX R0 *)
      | 3 -> of_int ~width:16 0x4000  (* JMP 0 *)

      (* NOP *)
      | _ -> of_int ~width:16 0x0000)
  in

  { O.instruction = mux i.address (Array.to_list memory) }

