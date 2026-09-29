open Hardcaml
open Signal

module I = struct
  type 'a t =
    { clk : 'a
    ; reset : 'a
    ; rx : 'a
    ; bit_period : 'a [@bits 8]
    ; consume : 'a
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { data_out : 'a [@bits 8]
    ; valid : 'a
    ; busy : 'a
    ; frame_error : 'a
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

  (* Synchronize asynchronous RX input. *)
  let rx_sync1 = wire 1 in
  let rx_sync2 = wire 1 in

  assign rx_sync1 (reg spec i.rx);
  assign rx_sync2 (reg spec rx_sync1);

  (* State:
       0 = IDLE
       1 = START
       2 = DATA
       3 = STOP
  *)
  let state = wire 2 in
  let timer = wire 8 in
  let bit_count = wire 4 in
  let data_reg = wire 8 in
  let valid_reg = wire 1 in
  let error_reg = wire 1 in

  let idle = of_int ~width:2 0 in
  let start_state = of_int ~width:2 1 in
  let data_state = of_int ~width:2 2 in
  let stop_state = of_int ~width:2 3 in

  let is_idle = state ==: idle in
  let is_start = state ==: start_state in
  let is_data = state ==: data_state in
  let is_stop = state ==: stop_state in

  let timer_done = timer ==:. 0 in

  (* Half-bit delay for center sampling of start bit. *)
  let half_period =
    uresize
      (select i.bit_period 7 1)
      8
  in

  let half_timer =
    half_period -:. 1
  in

  let full_timer =
    i.bit_period -:. 1
  in

  (* Start bit detected when RX is low while idle. *)
  let start_detect =
    is_idle &: (~:rx_sync2)
  in

  (* Center of start bit. *)
  let start_sample =
    is_start &: timer_done
  in

  (* Center of each data bit. *)
  let data_sample =
    is_data &: timer_done
  in

  (* Center of stop bit. *)
  let stop_sample =
    is_stop &: timer_done
  in

  (* ------------------------------------------------------------ *)
  (* STATE                                                        *)
  (* ------------------------------------------------------------ *)

  let state_after_start =
    mux2 rx_sync2
      idle
      data_state
  in

  let state_after_data =
    mux2 (bit_count ==:. 7)
      stop_state
      data_state
  in

  let state_after_start_sample =
    mux2 start_sample
      state_after_start
      state
  in

  let state_after_data_sample =
    mux2 data_sample
      state_after_data
      state_after_start_sample
  in

  let state_after_stop_sample =
    mux2 stop_sample
      idle
      state_after_data_sample
  in

  let next_state =
    mux2 start_detect
      start_state
      state_after_stop_sample
  in

  (* ------------------------------------------------------------ *)
  (* TIMER                                                        *)
  (* ------------------------------------------------------------ *)

  let timer_decrement =
    timer -:. 1
  in

  let timer_running =
    mux2 (is_start |: is_data |: is_stop)
      timer_decrement
      timer
  in

  let timer_after_start =
    mux2 start_sample
      full_timer
      timer_running
  in

  let timer_after_data =
    mux2 data_sample
      full_timer
      timer_after_start
  in

  let timer_after_stop =
    mux2 stop_sample
      (zero 8)
      timer_after_data
  in

  let next_timer =
    mux2 start_detect
      half_timer
      timer_after_stop
  in

  (* ------------------------------------------------------------ *)
  (* DATA BIT COUNTER                                             *)
  (* ------------------------------------------------------------ *)

  let incremented_bit_count =
    bit_count +:. 1
  in

  let bit_count_after_sample =
    mux2 (bit_count ==:. 7)
      (zero 4)
      incremented_bit_count
  in

  let next_bit_count =
    mux2 data_sample
      bit_count_after_sample
      bit_count
  in

  (* ------------------------------------------------------------ *)
  (* DATA REGISTER                                                *)
  (* ------------------------------------------------------------ *)

  (* UART data arrives LSB first.
     Shift each received bit into the MSB side. *)
  let shifted_data =
    concat_msb
      [ rx_sync2
      ; select data_reg 7 1
      ]
  in

  let next_data_reg =
    mux2 data_sample
      shifted_data
      data_reg
  in

  (* ------------------------------------------------------------ *)
  (* VALID / ERROR                                                *)
  (* ------------------------------------------------------------ *)

  let valid_after_receive =
    mux2 (stop_sample &: rx_sync2)
      vdd
      valid_reg
  in

  let next_valid =
    mux2 i.consume
      (zero 1)
      valid_after_receive
  in

  let error_after_receive =
    mux2 (stop_sample &: (~:rx_sync2))
      vdd
      error_reg
  in

  let next_error =
    mux2 i.consume
      (zero 1)
      error_after_receive
  in

  (* ------------------------------------------------------------ *)
  (* REGISTERS                                                     *)
  (* ------------------------------------------------------------ *)

  assign state
    (reg spec next_state);

  assign timer
    (reg spec next_timer);

  assign bit_count
    (reg spec next_bit_count);

  assign data_reg
    (reg spec next_data_reg);

  assign valid_reg
    (reg spec next_valid);

  assign error_reg
    (reg spec next_error);

  let busy =
    ~:is_idle
  in

  { O.data_out = data_reg
  ; valid = valid_reg
  ; busy
  ; frame_error = error_reg
  }
