
open Hardcaml
open Signal

module I = struct
  type 'a t =
    { clk : 'a
    ; reset : 'a
    ; uart_rx : 'a
    ; spi_miso : 'a
    ; i2c_scl_in : 'a
    ; i2c_sda_in : 'a
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
    ; spi_sclk : 'a
    ; spi_mosi : 'a
    ; spi_cs_n : 'a
    ; spi_busy : 'a
    ; spi_data_out : 'a [@bits 8]
    ; spi_valid : 'a
    ; i2c_scl_drive_low : 'a
    ; i2c_sda_drive_low : 'a
    ; i2c_busy : 'a
    ; i2c_done : 'a
    ; i2c_ack_error : 'a
    }
  [@@deriving hardcaml]
end

let create (scope : Scope.t) (i : _ I.t) =

  (* CPU control wires *)

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

  let spi_start = wire 1 in
  let spi_data = wire 8 in

  let i2c_start = wire 1 in
  let i2c_read_mode = wire 1 in
  let i2c_data = wire 8 in

  (* Program counter *)

  let pc =
    Program_counter.create scope
      { Program_counter.I.clk = i.clk
      ; reset = i.reset
      ; enable = pc_enable
      ; jump = pc_jump
      ; target = pc_target
      }
  in

  (* Instruction memory *)

  let memory =
    Instruction_memory.create scope
      { Instruction_memory.I.address = pc.pc }
  in

  (* Instruction decoder *)

  let decoded =
    Instruction.create scope
      { Instruction.I.instruction = memory.instruction }
  in

  (* Register file *)

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

  (* Protocol timing: R1 controls the clock period *)

  let configured_protocol_period =
    select registers.r1 7 0
  in

  let protocol_period =
    mux2
      (configured_protocol_period ==:. 0)
      (of_int ~width:8 8)
      configured_protocol_period
  in

  (* UART transmitter *)

  let uart_tx =
    Uart_tx.create scope
      { Uart_tx.I.clk = i.clk
      ; reset = i.reset
      ; start = uart_start
      ; data_in = uart_data
      ; bit_period = protocol_period
      }
  in

  (* UART receiver *)

  let uart_rx =
    Uart_rx.create scope
      { Uart_rx.I.clk = i.clk
      ; reset = i.reset
      ; rx = i.uart_rx
      ; bit_period = protocol_period
      ; consume = uart_rx_consume
      }
  in

  (* SPI master *)

  let spi =
    Spi_master.create scope
      { Spi_master.I.clk = i.clk
      ; reset = i.reset
      ; start = spi_start
      ; data_in = spi_data
      ; miso = i.spi_miso
      ; clock_period = protocol_period
      }
  in

  (* I2C master: supports WRITE and READ *)

  let i2c =
    I2c_master.create scope
      { I2c_master.I.clk = i.clk
      ; reset = i.reset
      ; start = i2c_start
      ; read_mode = i2c_read_mode
      ; address = select registers.r2 6 0
      ; data_in = i2c_data
      ; clock_period = protocol_period
      ; scl_in = i.i2c_scl_in
      ; sda_in = i.i2c_sda_in
      }
  in

  (* Execution unit *)

  let execution =
    Execution_unit.create scope
      { Execution_unit.I.opcode = decoded.opcode
      ; register = decoded.register
      ; immediate = decoded.immediate
      ; register_value = registers.read_data
      ; uart_busy = uart_tx.busy
      ; uart_rx_valid = uart_rx.valid
      ; uart_rx_data = uart_rx.data_out
      ; spi_busy = spi.busy
      ; spi_valid = spi.valid
      ; spi_data_out = spi.data_out
      ; i2c_busy = i2c.busy
      ; i2c_done = i2c.done_
      ; i2c_data_out = i2c.data_out
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

  assign spi_start execution.spi_start;
  assign spi_data execution.spi_data;

  assign i2c_start execution.i2c_start;
  assign i2c_read_mode execution.i2c_read_mode;
  assign i2c_data execution.i2c_data;

  (* Wait counter *)

  let wait_counter =
    Wait_counter.create scope
      { Wait_counter.I.clk = i.clk
      ; reset = i.reset
      ; load = wait_load
      ; start = vdd
      ; cycles = decoded.immediate
      }
  in

  (* Program counter control *)

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
      ; spi_busy = spi.busy
      ; spi_valid = spi.valid
      ; i2c_busy = i2c.busy
      ; i2c_done = i2c.done_
      }
  in

  assign pc_enable pc_control.pc_enable;
  assign pc_jump pc_control.pc_jump;
  assign pc_target pc_control.pc_target;
  assign wait_load pc_control.wait_load;

  (* GPIO *)

  let gpio =
    Gpio.create scope
      { Gpio.I.clk = i.clk
      ; reset = i.reset
      ; write_enable = gpio_write_enable
      ; write_data = gpio_write_data
      }
  in

  (* Shift output *)

  let shift_out =
    Shift_out.create scope
      { Shift_out.I.clk = i.clk
      ; reset = i.reset
      ; start = shift_load
      ; data_in = shift_data
      ; bit_period = protocol_period
      }
  in

  (* Core outputs *)

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

  ; spi_sclk = spi.sclk
  ; spi_mosi = spi.mosi
  ; spi_cs_n = spi.cs_n
  ; spi_busy = spi.busy
  ; spi_data_out = spi.data_out
  ; spi_valid = spi.valid

  ; i2c_scl_drive_low = i2c.scl_drive_low
  ; i2c_sda_drive_low = i2c.sda_drive_low
  ; i2c_busy = i2c.busy
  ; i2c_done = i2c.done_
  ; i2c_ack_error = i2c.ack_error
  }
