#ifndef SYNERGETICS_MATH_HPP
#define SYNERGETICS_MATH_HPP

#include <stdint.h>
#include <cstring>
#include <cmath>
#include <algorithm>

namespace Synergetics {

/**
 * HyperSurd: The Full Impressionist Basis (Q(sqrt2, sqrt3, sqrt5)).
 * Represents a + b*sqrt2 + c*sqrt3 + d*sqrt5.
 */
struct HyperSurd {
    int32_t a, b, c, d;
    static constexpr int32_t Shift = 16;
    static constexpr int32_t One = 1 << Shift;

    static inline HyperSurd identity() { return { One, 0, 0, 0 }; }

    HyperSurd add(const HyperSurd& other) const {
        return { a + other.a, b + other.b, c + other.c, d + other.d };
    }

    // High-fidelity multiplication logic for the multi-surd extension
    static inline HyperSurd multiply(const HyperSurd& u, const HyperSurd& v) {
        int64_t res_a = ((int64_t)u.a * v.a + 2*(int64_t)u.b * v.b + 3*(int64_t)u.c * v.c + 5*(int64_t)u.d * v.d) >> Shift;
        int64_t res_b = ((int64_t)u.a * v.b + (int64_t)u.b * v.a) >> Shift;
        int64_t res_c = ((int64_t)u.a * v.c + (int64_t)u.c * v.a) >> Shift;
        int64_t res_d = ((int64_t)u.a * v.d + (int64_t)u.d * v.a) >> Shift;
        return { (int32_t)res_a, (int32_t)res_b, (int32_t)res_c, (int32_t)res_d };
    }
};

struct SPU_Vector256 {
    int32_t v[8];
};

struct Quadray4 {
    SPU_Vector256 data;
    static Quadray4 identity() {
        Quadray4 q; std::memset(q.data.v, 0, 32);
        q.data.v[0] = 65536; return q;
    }
    bool equals(const Quadray4& other) const {
        for (int i = 0; i < 8; ++i) if (data.v[i] != other.data.v[i]) return false;
        return true;
    }
    static inline Quadray4 _spu_rotate_60(Quadray4 q) {
        return { {q.data.v[2], q.data.v[3], q.data.v[4], q.data.v[5], q.data.v[0], q.data.v[1], q.data.v[6], q.data.v[7]} };
    }
    static inline Quadray4 _spu_sperm_x4(Quadray4 q, int phase) {
        switch (phase) {
            case 1: return { {q.data.v[2], q.data.v[3], q.data.v[4], q.data.v[5], q.data.v[0], q.data.v[1], q.data.v[6], q.data.v[7]} };
            case 2: return { {q.data.v[4], q.data.v[5], q.data.v[0], q.data.v[1], q.data.v[2], q.data.v[3], q.data.v[6], q.data.v[7]} };
            case 3: return { {q.data.v[6], q.data.v[7], q.data.v[2], q.data.v[3], q.data.v[4], q.data.v[5], q.data.v[0], q.data.v[1]} };
            default: return q;
        }
    }
};

} // namespace Synergetics

#endif
