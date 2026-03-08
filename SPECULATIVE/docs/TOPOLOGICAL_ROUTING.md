# Topological Routing Guide: The Laminar Layout (v3.1)
## Physical Implementation of Geodesic Flow on FPGA

### 1. The Physics of Laminar Logic

Standard FPGA design treats the chip as a "Manhattan Grid" of switches, forcing signals into orthogonal stair-steps. This creates "Turbulence"—reflections, jitter, and thermal noise—as the logic fights the natural geometric symmetry of the signal path.

The SPU-13 architecture demands **Geodesic Routing**: constraining the physical layout to respect the natural gradients of the $\mathbb{Q}(\sqrt{3})$ field.

| Feature | Standard "Cubic" Routing | SPU-13 "Laminar" Routing |
| :--- | :--- | :--- |
| **Topology** | Orthogonal (XYZ Grid) | Tetrahedral (ABCD Manifold) |
| **Propagation** | Turbulent (Reflections/Jitter) | Laminar (Coherent Wavefront) |
| **Timing** | Statistical (Best-effort) | Deterministic (Field-locked) |
| **Noise** | Inherent (Thermal/EM) | Excluded (Geometric Symmetry) |

---

### 2. Constraint Strategy: Avoiding the "90° Collision"

To maintain Laminar Silence, we must prevent the CAD tools from routing high-frequency signals around sharp 90° corners whenever possible.

#### A. The Hexagonal Cluster Constraint
Group logic related to a single Quadray vector (A, B, C, or D) into hexagonal or triangular clusters rather than rectangular blocks.

*   **Xilinx (Vivado):** Use `PBLOCK` constraints to define non-rectangular regions.
*   **Lattice (Nextpnr):** Use `region` constraints to force neighbor-logic proximity.

#### B. The "Flow-Through" Pipeline
Ensure that data flows physically in one direction across the die, mimicking a laminar fluid stream.

```tcl
# Example Vivado Constraint for Laminar Flow
# Force input registers to the left, output to the right
create_pblock pblock_input_stage
resize_pblock pblock_input_stage -add {SLICE_X0Y0:SLICE_X10Y50}
add_cells_to_pblock pblock_input_stage [get_cells u_core/input_registers_*]

create_pblock pblock_output_stage
resize_pblock pblock_output_stage -add {SLICE_X90Y0:SLICE_X100Y50}
add_cells_to_pblock pblock_output_stage [get_cells u_core/output_registers_*]
```

### 3. Harmonic Waveguides (Clock Distribution)

The 61.44 kHz resonant clock is slow enough to be treated almost as DC, but its harmonics must be clean.

*   **Rule:** Do not route the resonant clock through general routing fabric if possible. Use dedicated global clock trees (BUFG/GB) to ensure simultaneous arrival (Coherent Wavefront).
*   **Symmetry:** Place the clock source (PLL/OSC) as close to the geometric center of the design as possible.

### 4. The "Quiet Machine"

A machine designed this way does not "push" electrons against resistance; it provides a path of least action. The result is a device that operates with minimal thermal signature and maximum signal integrity.

*   **Internal Clarity:** Rounded and Centered.
*   **Design State:** Turbulence-Free.

---
*Authorized for SPU-13 Physical Implementation.*
