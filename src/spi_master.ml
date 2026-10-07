open Hardcaml
open Signal

module I = struct
  type 'a t =
    { clk : 'a
    ; reset : 'a
    ; start : 'a
    ; data_in : 'a [@bits 8]
    ; miso : 'a
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
    ; data_out : 'a [@bits 8]
    ; valid : 'a
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
  (* SPI MASTER - MODE 0 FULL DUPLEX                              *)
  (*                                                              *)
  (* CPOL = 0                                                     *)
  (* CPHA = 0                                                     *)
  (* MSB first                                                    *)
  (*                                                              *)
  (* MOSI is valid before each rising SCLK edge.                   *)
  (* MISO is sampled on each rising SCLK edge.                     *)
  (* TX advances on each falling SCLK edge.                        *)
  (* ------------------------------------------------------------ *)

  let tx_shift_reg = wire 8 in
  let rx_shift_reg = wire 8 in

  let bits_remaining = wire 4 in
  let timer = wire 8 in
  let sclk_reg = wire 1 in

  let data_out_reg = wire 8 in
  let valid_reg = wire 1 in

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

  let safe_period =
    mux2
      (i.clock_period ==:. 0)
      (of_int ~width:8 2)
      i.clock_period
  in

  let half_period =
    uresize
      (select safe_period 7 1)
      8
  in

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
  (* SPI CLOCK EDGES                                              *)
  (* ------------------------------------------------------------ *)

  let toggle =
    busy &: timer_done
  in

  (* Current SCLK = 0 and toggle means we are generating
     a rising edge. *)
  let rising_edge =
    toggle &: (~:sclk_reg)
  in

  (* Current SCLK = 1 and toggle means we are generating
     a falling edge. *)
  let falling_edge =
    toggle &: sclk_reg
  in

  let last_bit =
    bits_remaining ==:. 1
  in

  (* The eighth bit has already been sampled on the previous
     rising edge. Finish on its following falling edge. *)
  let finish =
    falling_edge &: last_bit
  in

  (* ------------------------------------------------------------ *)
  (* TX SHIFT REGISTER                                            *)
  (* ------------------------------------------------------------ *)

  let tx_shifted =
    concat_msb
      [ select tx_shift_reg 6 0
      ; zero 1
      ]
  in

  let next_tx_shift_reg =
    mux2 i.start
      i.data_in
      (mux2
        (falling_edge &: (~:last_bit))
        tx_shifted
        tx_shift_reg)
  in

  (* ------------------------------------------------------------ *)
  (* RX SHIFT REGISTER                                            *)
  (* ------------------------------------------------------------ *)

  (* Shift left and place the newly sampled MISO bit into bit 0.

     If the slave sends:

       0x3C = 00111100

     the eight rising-edge samples reconstruct:

       00111100
  *)

  let rx_shifted =
    concat_msb
      [ select rx_shift_reg 6 0
      ; i.miso
      ]
  in

  let next_rx_shift_reg =
    mux2 i.start
      (zero 8)
      (mux2 rising_edge
        rx_shifted
        rx_shift_reg)
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
  (* SCLK                                                         *)
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
  (* RECEIVE RESULT                                               *)
  (* ------------------------------------------------------------ *)

  (* On the final falling edge, rx_shift_reg already contains
     all eight MISO samples. *)
  let next_data_out =
    mux2 finish
      rx_shift_reg
      data_out_reg
  in

  (* valid is a one-cycle pulse when a complete byte is ready. *)
  let next_valid =
    finish
  in

  let done_ =
    finish
  in

  (* ------------------------------------------------------------ *)
  (* REGISTERS                                                    *)
  (* ------------------------------------------------------------ *)

  assign tx_shift_reg
    (reg spec next_tx_shift_reg);

  assign rx_shift_reg
    (reg spec next_rx_shift_reg);

  assign bits_remaining
    (reg spec next_bits_remaining);

  assign timer
    (reg spec next_timer);

  assign sclk_reg
    (reg spec next_sclk);

  assign data_out_reg
    (reg spec next_data_out);

  assign valid_reg
    (reg spec next_valid);

  (* ------------------------------------------------------------ *)
  (* OUTPUTS                                                      *)
  (* ------------------------------------------------------------ *)

  { O.sclk = sclk_reg
  ; mosi = select tx_shift_reg 7 7
  ; cs_n = ~:busy
  ; busy
  ; done_
  ; data_out = data_out_reg
  ; valid = valid_reg
  }
