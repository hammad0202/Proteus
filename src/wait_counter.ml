open Hardcaml
open Signal

module I = struct
  type 'a t =
    { clk : 'a
    ; reset : 'a
    ; load : 'a
    ; start : 'a
    ; cycles : 'a [@bits 8]
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { busy : 'a
    ; done_ : 'a
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

  let counter = wire 8 in

  let counter_is_zero =
    counter ==:. 0
  in

  let counter_is_one =
    counter ==:. 1
  in

  let busy =
    ~:counter_is_zero
  in

  let done_ =
    counter_is_one
  in

  let loaded_counter =
    i.cycles +:. 1
  in

  let decremented_counter =
    counter -:. 1
  in

  let next_counter =
    mux2 i.load
      loaded_counter
      (mux2 busy
        decremented_counter
        counter)
  in

  assign counter (reg spec next_counter);

  { O.busy
  ; done_
  }
