open Hardcaml
open Signal

module I = struct
  type 'a t =
    { clk : 'a
    ; reset : 'a
    ; enable : 'a
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { count : 'a [@bits 32]
    }
  [@@deriving hardcaml]
end

let create (_scope : Scope.t) (i : _ I.t) =
  let spec =
    Reg_spec.create
      ~clock:i.clk
      ~reset:i.reset
      ()
  in

  let count = wire 32 in

  let next_count =
    mux2 i.enable
      (count +:. 1)
      count
  in

  assign count (reg spec next_count);

  { O.count = count }
