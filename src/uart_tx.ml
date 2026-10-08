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
    { tx : 'a
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

  let shift_reg = wire 10 in
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

  (* UART frame: stop bit, data bits, start bit *)
  let frame =
    concat_msb
      [ of_int ~width:1 1
      ; i.data_in
      ; of_int ~width:1 0
      ]
  in

  (* Shift right, inserting a high bit at the MSB. *)
  let shifted =
    concat_msb
      [ of_int ~width:1 1
      ; select shift_reg 9 1
      ]
  in

  let initial_timer =
    i.bit_period -:. 1
  in

  let next_shift_reg =
    mux2 i.start
      frame
      (mux2 shift
        shifted
        shift_reg)
  in

  let next_bits_remaining =
    mux2 i.start
      (of_int ~width:4 10)
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

  (* UART line must be high when idle. *)
  let tx =
    mux2 busy
      (select shift_reg 0 0)
      vdd
  in

  { O.tx = tx
  ; busy
  ; done_
  }
