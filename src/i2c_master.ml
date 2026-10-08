
open Hardcaml
open Signal

module I = struct
  type 'a t =
    { clk : 'a
    ; reset : 'a
    ; start : 'a
    ; read_mode : 'a
    ; address : 'a [@bits 7]
    ; data_in : 'a [@bits 8]
    ; clock_period : 'a [@bits 8]
    ; scl_in : 'a
    ; sda_in : 'a
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { scl_drive_low : 'a
    ; sda_drive_low : 'a
    ; busy : 'a
    ; done_ : 'a
    ; ack_error : 'a
    ; data_out : 'a [@bits 8]
    }
  [@@deriving hardcaml]
end

let create (_scope : Scope.t) (i : _ I.t) =
  let spec =
    Reg_spec.create ~clock:i.clk ~reset:i.reset ()
  in

  let state = wire 4 in
  let timer = wire 8 in
  let bit_index = wire 4 in

  let address_reg = wire 8 in
  let data_reg = wire 8 in
  let read_mode_reg = wire 1 in
  let rx_reg = wire 8 in

  let ack_error_reg = wire 1 in
  let done_reg = wire 1 in

  let idle_state = 0 in
  let start_state = 1 in
  let address_low_state = 2 in
  let address_high_state = 3 in
  let address_ack_low_state = 4 in
  let address_ack_high_state = 5 in
  let data_low_state = 6 in
  let data_high_state = 7 in
  let data_ack_low_state = 8 in
  let data_ack_high_state = 9 in
  let stop_low_state = 10 in
  let stop_high_state = 11 in
  let stop_release_state = 12 in

  let safe_period =
    mux2 (i.clock_period ==:. 0)
      (of_int ~width:8 8)
      i.clock_period
  in

  let half_period =
    uresize (select safe_period 7 1) 8
  in

  let safe_half_period =
    mux2 (half_period ==:. 0)
      (of_int ~width:8 1)
      half_period
  in

  let reload_timer = safe_half_period -:. 1 in
  let timer_done = timer ==:. 0 in
  let busy = state <>:. idle_state in

  let current_address_bit =
    mux bit_index
      [ select address_reg 7 7
      ; select address_reg 6 6
      ; select address_reg 5 5
      ; select address_reg 4 4
      ; select address_reg 3 3
      ; select address_reg 2 2
      ; select address_reg 1 1
      ; select address_reg 0 0
      ; gnd; gnd; gnd; gnd
      ; gnd; gnd; gnd; gnd
      ]
  in

  let current_data_bit =
    mux bit_index
      [ select data_reg 7 7
      ; select data_reg 6 6
      ; select data_reg 5 5
      ; select data_reg 4 4
      ; select data_reg 3 3
      ; select data_reg 2 2
      ; select data_reg 1 1
      ; select data_reg 0 0
      ; gnd; gnd; gnd; gnd
      ; gnd; gnd; gnd; gnd
      ]
  in

  let advance = busy &: timer_done in

  let start_transaction =
    (state ==:. idle_state) &: i.start
  in

  let address_finished =
    bit_index ==:. 7
  in

  let state_after_timer =
    mux state
      [ of_int ~width:4 idle_state
      ; of_int ~width:4 address_low_state
      ; of_int ~width:4 address_high_state
      ; mux2 address_finished
          (of_int ~width:4 address_ack_low_state)
          (of_int ~width:4 address_low_state)
      ; of_int ~width:4 address_ack_high_state
      ; of_int ~width:4 data_low_state
      ; of_int ~width:4 data_high_state
      ; mux2 address_finished
          (of_int ~width:4 data_ack_low_state)
          (of_int ~width:4 data_low_state)
      ; of_int ~width:4 data_ack_high_state
      ; of_int ~width:4 stop_low_state
      ; of_int ~width:4 stop_high_state
      ; of_int ~width:4 stop_release_state
      ; of_int ~width:4 idle_state
      ; of_int ~width:4 idle_state
      ; of_int ~width:4 idle_state
      ; of_int ~width:4 idle_state
      ]
  in

  let increment_bit =
    advance
    &: ((state ==:. address_high_state)
        |: (state ==:. data_high_state))
    &: (bit_index <>:. 7)
  in

  let reset_bit =
    advance
    &: ((state ==:. start_state)
        |: (state ==:. address_ack_high_state))
  in

  let ack_sample =
    advance
    &: ((state ==:. address_ack_high_state)
        |: ((state ==:. data_ack_high_state)
            &: (~:read_mode_reg)))
  in

  let ack_failed = ack_sample &: i.sda_in in

  assign state
    (reg spec
       (mux2 start_transaction
          (of_int ~width:4 start_state)
          (mux2 advance state_after_timer state)));

  assign timer
    (reg spec
       (mux2 start_transaction
          reload_timer
          (mux2 advance
             reload_timer
             (mux2 busy (timer -:. 1) timer))));

  assign bit_index
    (reg spec
       (mux2 start_transaction
          (zero 4)
          (mux2 reset_bit
             (zero 4)
             (mux2 increment_bit
                (bit_index +:. 1)
                bit_index))));

  assign read_mode_reg
    (reg spec
       (mux2 start_transaction i.read_mode read_mode_reg));

  assign address_reg
    (reg spec
       (mux2 start_transaction
          (concat_msb [ i.address; i.read_mode ])
          address_reg));

  assign data_reg
    (reg spec
       (mux2 start_transaction i.data_in data_reg));

  assign ack_error_reg
    (reg spec
       (mux2 start_transaction
          gnd
          (mux2 ack_failed vdd ack_error_reg)));

  (* Sample received bits during SCL high. *)
  let rx_sample =
    advance
    &: (state ==:. data_high_state)
    &: read_mode_reg
  in

  assign rx_reg
    (reg spec
       (mux2 start_transaction
          (zero 8)
          (mux2 rx_sample
             (concat_msb [ select rx_reg 6 0; i.sda_in ])
             rx_reg)));

  let scl_drive_low =
    (state ==:. address_low_state)
    |: (state ==:. address_ack_low_state)
    |: (state ==:. data_low_state)
    |: (state ==:. data_ack_low_state)
    |: (state ==:. stop_low_state)
  in

  let sda_drive_low =
    (state ==:. start_state)
    |: ((state ==:. address_low_state)
        &: (~:current_address_bit))
    |: ((state ==:. address_high_state)
        &: (~:current_address_bit))
    |: ((state ==:. data_low_state)
        &: (~:read_mode_reg)
        &: (~:current_data_bit))
    |: ((state ==:. data_high_state)
        &: (~:read_mode_reg)
        &: (~:current_data_bit))
    |: (state ==:. stop_low_state)
    |: (state ==:. stop_high_state)
  in

  assign done_reg
    (reg spec
       (advance &: (state ==:. stop_release_state)));

  { O.scl_drive_low
  ; sda_drive_low
  ; busy
  ; done_ = done_reg
  ; ack_error = ack_error_reg
  ; data_out = rx_reg
  }

