open Hardcaml
open Signal

module I = struct
  type 'a t =
    { instruction : 'a [@bits 16]
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { opcode : 'a [@bits 4]
    ; register : 'a [@bits 4]
    ; immediate : 'a [@bits 8]
    }
  [@@deriving hardcaml]
end

let create (_scope : Scope.t) (i : _ I.t) =
  let opcode = select i.instruction 15 12 in
  let register = select i.instruction 11 8 in
  let immediate = select i.instruction 7 0 in

  { O.opcode
  ; register
  ; immediate
  }
