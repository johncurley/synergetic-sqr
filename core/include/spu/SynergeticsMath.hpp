#ifndef SYNERGETICS_MATH_HPP
#define SYNERGETICS_MATH_HPP

#ifdef __APPLE__
#include <simd/simd.h>
#endif

#if defined(__arm64__) || defined(_M_ARM64)
#include <arm_neon.h>
#endif

#include <cmath>
#include <iostream>
#include <stdint.h>
#include <cstring>
#include <type_traits>

namespace Synergetics {

// --- TYPE-LEVEL PURITY GUARD ---
template <typename T>
struct PurityCheck {
    static_assert(!std::is_floating_point<T>::value, 
        "PURITY VIOLATION: Floating-point types are prohibited in the SPU-1 Core.");
    typedef T type;
};

// --- ARCHITECTURAL CONTRACT ---
static_assert(sizeof(int32_t) == 4, "SPU-1 requires 32-bit int32_t");
static_assert(sizeof(int64_t) == 8, "SPU-1 requires 64-bit int64_t");

// --- SOVEREIGN CORE (Algebraic Identity - Integer Only) ---

static inline int32_t spu_deterministic_cast(int64_t val) {
    return static_cast<int32_t>(static_cast<uint32_t>(static_cast<uint64_t>(val) & 0xFFFFFFFF));
}

struct SurdFixed64 {
    int32_t a, b; 
    static constexpr int32_t Shift = 16;
    static constexpr int32_t One = 1 << Shift;

    static inline SurdFixed64 _spu_surd_mul(SurdFixed64 u, SurdFixed64 v) {
        int64_t prod_bb = (int64_t)u.b * v.b;
        int64_t surd_term = (prod_bb << 1) + prod_bb; 
        int64_t res_a = ((int64_t)u.a * v.a + surd_term) >> Shift;
        int64_t res_b = ((int64_t)u.a * v.b + (int64_t)u.b * v.a) >> Shift;
        return { spu_deterministic_cast(res_a), spu_deterministic_cast(res_b) };
    }

    static inline SurdFixed64 _spu_safe_normalize(SurdFixed64 s) {
        uint32_t mask = 0x40000000;
        if (std::abs(s.a) < 256 && std::abs(s.b) < 256) return s;
        if ((static_cast<uint32_t>(s.a) & mask) || (static_cast<uint32_t>(s.b) & mask)) {
            return { s.a >> 1, s.b >> 1 };
        }
        return s;
    }

    int64_t norm() const {
        int64_t la = a; int64_t lb = b;
        return la * la - 3 * lb * lb;
    }

