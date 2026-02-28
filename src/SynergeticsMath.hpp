#ifndef SYNERGETICS_MATH_HPP
#define SYNERGETICS_MATH_HPP

#include <simd/simd.h>
#include <cmath>
#include <iostream>
#include <stdint.h>

namespace Synergetics {

// --- DISPLAY ADAPTER (Cartesian Corner - Estimations Allowed) ---
namespace DisplayAdapter {
    static constexpr float SQRT3_ESTIMATE = 1.73205081f;
}

// --- SOVEREIGN CORE (Algebraic Identity - Integer Only) ---

// Represents (a + b*sqrt(3)) / 2^16
struct SurdFixed64 {
    int32_t a, b; // coefficients

    static constexpr int32_t Shift = 16;
    static constexpr int32_t One = 1 << Shift;

    static inline SurdFixed64 _spu_surd_mul(SurdFixed64 u, SurdFixed64 v) {
        int64_t prod_bb = (int64_t)u.b * v.b;
        int64_t surd_term = (prod_bb << 1) + prod_bb; // *3
        int64_t res_a = ((int64_t)u.a * v.a + surd_term) >> Shift;
        int64_t res_b = ((int64_t)u.a * v.b + (int64_t)u.b * v.a) >> Shift;
        return { static_cast<int32_t>(res_a), static_cast<int32_t>(res_b) };
    }

    static inline SurdFixed64 _spu_normalize(SurdFixed64 s) {
        uint32_t mask = 0x40000000;
        if ((static_cast<uint32_t>(s.a) & mask) || (static_cast<uint32_t>(s.b) & mask)) {
            return { s.a >> 1, s.b >> 1 };
        }
        return s;
    }

    SurdFixed64 add(const SurdFixed64& other) const { return { a + other.a, b + other.b }; }
    SurdFixed64 subtract(const SurdFixed64& other) const { return { a - other.a, b - other.b }; }
    SurdFixed64 multiply(const SurdFixed64& other) const { return _spu_surd_mul(*this, other); }

    // Display-only conversion
    float toFloat() const {
        return (float(a) + float(b) * DisplayAdapter::SQRT3_ESTIMATE) / float(One);
    }
};

struct SPU_Vector256 {
    int32_t v[8];
    static inline SPU_Vector256 add(const SPU_Vector256& u, const SPU_Vector256& v) {
        SPU_Vector256 res;
#if defined(__APPLE__) && defined(__arm64__)
        auto uv = (int32x4x2_t*)u.v; auto vv = (int32x4x2_t*)v.v; auto rv = (int32x4x2_t*)res.v;
        rv->val[0] = vaddq_s32(uv->val[0], vv->val[0]); rv->val[1] = vaddq_s32(uv->val[1], vv->val[1]);
#else
        for (int i = 0; i < 8; ++i) res.v[i] = u.v[i] + v.v[i];
#endif
        return res;
    }
    static inline SPU_Vector256 rotate60(const SPU_Vector256& q) {
        return { q.v[2], q.v[3], q.v[4], q.v[5], q.v[0], q.v[1], q.v[6], q.v[7] };
    }
};

struct alignas(32) Quadray4 {
    SPU_Vector256 data;
    static Quadray4 identity() { return { {SurdFixed64::One, 0, 0, 0, 0, 0, 0, 0} }; }
    bool equals(const Quadray4& other) const {
        for (int i = 0; i < 8; ++i) if (data.v[i] != other.data.v[i]) return false;
        return true;
    }
};

// --- END SOVEREIGN CORE ---

// --- LEGACY SUPPORT (RationalSurd and old Rotor logic) ---

struct RationalSurd {
    int64_t a, b, divisor;
    static RationalSurd zero() { return {0, 0, 1}; }
    static RationalSurd one() { return {1, 0, 1}; }
    static RationalSurd fromInt(int64_t val) { return {val, 0, 1}; }
    RationalSurd multiply(const RationalSurd& other) const {
        __int128_t res_a = (__int128_t)a * other.a + (__int128_t)3 * b * other.b;
        __int128_t res_b = (__int128_t)a * other.b + (__int128_t)b * other.a;
        __int128_t res_d = (__int128_t)divisor * other.divisor;
        return { (int64_t)res_a, (int64_t)res_b, (int64_t)res_d };
    }
    bool equals(const RationalSurd& other) const {
        return ((__int128_t)a * other.divisor == (__int128_t)other.a * divisor) && 
               ((__int128_t)b * other.divisor == (__int128_t)other.b * divisor);
    }
    float toFloat() const {
        if (divisor == 0) return 0.0f;
        return (float(a) + float(b) * DisplayAdapter::SQRT3_ESTIMATE) / float(divisor);
    }
    RationalSurd project(const RationalSurd& focal, const RationalSurd& z, const RationalSurd& offset) const {
        return { (a * focal.a) / z.a, 0, 1 }; 
    }
    // Added back basic project for benchmark compatibility
    static RationalSurd project_simple(int64_t x, int64_t f, int64_t z) {
        return { x * f, 0, z };
    }
};

struct SurdRotor {
    int64_t janus;
    static SurdRotor identity() { return { 1 }; }
};

struct HyperSurd {
    RationalSurd val, eps;
    static HyperSurd variable(RationalSurd s) { return { s, RationalSurd::one() }; }
    HyperSurd multiply(const HyperSurd& other) const {
        return { val.multiply(other.val), { val.a * other.eps.a + val.b * other.eps.b * 3, 0, 1 } }; // Simplified
    }
};

} // namespace Synergetics

#endif
