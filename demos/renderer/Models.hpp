#ifndef MODELS_HPP
#define MODELS_HPP

#include <stdint.h>

/**
 * Sovereign Quadray Models (v2.6.3)
 * 100% Non-Negative Integer Coefficients.
 */

// Vector Equilibrium (12 vertices) in Quadray Basis
// Every vertex is a permutation of (1, 1, 0, 0) or (0, 0, 1, 1)
const int64_t ve_data_int[] = {
    1, 1, 0, 0,
    1, 0, 1, 0,
    1, 0, 0, 1,
    0, 1, 1, 0,
    0, 1, 0, 1,
    0, 0, 1, 1,
    // Complementary pairs (True Isotropic Inversion)
    0, 0, 1, 1,
    0, 1, 0, 1,
    0, 1, 1, 0,
    1, 0, 0, 1,
    1, 0, 1, 0,
    1, 1, 0, 0
};

// Octahedron (6 vertices) in Quadray Basis
// Represented as pure Prime-Axis radials
const int64_t oct_data_int[] = {
    2, 0, 0, 0,
    0, 2, 0, 0,
    0, 0, 2, 0,
    0, 0, 0, 2,
    1, 1, 1, 0, // Inverted radial (Sum projection)
    0, 1, 1, 1  // Inverted radial (Sum projection)
};

#endif
