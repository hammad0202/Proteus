open Hardcaml
open Signal

module I = struct
  type 'a t =
    { clk : 'a
    ; reset : 'a
    ; write_enable : 'a
    ; write_register : 'a [@bits 2]
    ; write_data : 'a [@bits 32]
    ; read_register : 'a [@bits 2]
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { read_data : 'a [@bits 32]
    ; r0 : 'a [@bits 32]
    ; r1 : 'a [@bits 32]
    ; r2 : 'a [@bits 32]
    ; r3 : 'a [@bits 32]
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

  let registers =
    Array.init 4 (fun _ -> wire 32)
  in

  Array.iteri
    (fun index register_wire ->
      let write =
        i.write_enable &: (i.write_register ==:. index)
      in

      let next_value =
        mux2 write i.write_data register_wire
      in

      assign register_wire (reg spec next_value))
    registers;

  let read_data =
    mux i.read_register (Array.to_list registers)
  in

  { O.read_data
  ; r0 = registers.(0)
  ; r1 = registers.(1)
  ; r2 = registers.(2)
  ; r3 = registers.(3)
  }

