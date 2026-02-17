# MIPS SoC with Hardware Factorial Accelerator

A fully functional 32-bit MIPS System-on-Chip (SoC) implemented in Verilog HDL and deployed on a Xilinx Basys 3 FPGA (Artix-7). The system integrates a custom-designed MIPS CPU, memory-mapped I/O, and a dedicated hardware accelerator for factorial computation — demonstrating hardware/software co-design on real silicon.

**Course**: CMPE 140 — Computer Architecture and Digital Design
**Platform**: Xilinx Basys 3 FPGA (Artix-7, 100 MHz)
**Language**: Verilog HDL
**Toolchain**: Xilinx Vivado, iverilog/ModelSim

---

## What Was Built

This project goes beyond simulation — every module was designed at the register-transfer level (RTL), synthesized, placed-and-routed, and verified running on physical FPGA hardware. The design covers the full digital design stack: ISA definition, datapath construction, control logic, memory subsystem, I/O interfacing, and hardware acceleration.

### Core Components

**MIPS CPU** — A single-cycle 32-bit MIPS processor built from scratch:
- Supports R-type (ADD, SUB, AND, OR, SLT, SLL, SRL, MULT, MULTU), I-type (ADDI, BEQ, LW, SW), J-type (J, JAL), and JALR instructions
- Extended ALU with 4-bit opcode for shift and multiply operations
- Dedicated multiply/divide unit with HI/LO register architecture
- 2-bit register destination selector supporting `$ra` write-back for JAL/JALR

**Hardware Factorial Accelerator** — A custom co-processor that offloads factorial computation from the CPU:
- Designed as a Moore FSM with 6 states (Idle → Validate → Compute → Done/Error)
- Datapath includes a down-counter and accumulator register controlled by the FSM
- Communicates with the CPU via memory-mapped registers; CPU triggers computation and polls for completion
- Runs concurrently with the CPU — demonstrates hardware/software co-design principles

**Memory Subsystem**:
- 64×32-bit instruction ROM initialized from a machine code file (`memfile.dat`)
- 64×32-bit data RAM with synchronous write
- Address decoder routes CPU memory accesses to the correct peripheral based on address

**GPIO Unit** — Maps 8 physical switches (input) and 8 LEDs (output) into the CPU address space, allowing MIPS assembly programs to read sensor input and drive outputs directly

---

## System Architecture

```
┌──────────────────────────────────────────────────┐
│                  soc_system.v                    │
│                                                  │
│  ┌──────────┐    ┌──────────┐    ┌────────────┐  │
│  │ MIPS CPU │───▶│ Address  │───▶│    DMEM    │  │
│  │          │◀───│ Decoder  │◀───│  (64×32b)  │  │
│  └──────────┘    │          │    └────────────┘  │
│       │          │          │    ┌────────────┐  │
│       │          │          │───▶│    GPIO    │  │
│  ┌────▼─────┐    │          │◀───│ SW / LEDs  │  │
│  │   IMEM   │    │          │    └────────────┘  │
│  │ (64×32b) │    │          │    ┌────────────┐  │
│  └──────────┘    │          │───▶│ Factorial  │  │
│                  └──────────┘◀───│ Accel. FSM │  │
└──────────────────────────────────────────────────┘
```

### Memory Map

| Address  | Peripheral         | Access        |
|----------|--------------------|---------------|
| `0x000–0x0FC` | Data Memory   | Read / Write  |
| `0x800`  | GPIO               | Read (SW) / Write (LED) |
| `0x900`  | Factorial — N / Result | Write N, then Read result |
| `0x904`  | Factorial — Control | Write GO=1, Read DONE flag |

The CPU triggers factorial computation in 3 steps:
1. `SW $t0, 0x900` — write input N
2. `SW $t1, 0x904` — pulse GO signal
3. Poll `0x904` until DONE, then read result from `0x900`

---

## Key Design Decisions

**Separate datapath/control architecture**: Each complex unit (CPU, factorial accelerator) splits into a datapath module and a control unit, following standard RTL design practice. This cleanly separates *what data flows where* from *when it flows*, making the design easier to reason about and extend.

**Hardware acceleration via memory-mapped co-processor**: Rather than computing factorials in software (which requires a multiply loop in assembly), the accelerator performs the computation in hardware in a handful of clock cycles. The CPU only needs to initiate the operation and read the result — a pattern used in real-world SoCs (DSP offload, crypto engines, etc.).

**Single-cycle CPU design**: All instructions complete in one clock cycle, simplifying control logic at the cost of the clock frequency being limited by the longest instruction path (typically LW through the ALU and data memory).

**Auto-clearing GO pulse**: The SoC-level logic converts a CPU register write into a single-cycle pulse to the factorial accelerator, preventing the accelerator from re-triggering on the same write.

---

## Repository Structure

```
src/               Verilog source files (synthesizable RTL)
  soc_system.v     SoC top-level (use for simulation)
  soc_fpga.v       FPGA top-level (adds clock gen + debouncing)
  mips.v           MIPS CPU top-level
  datapath.v       CPU datapath
  controlunit.v    CPU control unit
  factorial.v      Factorial accelerator top-level
  fact_control_unit.v   Factorial FSM
  fact_datapath.v       Factorial datapath
  memfile.dat      Instruction memory initialization (machine code)
sim/
  tb_soc_system.v  Testbench — simulates factorial of 3, 4, 5
constraint/
  mips_fpga.xdc    Xilinx pin constraints for Basys 3
archive/           Lab 6 baseline (MIPS CPU without accelerator)
```

---

## Running Simulation

```sh
# Compile
iverilog -o sim/sim_out $(find src -name "*.v") sim/tb_soc_system.v

# Run
vvp sim/sim_out
```

The testbench drives the switch input to N = 3, 4, 5 and verifies LED output shows 6, 24, and 120 respectively (8-bit binary on LEDs).

---

## Skills Demonstrated

- **RTL design in Verilog** — full SoC from scratch, not using IP cores
- **Computer architecture** — ISA design, datapath construction, hazard-free single-cycle control
- **FSM design** — Moore machine with datapath/control separation for the factorial unit
- **Hardware/software co-design** — CPU executes MIPS assembly that orchestrates a custom hardware accelerator
- **FPGA implementation** — synthesis, place-and-route, timing constraints, and physical deployment on Basys 3
- **Simulation and verification** — testbench-driven validation with expected output checking
