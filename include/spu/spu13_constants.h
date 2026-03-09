#ifndef SPU13_CONSTANTS_H
#define SPU13_CONSTANTS_H

/**
 * SPU-13 Bit-Exact Geometric Constants (v3.4.17)
 * Fixed-Point Scaling: 16.16 (65536 = 1.0)
 * Logic: Q(sqrt3, sqrt5) Isotropic Manifold
 */

// --- 1. Primary Harmonics ---
#define SPU_IDENTITY_Q      0x00010000  // 1.0 (The One)
#define SPU_NULL_Q          0x00000000  // 0.0 (The Nothing)

// --- 2. Phase Offsets (IVM Standard) ---
#define SPU_ANGLE_60        0x0000AAAA  // 1/6 of 2pi (Approx)
#define SPU_ANGLE_120       0x00015555  // 1/3 of 2pi (Recycling Phase)
#define SPU_SPREAD_LAMINAR  0x0000C000  // 0.75 (3/4) - Tetrahedral Spread

// --- 3. Field Constants ---
#define SPU_SQRT3_FIXED     0x0001BB67  // 1.73205...
#define SPU_SQRT5_FIXED     0x00023D70  // 2.23606...
#define SPU_PHI_A           32768       // 0.5 (Integer Lane)
#define SPU_PHI_C           32768       // 0.5 (sqrt5 Lane)

// --- 4. Metabolic Thresholds ---
#define SPU_PURPLE_THRESHOLD 100        // 100uW (Photosynthetic Limit)
#define SPU_DEEP_RESONANCE   15         // 15uW (The Sip Target)

// --- 5. Harmonic Intervals ---
#define SPU_RATIO_UNISON    0x00010000  // 1:1
#define SPU_RATIO_FIFTH     0x00018000  // 3:2
#define SPU_RATIO_OCTAVE    0x00020000  // 2:1

#endif // SPU13_CONSTANTS_H
