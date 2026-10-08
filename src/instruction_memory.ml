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
      | 0 -> of_int ~width:16 0x10A5
      | 1 -> of_int ~width:16 0x1108
      | 2 -> of_int ~width:16 0x1250
      | 3 -> of_int ~width:16 0xE000
      | 4 -> of_int ~width:16 0x4004
      | _ -> of_int ~width:16 0x0000)
  in

  { O.instruction =
      mux i.address (Array.to_list memory)
  }

