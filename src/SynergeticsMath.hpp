#ifndef SYNERGETICS_MATH_HPP
#define SYNERGETICS_MATH_HPP

#include <simd/simd.h>
#include <cmath>
#include <iostream>

namespace Synergetics {

// Represents a number exactly as (a + b*sqrt(3)) / divisor
struct RationalSurd {
    long a;
    long b;
    long divisor;

    static RationalSurd zero() { return {0, 0, 1}; }
    static RationalSurd one() { return {1, 0, 1}; }
    static RationalSurd fromInt(long val) { return {val, 0, 1}; }

    RationalSurd multiply(const RationalSurd& other) const {
        return {
            (a * other.a + 3 * b * other.b),
            (a * other.b + b * other.a),
            divisor * other.divisor
        };
    }

    RationalSurd add(const RationalSurd& other) const {
        return {
            a * other.divisor + other.a * divisor,
            b * other.divisor + other.b * divisor,
            divisor * other.divisor
        };
    }

    RationalSurd subtract(const RationalSurd& other) const {
        return {
            a * other.divisor - other.a * divisor,
            b * other.divisor - other.b * divisor,
            divisor * other.divisor
        };
    }

    float toFloat() const {
        return (float(a) + float(b) * 1.73205081f) / float(divisor);
    }

    bool equals(const RationalSurd& other) const {
        return (a * other.divisor == other.a * divisor) && 
               (b * other.divisor == other.b * divisor);
    }
};

struct SQRotor;

struct SurdRotor {
    RationalSurd w, x, y, z;
    long janus;

    static SurdRotor identity() {
        return {RationalSurd::one(), RationalSurd::zero(), RationalSurd::zero(), RationalSurd::zero(), 1};
    }

    SurdRotor multiply(const SurdRotor& other) const {
        // Full Janus Product (Hamilton-isomorphic) in RationalSurd space
        return {
            // w3 = w1w2 - x1x2 - y1y2 - z1z2
            w.multiply(other.w).subtract(x.multiply(other.x)).subtract(y.multiply(other.y)).subtract(z.multiply(other.z)),
            // x3 = w1x2 + x1w2 + y1z2 - z1y2
            w.multiply(other.x).add(x.multiply(other.w)).add(y.multiply(other.z)).subtract(z.multiply(other.y)),
            // y3 = w1y2 - x1z2 + y1w2 + z1x2
            w.multiply(other.y).subtract(x.multiply(other.z)).add(y.multiply(other.w)).add(z.multiply(other.x)),
            // z3 = w1z2 + x1y2 - y1x2 + z1w2
            w.multiply(other.z).add(x.multiply(other.y)).subtract(y.multiply(other.x)).add(z.multiply(other.w)),
            janus * other.janus
        };
    }

    SQRotor toSQRotor() const;
};

struct Quadray {
    float a, b, c, d;
    static constexpr simd::float3 Q1 = { 1.0f,  1.0f,  1.0f};
    static constexpr simd::float3 Q2 = { 1.0f, -1.0f, -1.0f};
    static constexpr simd::float3 Q3 = {-1.0f,  1.0f, -1.0f};
    static constexpr simd::float3 Q4 = {-1.0f, -1.0f,  1.0f};

    simd::float3 toCartesian() const {
        return (Q1 * a) + (Q2 * b) + (Q3 * c) + (Q4 * d);
    }

    static Quadray fromCartesian(simd::float3 v) {
        return {
            simd::dot(v, Q1) / 3.0f,
            simd::dot(v, Q2) / 3.0f,
            simd::dot(v, Q3) / 3.0f,
            simd::dot(v, Q4) / 3.0f
        };
    }
};

enum class Axis { W, X, Y, Z };

struct SQRotor {
    simd::float4 coords; // (w, x, y, z)
    float janus;

    static SQRotor identity() {
        return {{1.0f, 0.0f, 0.0f, 0.0f}, 1.0f};
    }

    static SQRotor fromAxisAngle(Axis axis, float theta) {
        float ct2 = cos(theta * 0.5f);
        float st2 = sin(theta * 0.5f);
        simd::float4 c = {ct2, 0, 0, 0};
        switch(axis) {
            case Axis::W: c.y = st2; break; // Axis index is shifted relative to v[4]
            case Axis::X: c.z = st2; break;
            case Axis::Y: c.w = st2; break;
            case Axis::Z: c.x = ct2; c.y = st2; break; // Placeholder for compound logic
        }
        // Simplified for single-axis case:
        float w = cos(theta * 0.5f);
        float s = sin(theta * 0.5f);
        if (axis == Axis::W) return {{w, s, 0, 0}, 1.0f};
        if (axis == Axis::X) return {{w, 0, s, 0}, 1.0f};
        if (axis == Axis::Y) return {{w, 0, 0, s}, 1.0f};
        // For Z, the paper notes it interacts differently, but for simplicity:
        return {{w, 0, 0, 0}, 1.0f};
    }

    SQRotor multiply(const SQRotor& other) const {
        return {
            {
                coords.x * other.coords.x - coords.y * other.coords.y - coords.z * other.coords.z - coords.w * other.coords.w,
                coords.x * other.coords.y + coords.y * other.coords.x + coords.z * other.coords.w - coords.w * other.coords.z,
                coords.x * other.coords.z - coords.y * other.coords.w + coords.z * other.coords.x + coords.w * other.coords.y,
                coords.x * other.coords.w + coords.y * other.coords.z - coords.z * other.coords.y + coords.w * other.coords.x
            },
            janus * other.janus
        };
    }

    Quadray rotate(const Quadray& q) const {
        // Full SQR rotation requires a 4D matrix lift
        // For now, we only rotate about W-axis to simplify the demo
        simd::float4x4 m = axisRotationMatrix(Axis::W, coords.x, janus);
        simd::float4 v = {q.a, q.b, q.c, q.d};
        simd::float4 rv = m * v;
        return {rv.x, rv.y, rv.z, rv.w};
    }

    static simd::float4x4 axisRotationMatrix(Axis axis, float theta, float janusSign = 1.0f) {
        float ct = cos(theta);
        float st = sin(theta) * janusSign;
        float F = (2.0f * ct + 1.0f) / 3.0f;
        float G = (2.0f * (ct * -0.5f + st * 0.8660254f) + 1.0f) / 3.0f;
        float H = (2.0f * (ct * -0.5f - st * 0.8660254f) + 1.0f) / 3.0f;

        // Right-circulant (W, Y): [F, H, G; G, F, H; H, G, F]
        // Left-circulant (X, Z):  [F, G, H; H, F, G; G, H, F]
        
        if (axis == Axis::W) {
            return simd_matrix(
                (simd::float4){1.0f, 0.0f, 0.0f, 0.0f},
                (simd::float4){0.0f,    F,    H,    G},
                (simd::float4){0.0f,    G,    F,    H},
                (simd::float4){0.0f,    H,    G,    F}
            );
        } else if (axis == Axis::X) {
            // Swap G and H for left-circulant chirality
            return simd_matrix(
                (simd::float4){F, 0.0f, G, H},
                (simd::float4){0.0f, 1.0f, 0.0f, 0.0f},
                (simd::float4){H, 0.0f, F, G},
                (simd::float4){G, 0.0f, H, F}
            );
        }
        return matrix_identity_float4x4;
    }
};

inline SQRotor SurdRotor::toSQRotor() const {
    return {{w.toFloat(), x.toFloat(), y.toFloat(), z.toFloat()}, (float)janus};
}

} // namespace Synergetics

#endif
