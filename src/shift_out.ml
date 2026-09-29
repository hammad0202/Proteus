open Hardcaml
open Signal

module I = struct
  type 'a t =
    { clk : 'a
    ; reset : 'a
    ; start : 'a
    ; data_in : 'a [@bits 8]
    ; bit_period : 'a [@bits 8]
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { data_out : 'a
    ; busy : 'a
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

  let shift_reg = wire 8 in
  let bits_remaining = wire 4 in
  let timer = wire 8 in

  let busy =
    bits_remaining <>:. 0
  in

  let timer_done =
    timer ==:. 0
  in

  let shift =
    busy &: timer_done
  in

  let shifted =
    concat_msb
      [ select shift_reg 6 0
      ; zero 1
      ]
  in

  (* Load N-1 so that bit_period = N means exactly N clock cycles per bit. *)
  let initial_timer =
    i.bit_period -:. 1
  in

  let next_shift_reg =
    mux2 i.start
      i.data_in
      (mux2 shift
        shifted
        shift_reg)
  in

  let next_bits_remaining =
    mux2 i.start
      (of_int ~width:4 8)
      (mux2 shift
        (bits_remaining -:. 1)
        bits_remaining)
  in

  let next_timer =
    mux2 i.start
      initial_timer
      (mux2 shift
        initial_timer
        (timer -:. 1))
  in

  let done_ =
    shift &: (bits_remaining ==:. 1)
  in

  assign shift_reg (reg spec next_shift_reg);
  assign bits_remaining (reg spec next_bits_remaining);
  assign timer (reg spec next_timer);

  { O.data_out = select shift_reg 7 7
  ; busy
  ; done_
  }
