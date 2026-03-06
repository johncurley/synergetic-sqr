# Tang Nano 20k Target Support
## Gowin EDA Synthesis

### Build Instructions
1. Create a new project in **Gowin EDA**.
2. Add all files from `rtl/` and `boards/tang_nano_20k/top.v`.
3. Set the constraint file to `tang_nano_20k.cst`.
4. Run **Synthesis** and **Place & Route**.
5. Flash the generated `.fs` file.

### Verification
*   The onboard RGB LED will signal **Resonance Lock** (Green) upon successful identity restoration.
