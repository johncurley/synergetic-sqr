#ifndef SPU13_CONSTANTS_H
#define SPU13_CONSTANTS_H

/**
 * SPU-13 Bit-Exact Geometric Constants (v3.4.29)
 * "The Nothing is the Hub"
 * Fixed-Point Scaling: 16.16 (65536 = 1.0)
 */

// --- 1. Angular Constants (The Laminar Offset) ---
#define SPU_IVM_ANGLE_DEG       60
#define SPU_TETRA_PHASE_SHIFT   120
#define SPU_CUBIC_REJECTION     90

// --- 2. Quadray Address Space (ABCD) ---
#define SPU_VERTEX_A_APEX       0x01 // The Synergy
#define SPU_VERTEX_B_LEFT       0x02 // The Input
#define SPU_VERTEX_C_RIGHT      0x04 // The Memory
#define SPU_VERTEX_D_ORIGIN     0x08 // The Nothing (Octahedral Center)

// --- 3. Photosynthetic Thresholds ---
#define SPU_SIP_THRESHOLD_UW    10   // 10 microwatts = "Blooming"
#define SPU_GULP_THRESHOLD_UW   100  // 100 microwatts = "Vegetable"
#define SPU_DEEP_RESONANCE      15   // 15uW (The Sip Target)

// --- 4. Fractal Depth (n) ---
#define SPU_MAX_RECURSION_N     16   // The Star-Child Limit
#define SPU_STABLE_MANIFOLD_N   12   // The Biking Flow Lock

// --- 5. Primary Math Harmonics ---
#define SPU_IDENTITY_Q          0x00010000  // 1.0 (The One)
#define SPU_NULL_Q              0x00000000  // 0.0 (The Nothing)
#define SPU_SPREAD_LAMINAR      0x0000C000  // 0.75 (3/4) - Tetrahedral Spread

// --- 6. Field Constants ---
#define SPU_SQRT3_FIXED         0x0001BB67  // 1.73205...
#define SPU_SQRT5_FIXED         0x00023D70  // 2.23606...
#define SPU_PHI_A               32768       // 0.5 (Integer Lane)
#define SPU_PHI_C               32768       // 0.5 (sqrt5 Lane)

// --- 7. Harmonic Intervals ---
#define SPU_RATIO_UNISON        0x00010000  // 1:1
#define SPU_RATIO_FIFTH         0x00018000  // 3:2
#define SPU_RATIO_OCTAVE        0x00020000  // 2:1

#endif // SPU13_CONSTANTS_H
