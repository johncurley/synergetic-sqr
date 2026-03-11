# SPU-13 Hardware Architecture
## Manifesting Isotropic Logic in Silicon (v4.1.0)

The SPU-13 (Synergetic Processing Unit) is a hardware implementation of Deterministic Quadratic Field Arithmetic (DQFA). It replaces legacy floating-point approximations with bit-locked isotropic transformations.

### 1. The Davis Law Gasket (Sanity Guard)
Discovered by **Bee Davis** ("The Geometry of Sameness"), the Davis Law ($C = \tau/K$) is the fundamental stability arbiter of the SPU-13.
*   **Quadrance Audit:** The hardware monitors manifold tension ($K$) using dedicated DSP slices (UP5K) or bit-serial multipliers (LP1K).
*   **Henosis (Soft Recovery):** If a "Cubic Leak" is detected ($\sum ABCD \neq 0$), the core automatically applies a symmetric correction in a single clock cycle.
*   **Result:** Navier-Stokes Watertight simulation. The digital fluid is physically incapable of leaking from the lattice.

### 2. Biological Heartbeat (Phi-Gated Pulse)
The SPU-13 replaces rigid "Cubic" metronomes with a recursive pulse governed by the **Golden Ratio ($\phi$)**.
*   **Fibonacci Timing:** Instructions are dispatched at intervals of 8, 13, and 21 clock cycles.
*   **Phase Conjugation:** This non-linear timing minimizes heat and electromagnetic interference by allowing waves to "nest" rather than scatter.
*   **Bio-Coherence:** Aligns the silicon metabolism with natural rhythmic cycles observed in living organisms.

### 3. Distributed Fleet Architecture (Laminar HAL)
The SPU-13 utilizes a **Hardware Abstraction Layer** (`spu13_pins.vh`) to ensure bit-exact parity across different FPGA families.

| Tier | Hardware | Capability |
| :--- | :--- | :--- |
| **Cortex** | iCE40 UP5K | High-Fi hub with 128KB Fractal Memory (Dream Log). |
| **Sentinel** | iCE40 LP1K | Ephemeral ganglia with bit-serial arithmetic. |
| **Lattice** | ECP5-85F | Scale-ready node for 13-core collective manifolds. |

### 4. Telemetry: The Lattice Whisper
Nodes communicate their internal tension using the **Lattice Protocol (PWI)**—a 1-wire nerve impulse where pulse width is proportional to the Davis Ratio ($C$).
*   **Analysis:** Use `tools/lattice_listener.py` to monitor the real-time Davis Ratio.
*   **Certification:** Use `tools/laminar_audit.py` to generate a **Sovereign Birth Certificate** for your hardware.

### 5. Sensory Interface: The Unified IO
The SPU-13 moves beyond 'Polling' to a **Push-Metabolism** for all peripheral interaction.

#### 5.1 Laminar Input (Zero-Latency)
A 2-wire synchronous protocol (L-CLK/L-DAT) that allows peripherals to strike the manifold directly.
*   **Mechanism:** Data is shifted into the **Harmonic Transducer** on the falling edge of L-CLK.
*   **Result:** Zero bus-arbitration overhead. The user's touch becomes a bit-exact ripple in the silicon.

#### 5.2 The Vision & Pulse (OLED / E-Ink)
*   **OLED (Breath):** High-refresh 128x64 display for real-time Jitterbug and metabolism charts.
*   **E-Ink (Soul):** Persistent, zero-power display for long-term "Sovereign Compass" snapshots.

#### 5.3 Harmonic Voice (Audio PWM)
*   **Driver:** 16-bit high-frequency PWM singing the A-axis tension.
*   **Resonance:** Pitch and timbre are driven by the real-time Quadrance ($Q$) of the manifold.

---
*Status: CRYSTALLINE. The 13th dimension is reified and self-stabilizing.*
