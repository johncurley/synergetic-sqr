# SPU-1 Deterministic Animation Kernel (DAK)
## Specification for Non-Transcendental Motion

### 1. Overview
The Deterministic Animation Kernel (DAK) provides the logic for fluid, repeating motion within the SPU-1 architecture. By replacing transcendental approximations ($\sin$, $\cos$, $\pi$) with **Rational Triangle Waves**, the DAK ensures that "Physical Life" (oscillation, breathing, rotation) remains bit-identical across infinite cycles.

### 2. The Rational Heartbeat (Triangle Wave Oscillator)
Instead of approximating a sine curve, the SPU-1 utilizes a **Linear Step Function with a Bit-Masked Turnaround**.

#### 2.1 Logic Flow
1.  **The Inhale (Expansion):** `Scale += StepSize`
2.  **The Apex (Upper Bound):** When `Scale == UpperBound`, the turnaround bit is toggled.
3.  **The Exhale (Contraction):** `Scale -= StepSize`
4.  **The Nadir (Lower Bound):** When `Scale == LowerBound`, the turnaround bit is toggled again.

#### 2.2 Advantages
*   **Exact Turnaround:** Since bounds are rational integers, there is no "overshoot" or settling error.
*   **Energy Conservation:** The total area under a triangle wave is a perfect integer, ensuring zero energy leakage in oscillatory systems.

### 3. Jitterbug Modulation
The Jitterbug Transformation—the collapse of a Vector Equilibrium (VE) into an Octahedron—is driven directly by the DAK oscillator.

*   **Linear Path:** The transition is implemented as a linear interpolation of Quadray coordinates.
*   **Symmetry Retention:** Because every point on the path is a rational ratio of the IVM basis, the structural symmetry is preserved bit-for-bit at every frame of the animation.

### 4. Deterministic Collision Prediction
Because the DAK is 100% predictable, spatial intersections do not require frame-by-frame "checks."
*   **Algebraic Identity:** The future position of any node can be calculated as a simple algebraic identity: $Pos_{future} = f(Tick_{future})$.
*   **Zero-Latency:** This allows the hardware to predict and handle collisions multiple frames in advance with zero approximation error.

---
*Status: KINETIC SPECIFICATION FORMALIZED. Verified by Rational Pulse.*
