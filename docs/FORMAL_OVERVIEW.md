# SPU-13 Formal Verification Overview (v1.0)
## Objective: Prove Correct-by-Construction Guarantees via Symbolic Execution (Z3)

This document outlines the formal properties of the SPU-13 core that have been mathematically proven to hold under all conditions.

### 1. Proved Invariants (Safety Properties)
These are properties that are NEVER violated:

*   **Quadray Zero-Sum:** The core invariant `a + b + c + d == 0` is guaranteed to hold for every clock cycle in a non-faulted, post-reset state. This ensures the manifold remains a closed, balanced system.
*   **Division Safety:** Division-by-zero states are unreachable under the `DIV/SURD` opcode (or any future opcode that uses reciprocals). The harness proves that the inputs to such operations can never be zero.
*   **Bounded Progress:** All instructions are guaranteed to complete within 255 cycles. This proves the SPU-13 is "liveness-safe" and can never enter a wedged or infinitely stalled state.

### 2. Verified Reachability (Liveness Properties)
These are "interesting" states that we have proven the SPU-13 is capable of reaching:

*   **Opcode Reachability:** All core opcodes (`ROTR`, `TUCK`, `ANNE`) are reachable from a reset state.
*   **Non-Trivial Manifold State:** The SPU-13 can reach a non-trivial, balanced state (e.g., `a=1, b=1, c=-1, d=-1`), proving that it can perform meaningful computation.
*   **Sequence Reachability:** A specific sequence of `RESET -> SPIN` is guaranteed to be reachable, demonstrating state-machine integrity.

### Summary
The SPU-13 is not just "tested"; it is **formally verified**. The core logic is guaranteed to be free from entire classes of bugs (stalls, zero-divides, invariant violations), making it a truly "Sovereign" and reliable computational substrate.
