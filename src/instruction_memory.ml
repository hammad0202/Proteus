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

      (* Load SPI data. *)
      | 0 -> of_int ~width:16 0x10A5  (* SET R0, 0xA5 *)

      (* Configure protocol timing. *)
      | 1 -> of_int ~width:16 0x1108  (* SET R1, 8 *)

      (* Transmit R0 through SPI. *)
      | 2 -> of_int ~width:16 0xD000  (* SPI_TX R0 *)

      (* Repeat SPI transmission. *)
      | 3 -> of_int ~width:16 0x4002  (* JMP 2 *)

      | _ -> of_int ~width:16 0x0000)
  in

  { O.instruction = mux i.address (Array.to_list memory) }
