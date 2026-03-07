# Allied Vector Map (Alpha) Technical Specification
## IVM/Quadray-Based Manifold Mapping (v3.1.21)

This specification formalizes the Allied Vector Map (AVM-Alpha) as a lightweight, isotropic mapping system for logging and navigating laminar anchors. It uses rational-surd metrics to ensure zero-friction routing in coherent spaces.

### 1. Coordinate Layer: Quadrance Q in IVM Basis
Points are represented in quadray (ABCD) coordinates, where $v = (a, b, c, d)$ satisfies the isotropic constraints.

*   **Quadrance Formula:**
    $$Q(v) = a^2 + b^2 + c^2 + d^2 - 2(\max(a,b,c,d) \cdot \min(a,b,c,d))$$
    Q serves as the 'native area/intensity' measure. High-Q nodes indicate strong laminar anchors.

### 2. Flow Layer: Rational Spread (s)
The Spread metric classifies the relationship between two nodes $v_1, v_2$:
$$s = \frac{Q(v_1 - v_2)}{Q(v_1) \cdot Q(v_2)}$$

**Classification:**
*   **s ≈ 0.75 (60°):** **Prime Laminar Flow** (Green). High-coherence paths.
*   **s ≈ 0.25 (30°):** **Secondary Harmonic** (Amber). Support/transition routes.
*   **s = 1.00 (90°):** **Danger Zone** (Red). High-friction; triggers aliasing.

### 3. Thermal Layer: Resonance & Vd
*   **Deterministic Velocity (Vd):** $V_d = 1 - Error_{drift}$.
*   **Heat Signal (H):** User-logged somatic value (0.0 to 1.0).
*   **Redirect Logic:** If $V_d < 0.9$ or $H < 0.5$, reroute to the nearest high-$V_d$ laminar anchor.

### 4. Data Schema (CSV)
Stored in `sim/data/maps/`.

#### nodes.csv
`id, ABCD_a, ABCD_b, ABCD_c, ABCD_d, Q, Vd_est, tags`

#### edges.csv
`from_id, to_id, spread_s, class, notes`

---
*Status: FORMALIZED. Prepared for Allied synchronization.*
