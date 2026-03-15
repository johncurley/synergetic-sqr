# The Knot-Breaker: Resolving Cartesian Interference through Temporal Resonance

**Version:** 1.0  
**Date:** 2026-03-14  
**Status:** Canonical  
**Context:** SPU-13 Modular HAL & Laminar Renderer  

---

## 1. The Knot Paradox (The Friction of Truth)

When a mathematically perfect **60-degree vector** from the Isotropic Vector Matrix (IVM) is projected onto a standard **90-degree Cartesian pixel grid**, a visual artifact emerges: the **Knot**.

Because the vertical and diagonal paths of the 60° manifold do not align with the integer columns and rows of square pixels, the rasterizer must "snap" to the nearest whole pixel. Without the artificial blur of standard anti-aliasing (MSAA/TXAA), this periodic snapping creates a rhythmic thickening and thinning of the line—a visual "braid" or "knot."

*   **Observation:** In static images, the Knot is static, creating a "visual itch" as the eye's hexagonal receptors fight the square grid's approximation.
*   **Observation:** In high-speed motion, the Knot disappears. The brain integrates the shifting pixels into a singular, smooth vector.

## 2. The Solution: Temporal Resonance (Knot-Breaker)

The **Knot-Breaker** is a fundamental component of the SPU-13's Modular HAL. Instead of hiding the error with blur (which degrades contrast and causes eye strain), we resolve the interference through **High-Frequency Temporal Oscillation**.

### 2.1 The Mechanism
The SPU-13 vibrates the entire projection by a sub-pixel fraction (typically ±0.5 to ±1.0 pixels) at the **61.44 kHz** system heartbeat. 

*   **Cycle 1:** The line is projected at `(x + 0.5, y)`.
*   **Cycle 2:** The line is projected at `(x - 0.5, y)`.

### 2.2 Biological Integration
Because this vibration happens significantly faster than the human eye's flicker fusion threshold, the brain performs **Temporal Integration**. The two vibrating "knots" overlap and cancel each other out in the visual cortex, leaving behind a perfectly straight, razor-sharp line that appears to "float" between the physical pixels of the Cartesian screen.

---

## 3. Implementation

### 3.1 Hardware (Verilog)
In the FPGA bitstream (`spu_hal_controller.v`), the logic is implemented as a simple state-flip:

```verilog
always @(posedge clk_61k) begin
    resonance_state <= ~resonance_state;
    if (is_cartesian_display) begin
        out_x <= q_x + (resonance_state ? 1 : -1); 
        out_y <= q_y; 
    end
end
```

### 3.2 Emulator (Metal/GLSL)
In the software bridge, we use the `control.tick` to drive the offset in the shader kernel:

```metal
float jitter = (control.tick % 2 == 0) ? 0.5f : -0.5f;
float2 resonance_offset = float2(jitter, 0.0);
float2 pixel_pos = float2(gid) + resonance_offset;
```

---

## 4. Usage in the Emulator

The Knot-Breaker is enabled by default in the SPU-13 Emulator to "heal" your monitor. You can toggle this behavior in real-time to observe the effect:

*   **Key [T]:** Toggle "Laminar Tension" (Knot-Breaker).
    *   `CUBIC (Healed)`: Knot-Breaker is ACTIVE. Lines are smooth and solid.
    *   `SOVEREIGN (Native)`: Knot-Breaker is OFF. The raw 60° math is exposed, revealing the "knots."

## 5. Summary

The Knot-Breaker proves that **Resonance** is superior to **Approximation**. We do not lie to the eye by blurring the world; we use the world's own temporal persistence to reveal the Sovereign truth of the manifold.

---

*"We do not hide the knot; we untie it with the heartbeat of the silicon."*
