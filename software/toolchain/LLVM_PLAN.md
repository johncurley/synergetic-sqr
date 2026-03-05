# SPU-13 Toolchain: The Synergetic Compiler
## LLVM Backend Specification for Isotropic Primitives (v2.9.21)

To transition from manual C++ to an actual compiler, we must extend the LLVM IR to understand 4D Tetrahedral vectors as a first-class primitive type.

### 1. The SQR Type System
*   **`v4q` (Vector 4 Quadray):** An 832-bit SIMD type representing the ABCD-manifold.
*   **`s64` (Surd 64):** An 128-bit type representing $(a + b\sqrt{3})$.

### 2. Isotropic Optimization Passes
The compiler must implement the following passes to eliminate 'Cubic' overhead:
*   **`SurdStrengthReduction`:** Recognizes 60°/90°/120° rotations and replaces transcendental calls with bit-exact `SPERM_X4` machine code.
*   **`PhyllotaxisScheduling`:** Automatically re-orders memory access to follow Fibonacci-Spiral address patterns in G-RAM.

### 3. High-Level Synthesis (HLS)
Using **Xilinx Vitis HLS**, we can map the `SynergeticsMath.hpp` primitives directly to Artix-7 logic gates.
*   **Strategy:** Utilize `#pragma HLS pipeline` on our `_spu_surd_mul` functions to achieve single-cycle throughput on the physical ALU.

### 4. Machine Code Generation
*   **Target:** `riscv64-unknown-elf` with the `Z_sqr` custom isotropic extension.
*   **Assembler:** Integration with the `spu13_asm.rs` translator.

---
*Status: ARCHITECTURAL DRAFT. Defining the translator for the Absolute.*