    SurdFixed64 add(const SurdFixed64& other) const { return { a + other.a, b + other.b }; }
    SurdFixed64 subtract(const SurdFixed64& other) const { return { a - other.a, b - other.b }; }
    SurdFixed64 multiply(const SurdFixed64& other) const { return _spu_surd_mul(*this, other); }
    SurdFixed64 janusFlip() const { return { a, -b }; }
};

struct SurdVector3 {
    SurdFixed64 x, y, z;
    static inline void _spu_safe_normalize_vector(SurdVector3& v) {
        v.x = SurdFixed64::_spu_safe_normalize(v.x);
        v.y = SurdFixed64::_spu_safe_normalize(v.y);
        v.z = SurdFixed64::_spu_safe_normalize(v.z);
    }
};

struct SurdMatrix3x3 {
    SurdVector3 row[3];
    static inline void _spu_safe_normalize_matrix(SurdMatrix3x3& m) {
        SurdVector3::_spu_safe_normalize_vector(m.row[0]);
        SurdVector3::_spu_safe_normalize_vector(m.row[1]);
        SurdVector3::_spu_safe_normalize_vector(m.row[2]);
    }
};

struct SPU_Vector256 {
    int32_t v[8];
    static inline SPU_Vector256 add(const SPU_Vector256& u, const SPU_Vector256& v) {
        SPU_Vector256 res;
#if defined(__APPLE__) && defined(__arm64__)
        union { int32_t arr[4]; int32x4_t vec; } lu1, lu2, lv1, lv2, lr1, lr2;
        std::memcpy(lu1.arr, &u.v[0], 16); std::memcpy(lu2.arr, &u.v[4], 16);
        std::memcpy(lv1.arr, &v.v[0], 16); std::memcpy(lv2.arr, &v.v[4], 16);
        lr1.vec = vaddq_s32(lu1.vec, lv1.vec); lr2.vec = vaddq_s32(lu2.vec, lv2.vec);
        std::memcpy(&res.v[0], lr1.arr, 16); std::memcpy(&res.v[4], lr2.arr, 16);
#else
        for (int i = 0; i < 8; ++i) res.v[i] = u.v[i] + v.v[i];
#endif
        return res;
    }
    static inline SPU_Vector256 rotate60(const SPU_Vector256& q) {
        return { q.v[2], q.v[3], q.v[4], q.v[5], q.v[0], q.v[1], q.v[6], q.v[7] };
    }
    static inline SPU_Vector256 permute_q1(const SPU_Vector256& q) {
        return { q.v[0], q.v[1], q.v[4], q.v[5], q.v[6], q.v[7], q.v[2], q.v[3] };
    }
};

struct alignas(32) Quadray4 {
    SPU_Vector256 data;
    static Quadray4 identity() { return { {SurdFixed64::One, 0, 0, 0, 0, 0, 0, 0} }; }
    bool checkParity() const {
        int32_t sum_a = 0, sum_b = 0;
        for (int i = 0; i < 4; ++i) { sum_a += data.v[i*2]; sum_b += data.v[i*2+1]; }
        return (sum_a == 0 && sum_b == 0);
    }
    static inline Quadray4 _spu_add_q4(Quadray4 u, Quadray4 v) { return { SPU_Vector256::add(u.data, v.data) }; }
    static inline Quadray4 _spu_rotate_60(Quadray4 q) { return { SPU_Vector256::rotate60(q.data) }; }
    static inline Quadray4 _spu_permute_q1(Quadray4 q) { return { SPU_Vector256::permute_q1(q.data) }; }
    
    static inline Quadray4 _spu_prime_permute(Quadray4 q, int phase) {
        switch (phase) {
            case 1: // P3: 60 deg Pin-A (a, d, b, c)
                return { {q.data.v[0], q.data.v[1], q.data.v[6], q.data.v[7], q.data.v[2], q.data.v[3], q.data.v[4], q.data.v[5]} };
            case 2: // P5: 120 deg Pin-A (a, c, d, b)
                return { {q.data.v[0], q.data.v[1], q.data.v[4], q.data.v[5], q.data.v[6], q.data.v[7], q.data.v[2], q.data.v[3]} };
            case 3: // P7: Hyper-Flip (d, b, c, a)
                return { {q.data.v[6], q.data.v[7], q.data.v[2], q.data.v[3], q.data.v[4], q.data.v[5], q.data.v[0], q.data.v[1]} };
            default: // P1: Identity (a, b, c, d)
                return q;
        }
    }

