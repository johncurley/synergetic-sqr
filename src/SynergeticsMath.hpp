#ifndef SYNERGETICS_MATH_HPP
#define SYNERGETICS_MATH_HPP

#include <simd/simd.h>
#include <cmath>
#include <iostream>
#include <stdint.h>

namespace Synergetics {

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

    RationalSurd add(const RationalSurd& other) const {
        __int128_t res_a = (__int128_t)a * other.divisor + (__int128_t)other.a * divisor;
        __int128_t res_b = (__int128_t)b * other.divisor + (__int128_t)other.b * divisor;
        __int128_t res_d = (__int128_t)divisor * other.divisor;
        return { (int64_t)res_a, (int64_t)res_b, (int64_t)res_d };
    }

    RationalSurd subtract(const RationalSurd& other) const {
        __int128_t res_a = (__int128_t)a * other.divisor - (__int128_t)other.a * divisor;
        __int128_t res_b = (__int128_t)b * other.divisor - (__int128_t)other.b * divisor;
        __int128_t res_d = (__int128_t)divisor * other.divisor;
        return { (int64_t)res_a, (int64_t)res_b, (int64_t)res_d };
    }

    float toFloat() const {
        if (divisor == 0) return 0.0f;
        return (float(a) + float(b) * 1.73205081f) / float(divisor);
    }

    RationalSurd project(const RationalSurd& focal, const RationalSurd& z, const RationalSurd& offset) const {
        return this->multiply(focal).divide(z.add(offset));
    }

    RationalSurd invert() const {
        int64_t norm = a * a - 3 * b * b;
        return { a * divisor, -b * divisor, norm };
    }

    RationalSurd divide(const RationalSurd& other) const {
        return this->multiply(other.invert());
    }

    bool equals(const RationalSurd& other) const {
        return ((__int128_t)a * other.divisor == (__int128_t)other.a * divisor) && 
               ((__int128_t)b * other.divisor == (__int128_t)other.b * divisor);
    }
};

// SURD-FIXED-POINT (DQFA SPEC v1.4 - Silicon Ready)
// Representing (a + b*sqrt(3)) / 2^16
struct SurdFixed64 {
    int32_t a, b; // 32-bit integer coefficients

    static constexpr int32_t Shift = 16;
    static constexpr int32_t One = 1 << Shift;

    static SurdFixed64 fromInt(int32_t val) { return { val << Shift, 0 }; }
    static SurdFixed64 zero() { return { 0, 0 }; }
    static SurdFixed64 one() { return { One, 0 }; }
    static SurdFixed64 sqrt3() { return { 0, One }; }

    SurdFixed64 add(const SurdFixed64& other) const {
        return { a + other.a, b + other.b };
    }

    SurdFixed64 subtract(const SurdFixed64& other) const {
        return { a - other.a, b - other.b };
    }

    SurdFixed64 multiply(const SurdFixed64& other) const {
        int64_t res_a = ((int64_t)a * other.a + (int64_t)3 * b * other.b) >> Shift;
        int64_t res_b = ((int64_t)a * other.b + (int64_t)b * other.a) >> Shift;
        return { (int32_t)res_a, (int32_t)res_b };
    }

    float toFloat() const {
        return (float(a) + float(b) * 1.73205081f) / float(One);
    }
};

struct SurdVector3 {
    SurdFixed64 x, y, z;
    static SurdVector3 fromInt(int64_t ix, int64_t iy, int64_t iz) {
        return { SurdFixed64::fromInt((int32_t)ix), SurdFixed64::fromInt((int32_t)iy), SurdFixed64::fromInt((int32_t)iz) };
    }
};

struct SurdMatrix3x3 {
    SurdFixed64 m[9]; // Row-major

    static SurdMatrix3x3 identity() {
        return {
            {
                SurdFixed64::one(), SurdFixed64::zero(), SurdFixed64::zero(),
                SurdFixed64::zero(), SurdFixed64::one(), SurdFixed64::zero(),
                SurdFixed64::zero(), SurdFixed64::zero(), SurdFixed64::one()
            }
        };
    }

    SurdVector3 transform(const SurdVector3& v) const {
        return {
            m[0].multiply(v.x).add(m[1].multiply(v.y)).add(m[2].multiply(v.z)),
            m[3].multiply(v.x).add(m[4].multiply(v.y)).add(m[5].multiply(v.z)),
            m[6].multiply(v.x).add(m[7].multiply(v.y)).add(m[8].multiply(v.z))
        };
    }
};

