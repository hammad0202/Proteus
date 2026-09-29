open Hardcaml
open Signal

module I = struct
  type 'a t =
    { clk : 'a
    ; reset : 'a
    ; write_enable : 'a
    ; write_data : 'a
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { gpio_out : 'a
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

  let output = wire 1 in

  let next_output =
    mux2 i.write_enable
      i.write_data
      output
  in

  assign output (reg spec next_output);

  { O.gpio_out = output }
