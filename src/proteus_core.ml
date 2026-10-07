open Hardcaml
open Signal

module I = struct
  type 'a t =
    { clk : 'a
    ; reset : 'a
    ; uart_rx : 'a
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { pc : 'a [@bits 8]
    ; instruction : 'a [@bits 16]
    ; opcode : 'a [@bits 4]
    ; register : 'a [@bits 4]
    ; immediate : 'a [@bits 8]
    ; r0 : 'a [@bits 32]
    ; r1 : 'a [@bits 32]
    ; r2 : 'a [@bits 32]
    ; r3 : 'a [@bits 32]
    ; gpio_out : 'a
    ; shift_busy : 'a
    ; uart_busy : 'a
    }
  [@@deriving hardcaml]
end

let create (scope : Scope.t) (i : _ I.t) =

  let pc_enable = wire 1 in
  let pc_jump = wire 1 in
  let pc_target = wire 8 in

  let wait_load = wire 1 in

  let register_write_enable = wire 1 in
  let register_write_register = wire 2 in
  let register_write_data = wire 32 in

  let gpio_write_enable = wire 1 in
  let gpio_write_data = wire 1 in

  let shift_load = wire 1 in
  let shift_data = wire 8 in

  let uart_start = wire 1 in
  let uart_data = wire 8 in
  let uart_rx_consume = wire 1 in

  let pc =
    Program_counter.create scope
      { Program_counter.I.clk = i.clk
      ; reset = i.reset
      ; enable = pc_enable
      ; jump = pc_jump
      ; target = pc_target
      }
  in

  let memory =
    Instruction_memory.create scope
      { Instruction_memory.I.address = pc.pc
      }
  in

  let decoded =
    Instruction.create scope
      { Instruction.I.instruction = memory.instruction
      }
  in

  let registers =
    Register_file.create scope
      { Register_file.I.clk = i.clk
      ; reset = i.reset
      ; write_enable = register_write_enable
      ; write_register = register_write_register
      ; write_data = register_write_data
      ; read_register = select decoded.register 1 0
      }
  in

  let configured_uart_bit_period =
  select registers.r1 7 0
in

let uart_bit_period =
  mux2
    (configured_uart_bit_period ==:. 0)
    (of_int ~width:8 8)
    configured_uart_bit_period
in

  let uart_tx =
    Uart_tx.create scope
      { Uart_tx.I.clk = i.clk
      ; reset = i.reset
      ; start = uart_start
      ; data_in = uart_data
      ; bit_period = uart_bit_period
      }
  in

  let uart_rx =
    Uart_rx.create scope
      { Uart_rx.I.clk = i.clk
      ; reset = i.reset
      ; rx = i.uart_rx
      ; bit_period = uart_bit_period
      ; consume = uart_rx_consume
      }
  in

  let execution =
    Execution_unit.create scope
      { Execution_unit.I.opcode = decoded.opcode
      ; register = decoded.register
      ; immediate = decoded.immediate
      ; register_value = registers.read_data
      ; uart_busy = uart_tx.busy
      ; uart_rx_valid = uart_rx.valid
      ; uart_rx_data = uart_rx.data_out
      }
  in

  assign register_write_enable execution.write_enable;
  assign register_write_register execution.write_register;
  assign register_write_data execution.write_data;

  assign gpio_write_enable execution.gpio_write_enable;
  assign gpio_write_data execution.gpio_write_data;

  assign shift_load execution.shift_load;
  assign shift_data execution.shift_data;

  assign uart_start execution.uart_start;
  assign uart_data execution.uart_data;
  assign uart_rx_consume execution.uart_rx_consume;

  let wait_counter =
    Wait_counter.create scope
      { Wait_counter.I.clk = i.clk
      ; reset = i.reset
      ; load = wait_load
      ; start = vdd
      ; cycles = decoded.immediate
      }
  in

  let pc_control =
    Pc_control.create scope
      { Pc_control.I.opcode = decoded.opcode
      ; immediate = decoded.immediate
      ; register_value = registers.read_data
      ; wait_busy = wait_counter.busy
      ; wait_done = wait_counter.done_
      ; uart_busy = uart_tx.busy
      ; uart_done = uart_tx.done_
      ; uart_rx_valid = uart_rx.valid
      }
  in

  assign pc_enable pc_control.pc_enable;
  assign pc_jump pc_control.pc_jump;
  assign pc_target pc_control.pc_target;
  assign wait_load pc_control.wait_load;

  let gpio =
    Gpio.create scope
      { Gpio.I.clk = i.clk
      ; reset = i.reset
      ; write_enable = gpio_write_enable
      ; write_data = gpio_write_data
      }
  in

  let shift_out =
    Shift_out.create scope
      { Shift_out.I.clk = i.clk
      ; reset = i.reset
      ; start = shift_load
      ; data_in = shift_data
      ; bit_period = uart_bit_period
      }
  in

  { O.pc = pc.pc
  ; instruction = memory.instruction
  ; opcode = decoded.opcode
  ; register = decoded.register
  ; immediate = decoded.immediate
  ; r0 = registers.r0
  ; r1 = registers.r1
  ; r2 = registers.r2
  ; r3 = registers.r3
  ; gpio_out =
      mux2 uart_tx.busy
        uart_tx.tx
        (mux2 shift_out.busy
          shift_out.data_out
          gpio.gpio_out)
  ; shift_busy = shift_out.busy
  ; uart_busy = uart_tx.busy
  }