    static inline int64_t _spu_quadrance(Quadray4 u, Quadray4 v) {
        int64_t total = 0;
        for (int i = 0; i < 4; ++i) {
            int64_t da = (int64_t)u.data.v[i*2] - v.data.v[i*2];
            int64_t db = (int64_t)u.data.v[i*2+1] - v.data.v[i*2+1];
            total += (da * da) + (db * db * 3);
        }
        return total;
    }
    bool equals(const Quadray4& other) const {
        for (int i = 0; i < 8; ++i) if (data.v[i] != other.data.v[i]) return false;
        return true;
    }
};

struct DualSurd {
    SurdFixed64 val, eps;
    DualSurd add(const DualSurd& other) const { return { val.add(other.val), eps.add(other.eps) }; }
    DualSurd multiply(const DualSurd& other) const {
        return { val.multiply(other.val), val.multiply(other.eps).add(eps.multiply(other.val)) };
    }
};

// --- END SOVEREIGN CORE ---

// --- DISPLAY ADAPTER ---
namespace DisplayAdapter {
    static constexpr float SQRT3_ESTIMATE = 1.73205081f;
    static inline float toFloat(const SurdFixed64& s) {
        return (float(s.a) + float(s.b) * SQRT3_ESTIMATE) / float(SurdFixed64::One);
    }
}

// --- TENSEGRITY DYNAMICS ---
struct SPU_Mass { int64_t num, den; };
struct SPU_TensegrityNode {
    Quadray4 position;
    Quadray4 prev_position; 
    SPU_Mass mass;
    static inline void _spu_verlet_step(SPU_TensegrityNode& node, const Quadray4& a, int32_t dt_sq) {
        Quadray4 temp = node.position;
        Quadray4 twice_pos = { {node.position.data.v[0] << 1, node.position.data.v[1] << 1, 
                                 node.position.data.v[2] << 1, node.position.data.v[3] << 1,
                                 node.position.data.v[4] << 1, node.position.data.v[5] << 1,
                                 node.position.data.v[6] << 1, node.position.data.v[7] << 1} };
        Quadray4 neg_prev = { {-node.prev_position.data.v[0], -node.prev_position.data.v[1],
                               -node.prev_position.data.v[2], -node.prev_position.data.v[3],
                               -node.prev_position.data.v[4], -node.prev_position.data.v[5],
                               -node.prev_position.data.v[6], -node.prev_position.data.v[7]} };
        Quadray4 accel = { {a.data.v[0] * dt_sq, a.data.v[1] * dt_sq, a.data.v[2] * dt_sq, a.data.v[3] * dt_sq,
                            a.data.v[4] * dt_sq, a.data.v[5] * dt_sq, a.data.v[6] * dt_sq, a.data.v[7] * dt_sq} };
        node.position = Quadray4::_spu_add_q4(twice_pos, Quadray4::_spu_add_q4(neg_prev, accel));
        node.prev_position = temp;
    }
    static inline Quadray4 gravityVector() { return { {0, 0, 0, 0, 0, 0, SurdFixed64::One, 0} }; }
};

enum class LinkType { Cable, Strut, Tie };
struct TensegrityLink {
    int32_t nodeA_idx, nodeB_idx;
    int64_t rest_quadrance; 
    int32_t stiffness;      
    LinkType type;
    void projectConstraint(SPU_TensegrityNode& a, SPU_TensegrityNode& b) const {
        int64_t current_q = Quadray4::_spu_quadrance(a.position, b.position);
        if (type == LinkType::Cable && current_q <= rest_quadrance) return;
        if (type == LinkType::Strut && current_q >= rest_quadrance) return;
        int64_t diff = current_q - rest_quadrance;
        if (std::abs(diff) < 16) return; 
        for (int i = 0; i < 8; ++i) {
            int32_t delta = (a.position.data.v[i] - b.position.data.v[i]) >> 4;
            if (diff > 0) { a.position.data.v[i] -= delta; b.position.data.v[i] += delta; }
            else { a.position.data.v[i] += delta; b.position.data.v[i] -= delta; }
        }
    }
};

// --- LEGACY SUPPORT ---
struct RationalSurd {
    int64_t a, b, divisor;
    static RationalSurd zero() { return {0, 0, 1}; }
    static RationalSurd one() { return {1, 0, 1}; }
    static RationalSurd fromInt(int64_t val) { return {val, 0, 1}; }
    RationalSurd multiply(const RationalSurd& other) const {
#if defined(_MSC_VER) && !defined(__clang__)
        long double res_a = (long double)a * other.a + (long double)3 * b * other.b;
        long double res_b = (long double)a * other.b + (long double)b * other.a;
        return { (int64_t)res_a, (int64_t)res_b, divisor * other.divisor };
#else
        __int128_t res_a = (__int128_t)a * other.a + (__int128_t)3 * b * other.b;
        __int128_t res_b = (__int128_t)a * other.b + (__int128_t)b * other.a;
        return { (int64_t)res_a, (int64_t)res_b, divisor * other.divisor };
#endif
    }
    bool equals(const RationalSurd& other) const { return a * other.divisor == other.a * divisor && b * other.divisor == other.b * divisor; }
    float toFloat() const { return (float(a) + float(b) * DisplayAdapter::SQRT3_ESTIMATE) / float(divisor); }
};

} // namespace Synergetics

#endif
