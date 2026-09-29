open Hardcaml
open Signal

module I = struct
  type 'a t =
    { clk : 'a
    ; reset : 'a
    ; enable : 'a
    ; jump : 'a
    ; target : 'a [@bits 8]
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { pc : 'a [@bits 8]
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

  let pc = wire 8 in

  let incremented_pc =
    pc +:. 1
  in

  let next_pc =
    mux2 i.jump
      i.target
      (mux2 i.enable
        incremented_pc
        pc)
  in

  assign pc (reg spec next_pc);

  { O.pc }
