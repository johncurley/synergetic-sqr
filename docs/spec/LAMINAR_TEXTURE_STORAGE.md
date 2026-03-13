# Laminar Texture Storage: Fractal RAM Alignment (v1.0)
## Objective: Spatial Locality via Bit-Interleaved Quadray Addressing.

Standard texture storage is optimized for 90-degree scans. The SPU-13 uses **Fractal RAM Alignment** to ensure that geometric neighbors in the 60-degree manifold are physical neighbors in silicon memory.

### 1. Bit-Interleaved Addressing (IVM-Map)
To map 3D Quadray vectors $\{a,b,c\}$ to a 1D RAM address, we interleave their bits:
- **Address Format:** `[a7][b7][c7][a6][b6][c6]...[a0][b0][c0]`
- **Properties:** This creates a **Recursive Hex-Order** traversal. Any $2^n \times 2^n$ block in RAM corresponds to a perfectly equilateral "Diamond" or "Hex" in the manifold.

### 2. The Resonant Neighborhood
A single memory fetch in the SPU-13 is designed to return a **7-Pixel Sip**:
- **Address 0:** Center Pixel.
- **Addresses 1-6:** The six immediate 60-degree neighbors.
- **Benefit:** Zero-latency Bi-Linear (Resonant) interpolation. The hardware doesn't need to "calculate" neighbor addresses; they are offsets in the fractal stream.

### 3. Hex-Tile Format
Textures are stored as **Sovereign Hex-Tiles** (SHT).
- **Header:** 4-byte LHS (Laminar Header Signature).
- **Data:** R,G,B,A (8-bit or 16-bit fixed-point) mapped to the fractal address space.

---
*Status: REIFIED. The memory is coherent.*
