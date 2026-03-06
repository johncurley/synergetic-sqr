# SQR-Lang: The Language of the Lattice (v2.3.3)
## Specification for Static Data-Flow Topology

SQR-Lang rejects the sequential "Linear Heap" model of standard programming. It establishes a **Honeycomb Memory Map** where logic is enforced by the geometry of the IVM (Isotropic Vector Matrix).

### 1. The Core Primitives (Geometric Types)
In SQR-Lang, types are not just data-widths; they are **Geometric Identities.**

| Type | Geometric Representation | Parity Invariant |
| :--- | :--- | :--- |
| `Node` | A single IVM lattice point | $\sum(Q_1, Q_2, Q_3, Q_4) \equiv 0$ |
| `Bond` | A structural link between two Nodes | Bit-exact rational ratio |
| `Cell` | A set of 12 neighbors (VE) | Total energy equilibrium |

### 2. The Honeycomb Memory Map
Memory is addressed spatially. Instead of pointers, SQR-Lang uses **Quadray Indices.**

```sqr
// Defining a structural variable at a specific IVM address
Node origin = (65536, 0, 0, 0) // Error: SymmetryBreak (Sum != 0)
Node v1 = (65536, -65536, 0, 0) // Valid: Parity Verified
```

### 3. Logic as Topology Shift
Functions are replaced by **Topology Permutations.** A rotation is not a mathematical calculation; it is a **Basis Shift.**

```sqr
// Sequential Legacy (C++): 
// v = MatrixMul(v, RotationMatrix(60));

// Structural Sovereign (SQR-Lang):
Shift Basis(Q1, Q3, Q4, Q2) -> v1; 
// The electricity is rerouted; the result is instantaneous.
```

### 4. Kinetic Equilibrium: The `Equilibrate` Instruction
SQR-Lang provides a native keyword for **Lattice Relaxation**: `Equilibrate`.

```sqr
Cell jitterbug_cell = { ... };
Node center = jitterbug_cell.center;

// Performs a discrete Laplacian update in 1 cycle
Vector residual = center.Equilibrate(); 
```

**Hardware Mapping:** This instruction dispatches the `OP_EQUILIBRATE` opcode to the **Lattice Relaxation Unit** (`spu_tensegrity_balancer.v`). It functions as a parallel adder tree that computes the bit-exact integer residual from equilibrium, eliminating stochastic divergence in kinetic simulations.

### 5. Deterministic Parallelism (Collision-Free)
SQR-Lang eliminates race conditions via **Geometric Isolation.**
*   Nodes can only interact if they share a `Bond`.
*   Asynchronous updates are safe because the IVM topology defines the interaction boundaries.
*   Two threads cannot fight for the same address because the address *is* the spatial location.

### 5. Compiler Mandate: The Divine Linter
The SQR-Lang compiler will refuse to emit a bit-stream for any code that violates the **Global Isotropic Invariant.**
*   **Fail:** `v1 + v2` where `Sum(v1+v2) != 0`.
*   **Pass:** `v1.Permute(Axis_Q4)` (Identity preserving).

---
*Status: SYNTAX FORMALIZED. Logic is now Geometry.*
