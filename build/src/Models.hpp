#ifndef MODELS_HPP
#define MODELS_HPP

#include <stdint.h>

// Vector Equilibrium (12 vertices) in Quadray Basis
// Every vertex is a permutation of (1, 1, 0, 0)
const int64_t ve_data_int[] = {
    1, 1, 0, 0,
    1, 0, 1, 0,
    1, 0, 0, 1,
    0, 1, 1, 0,
    0, 1, 0, 1,
    0, 0, 1, 1,
    // Add negative counterparts for full symmetry
    -1, -1, 0, 0,
    -1, 0, -1, 0,
    -1, 0, 0, -1,
    0, -1, -1, 0,
    0, -1, 0, -1,
    0, 0, -1, -1
};

// Octahedron (6 vertices doubled) in Quadray Basis
// Every vertex is a permutation of (2, 0, 0, 0)
const int64_t oct_data_int[] = {
    2, 0, 0, 0,
    0, 2, 0, 0,
    0, 0, 2, 0,
    0, 0, 0, 2,
    -2, 0, 0, 0,
    0, -2, 0, 0,
    // Doubled for Jitterbug interpolation consistency
    0, 0, -2, 0,
    0, 0, 0, -2,
    2, 0, 0, 0,
    0, 2, 0, 0,
    0, 0, 2, 0,
    0, 0, 0, 2
};

const int jitterbug_edges[] = {
    0, 1, 0, 2, 0, 3, 0, 4,
    1, 3, 1, 5, 1, 6,
    2, 4, 2, 5, 2, 7,
    3, 7, 3, 8,
    4, 6, 4, 8,
    5, 9, 5, 10,
    6, 9, 6, 11,
    7, 10, 7, 11,
    8, 10, 8, 11,
    9, 10, 9, 11
};

#endif
