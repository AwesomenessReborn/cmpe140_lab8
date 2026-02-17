# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CMPE 140 Lab 8 — A 32-bit MIPS SoC implemented in Verilog, targeting the Xilinx Basys 3 FPGA (Artix-7). The SoC integrates a MIPS CPU, memory subsystem, GPIO, and a hardware factorial accelerator.

## Simulation Commands

Run the testbench with iverilog:
```sh
# Compile all sources + testbench
iverilog -o sim/sim_out $(find src -name "*.v") sim/tb_soc_system.v

# Run simulation
vvp sim/sim_out
```

The testbench (`sim/tb_soc_system.v`) verifies factorial computation for N=3 (→6), N=4 (→24), N=5 (→120) using a 10ns clock period and 100ns reset.

## FPGA Build (Xilinx Vivado)

1. Add all `src/*.v` files as design sources
2. Set `src/soc_fpga.v` as the top-level module for FPGA synthesis (wraps clock gen and debouncing)
3. Add `constraint/mips_fpga.xdc` as the constraint file
4. Run Synthesis → Implementation → Generate Bitstream → Program Basys 3

For simulation-only work, use `src/soc_system.v` as top-level (no FPGA-specific clock primitives).

## Architecture

```
soc_fpga.v          (FPGA top: clock gen, button debounce)
└── soc_system.v    (SoC top: connects all subsystems)
    ├── mips.v      (CPU top: control + datapath)
    │   ├── controlunit.v  → maindec.v, auxdec.v
    │   └── datapath.v     → regfile.v, alu.v, muldivunit.v, mux2/3.v, adder.v, signext.v, register.v
    ├── imem.v              (64×32-bit instruction ROM, initialized from memfile.dat)
    ├── dmem.v              (64×32-bit data RAM)
    ├── address_decoder.v   (routes CPU memory accesses to dmem/gpio/factorial)
    ├── gpio_unit.v         (8-bit switches in, 8-bit LEDs out)
    └── factorial.v         (hardware accelerator)
        ├── fact_control_unit.v  (FSM: 6 states)
        └── fact_datapath.v      (counter + accumulator)
```

### Memory Map

| Address | Component |
|---------|-----------|
| `0x000–0x0FC` | Data memory (DMEM) |
| `0x800` | GPIO (switches read / LEDs write) |
| `0x900` | Factorial — write N, read N! result |
| `0x904` | Factorial — write GO (1), read DONE flag |

### Instruction Set

- **R-type**: ADD, SUB, AND, OR, SLT, SLL, SRL, MULT, MULTU
- **I-type**: ADDI, BEQ, LW, SW
- **J-type**: J, JAL
- **Special**: JALR

The ALU uses a 4-bit opcode. The datapath supports a 2-bit `regdst` selector (for normal, RT, and `$ra`/`$31` write-back), and a separate multiply/divide unit holds HI/LO registers.

### Factorial Accelerator Protocol

1. CPU writes N to address `0x900`
2. CPU writes `1` to address `0x904` (GO)
3. Poll `0x904` until DONE flag is set
4. CPU reads result from `0x900`

### Key Constraints (mips_fpga.xdc)

| Signal | Pin |
|--------|-----|
| 100 MHz clk | W5 |
| Reset (btnC) | W19 |
| Step (btnU) | U18 |
| SW[7:0] | W13–V17 |
| LED[7:0] | V14–U16 |

### Archive

`archive/` contains the Lab 6 version (basic MIPS CPU, no factorial accelerator or multiply/divide unit) — useful as a reference baseline.
