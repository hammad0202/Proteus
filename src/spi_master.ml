open Hardcaml
open Signal

module I = struct
  type 'a t =
    { clk : 'a
    ; reset : 'a
    ; start : 'a
    ; data_in : 'a [@bits 8]
    ; clock_period : 'a [@bits 8]
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { sclk : 'a
    ; mosi : 'a
    ; cs_n : 'a
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

  (* ------------------------------------------------------------ *)
  (* SPI MASTER - MODE 0                                          *)
  (*                                                              *)
  (* CPOL = 0                                                     *)
  (* CPHA = 0                                                     *)
  (* MSB first                                                    *)
  (*                                                              *)
  (* MOSI is valid before each rising SCLK edge.                   *)
  (* Receiver samples MOSI on rising edge.                         *)
  (* Transmitter advances data on falling edge.                    *)
  (* ------------------------------------------------------------ *)

  let shift_reg = wire 8 in
  let bits_remaining = wire 4 in
  let timer = wire 8 in
  let sclk_reg = wire 1 in

  (* ------------------------------------------------------------ *)
  (* STATUS                                                       *)
  (* ------------------------------------------------------------ *)

  let busy =
    bits_remaining <>:. 0
  in

  let timer_done =
    timer ==:. 0
  in

  (* ------------------------------------------------------------ *)
  (* CLOCK PERIOD                                                 *)
  (* ------------------------------------------------------------ *)

  (* Never allow a zero clock period. *)
  let safe_period =
    mux2
      (i.clock_period ==:. 0)
      (of_int ~width:8 2)
      i.clock_period
  in

  (* Each SCLK level lasts half of the requested period. *)
  let half_period =
    uresize
      (select safe_period 7 1)
      8
  in

  (* Protect against periods that would produce half_period = 0. *)
  let safe_half_period =
    mux2
      (half_period ==:. 0)
      (of_int ~width:8 1)
      half_period
  in

  let reload_timer =
    safe_half_period -:. 1
  in

  (* ------------------------------------------------------------ *)
  (* SPI CLOCK CONTROL                                            *)
  (* ------------------------------------------------------------ *)

  let toggle =
    busy &: timer_done
  in

  (* When SCLK is currently high and a toggle occurs,
     this is the falling edge. *)
  let falling_edge =
    toggle &: sclk_reg
  in

  let last_bit =
    bits_remaining ==:. 1
  in

  (* Transaction finishes after the falling edge following
     the eighth sampled bit. *)
  let finish =
    falling_edge &: last_bit
  in

  (* ------------------------------------------------------------ *)
  (* SHIFT REGISTER                                               *)
  (* ------------------------------------------------------------ *)

  (* Shift toward the MSB output.

     Example:

       data = 0xA5 = 10100101

     MOSI sequence:

       1 0 1 0 0 1 0 1
  *)

  let shifted =
    concat_msb
      [ select shift_reg 6 0
      ; zero 1
      ]
  in

  let next_shift_reg =
    mux2 i.start
      i.data_in
      (mux2
        (falling_edge &: (~:last_bit))
        shifted
        shift_reg)
  in

  (* ------------------------------------------------------------ *)
  (* BIT COUNTER                                                  *)
  (* ------------------------------------------------------------ *)

  let next_bits_remaining =
    mux2 i.start
      (of_int ~width:4 8)
      (mux2 falling_edge
        (bits_remaining -:. 1)
        bits_remaining)
  in

  (* ------------------------------------------------------------ *)
  (* SCLK REGISTER                                                *)
  (* ------------------------------------------------------------ *)

  let next_sclk =
    mux2 i.start
      gnd
      (mux2 finish
        gnd
        (mux2 toggle
          (~:sclk_reg)
          sclk_reg))
  in

  (* ------------------------------------------------------------ *)
  (* TIMER                                                        *)
  (* ------------------------------------------------------------ *)

  let next_timer =
    mux2 i.start
      reload_timer
      (mux2 busy
        (mux2 timer_done
          reload_timer
          (timer -:. 1))
        timer)
  in

  (* ------------------------------------------------------------ *)
  (* DONE                                                         *)
  (* ------------------------------------------------------------ *)

  let done_ =
    finish
  in

  (* ------------------------------------------------------------ *)
  (* REGISTERS                                                    *)
  (* ------------------------------------------------------------ *)

  assign shift_reg
    (reg spec next_shift_reg);

  assign bits_remaining
    (reg spec next_bits_remaining);

  assign timer
    (reg spec next_timer);

  assign sclk_reg
    (reg spec next_sclk);

  (* ------------------------------------------------------------ *)
  (* OUTPUTS                                                      *)
  (* ------------------------------------------------------------ *)

  { O.sclk = sclk_reg
  ; mosi = select shift_reg 7 7
  ; cs_n = ~:busy
  ; busy
  ; done_
  }
