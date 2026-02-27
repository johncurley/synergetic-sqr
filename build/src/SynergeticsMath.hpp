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

    RationalSurd simplify() const {
        if (divisor < 1000000000L) return *this; 
        double scale = 1000000.0 / (double)divisor;
        return { (int64_t)(a * scale), (int64_t)(b * scale), 1000000L };
    }

    static RationalSurd oscillator(int64_t time_ms, int64_t period_ms) {
        int64_t half_period = period_ms / 2;
        int64_t t = time_ms % period_ms;
        int64_t val = (t < half_period) ? t : (period_ms - t);
        return { (val * 4) - period_ms, 0, period_ms };
    }

    bool equals(const RationalSurd& other) const {
        return ((__int128_t)a * other.divisor == (__int128_t)other.a * divisor) && 
               ((__int128_t)b * other.divisor == (__int128_t)other.b * divisor);
    }
};

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