// SurdLang: DualSurd for Hyper-Surd Derivatives (eps^2 = 0)
struct DualSurd {
    SurdFixed64 val, eps;

    DualSurd add(const DualSurd& other) const {
        return { val.add(other.val), eps.add(other.eps) };
    }

    // gstep: Leibniz product (u*v, u*v' + u'*v)
    DualSurd multiply(const DualSurd& other) const {
        return { 
            val.multiply(other.val), 
            val.multiply(other.eps).add(eps.multiply(other.val)) 
        };
    }
};

// Rational Oscillator (Absolute Zero Drift Triangle Wave)
// Maps time (0 to Period) to a SurdFixed64 range [-1, 1]
inline SurdFixed64 rationalOscillator(int64_t time_ms, int64_t period_ms) {
    int64_t half_period = period_ms / 2;
    int64_t t = time_ms % period_ms;
    int64_t raw_val = (t < half_period) ? t : (period_ms - t);
    // Normalize to [-1, 1] range in SF32.16
    int64_t normalized = (raw_val * 4 * SurdFixed64::One / period_ms) - SurdFixed64::One;
    return { static_cast<int32_t>(normalized), 0 };
}

struct Surd32 {
    int32_t divisor, a, b, pad;
    static Surd32 fromSurd(RationalSurd s) { return { (int32_t)s.divisor, (int32_t)s.a, (int32_t)s.b, 0 }; }
};

enum class Axis { W, X, Y, Z };

struct SQRotor {
    simd::float4 coords;
    float janus;
    static SQRotor identity() { return {{1.0f, 0.0f, 0.0f, 0.0f}, 1.0f}; }
    static simd::float4x4 axisRotationMatrix(Axis axis, float theta, float janusSign = 1.0f) {
        float ct = cos(theta);
        float st = sin(theta) * janusSign;
        float F = (2.0f * ct + 1.0f) / 3.0f;
        float G = (2.0f * (ct * -0.5f + st * 0.8660254f) + 1.0f) / 3.0f;
        float H = (2.0f * (ct * -0.5f - st * 0.8660254f) + 1.0f) / 3.0f;
        if (axis == Axis::W) {
            return simd_matrix((simd::float4){1.0f, 0.0f, 0.0f, 0.0f}, (simd::float4){0.0f, F, H, G}, (simd::float4){0.0f, G, F, H}, (simd::float4){0.0f, H, G, F});
        }
        return matrix_identity_float4x4;
    }
};

struct SurdRotor {
    RationalSurd w, x, y, z;
    int64_t janus;
    static SurdRotor identity() { return {RationalSurd::one(), RationalSurd::zero(), RationalSurd::zero(), RationalSurd::zero(), 1}; }
    SurdRotor multiply(const SurdRotor& other) const {
        return {
            w.multiply(other.w).subtract(x.multiply(other.x)).subtract(y.multiply(other.y)).subtract(z.multiply(other.z)),
            w.multiply(other.x).add(x.multiply(other.w)).add(y.multiply(other.z)).subtract(z.multiply(other.y)),
            w.multiply(other.y).subtract(x.multiply(other.z)).add(y.multiply(other.w)).add(z.multiply(other.x)),
            w.multiply(other.z).add(x.multiply(other.y)).subtract(y.multiply(other.x)).add(z.multiply(other.w)),
            janus * other.janus
        };
    }
    SQRotor toSQRotor() const { return {{w.toFloat(), x.toFloat(), y.toFloat(), z.toFloat()}, (float)janus}; }
};

struct SurdRotor32 {
    Surd32 w, x, y, z;
    int32_t janus, p1, p2, p3;
    static SurdRotor32 fromRotor(SurdRotor r) {
        return { Surd32::fromSurd(r.w), Surd32::fromSurd(r.x), Surd32::fromSurd(r.y), Surd32::fromSurd(r.z), (int32_t)r.janus, 0, 0, 0 };
    }
};

struct HyperSurd {
    RationalSurd val, eps;
    static HyperSurd constant(RationalSurd s) { return { s, RationalSurd::zero() }; }
    static HyperSurd variable(RationalSurd s) { return { s, RationalSurd::one() }; }
    HyperSurd add(const HyperSurd& other) const { return { val.add(other.val), eps.add(other.eps) }; }
    HyperSurd multiply(const HyperSurd& other) const {
        return { val.multiply(other.val), val.multiply(other.eps).add(eps.multiply(other.val)) };
    }
    static HyperSurd HookesLaw(HyperSurd displacement, RationalSurd k) {
        return displacement.multiply(HyperSurd::constant(k));
    }
};

} // namespace Synergetics

#endif
