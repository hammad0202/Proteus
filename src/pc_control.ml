open Hardcaml
open Signal

module I = struct
  type 'a t =
    { opcode : 'a [@bits 4]
    ; immediate : 'a [@bits 8]
    ; register_value : 'a [@bits 32]
    ; wait_busy : 'a
    ; wait_done : 'a
    ; uart_busy : 'a
    ; uart_done : 'a
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { pc_enable : 'a
    ; pc_jump : 'a
    ; pc_target : 'a [@bits 8]
    ; wait_load : 'a
    }
  [@@deriving hardcaml]
end

let create (_scope : Scope.t) (i : _ I.t) =
  let is_wait = i.opcode ==:. 3 in
  let is_jmp = i.opcode ==:. 4 in
  let is_jnz = i.opcode ==:. 5 in
  let is_uart_tx = i.opcode ==:. 11 in

  let register_nonzero =
    i.register_value <>:. 0
  in

  let jnz_taken =
    is_jnz &: register_nonzero
  in

  let pc_jump =
    is_jmp |: jnz_taken
  in

  (* WAIT *)
  let wait_load =
    is_wait &: (i.wait_busy ==:. 0)
  in

  let wait_active =
    is_wait &: i.wait_busy
  in

  let wait_finished =
    is_wait &: i.wait_done
  in

  (* UART_TX
     
     Keep the PC on the UART_TX instruction for the entire
     transmission. The execution unit starts UART only when
     uart_busy = 0, so the same instruction cannot restart
     while the UART is busy.
  *)
  let uart_active =
    is_uart_tx
  in

  let uart_finished =
    is_uart_tx &: i.uart_done
  in

  let pc_enable =
    ((~:wait_active) |: wait_finished)
    &: ((~:uart_active) |: uart_finished)
  in

  let pc_target =
    i.immediate
  in

  { O.pc_enable
  ; pc_jump
  ; pc_target
  ; wait_load
  }
