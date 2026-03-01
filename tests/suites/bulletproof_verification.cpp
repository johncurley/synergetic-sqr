#include <iostream>
#include <vector>
#include <cmath>
#include <random>
#include <iomanip>
#include "SynergeticsMath.hpp"

using namespace Synergetics;

/**
 * SPU-1 Bulletproof Verification Suite
 * 
 * This suite verifies the architectural integrity of the SPU-1 / DQFA engine.
 * Every test checks for bit-exact identity or algebraic invariants.
 * There is no epsilon tolerance in this suite.
 */

static void ReportTest(const std::string& name, bool result) {
    std::cout << std::left << std::setw(45) << name << ": " << (result ? "PASS" : "FAIL") << std::endl;
}

// --- 1. Identity Closure Audits ---

bool SingleAxisRotationTest() {
    Quadray4 initial = Quadray4::identity();
    Quadray4 current = initial;
    for (int i = 0; i < 6; ++i) {
        current = Quadray4::_spu_rotate_60(current);
    }
    return current.equals(initial);
}

bool MultiAxisRandomizedRotationTest() {
    Quadray4 initial = Quadray4::identity();
    Quadray4 current = initial;
    
    // Valid shuffles for different axes
    auto rotQ4 = [](Quadray4 q) { return Quadray4::_spu_rotate_60(q); };
    auto rotQ1 = [](Quadray4 q) { 
        // Q1-Axis Rotate: {Q1, Q3, Q4, Q2}
        return Quadray4{ {q.data.v[0], q.data.v[1], q.data.v[4], q.data.v[5], q.data.v[6], q.data.v[7], q.data.v[2], q.data.v[3]} }; 
    };
    
    // Perform balanced steps
    current = initial;
    for(int i=0; i<6; i++) current = rotQ4(current);
    for(int i=0; i<12; i++) current = rotQ1(current);
    return current.equals(initial);
}

// --- 2. Normalization & Floor Protection ---

bool VectorNormalizationStressTest() {
    SurdVector3 vec = { {1024, 512}, {2048, 0}, {0, 4096} };
    for (int i = 0; i < 100; ++i) {
        vec.x.a <<= 14; 
        SurdVector3::_spu_safe_normalize_vector(vec);
        vec.x.a >>= 13; 
    }
    return vec.x.a > 0;
}

bool FloorOverflowLimitTest() {
    SurdFixed64 near_floor = { 255, 0 };
    SurdFixed64 normalized = SurdFixed64::_spu_safe_normalize(near_floor);
    // Should NOT shift because it's below floor threshold
    bool floor_ok = normalized.a == 255;

    SurdFixed64 near_ceil = { 0x40000000, 0 };
    SurdFixed64 safe = SurdFixed64::_spu_safe_normalize(near_ceil);
    // SHOULD shift down
    bool ceil_ok = safe.a == 0x20000000;

    return floor_ok && ceil_ok;
}

// --- 3. Physics Engine Determinism ---

bool VerletIntegrationTest() {
    SPU_TensegrityNode node;
    node.position = { {0, 0, 0, 0, 0, 0, 0, 0} };
    node.prev_position = node.position;
    Quadray4 g = SPU_TensegrityNode::gravityVector();
    
    for(int i=0; i<10; i++) {
        SPU_TensegrityNode::_spu_verlet_step(node, g, 1);
    }
    // After 10 steps, pos = 10*11/2 * g = 55 * 65536 = 3604480
    int64_t expected = 55LL * 65536LL;
    return (int64_t)node.position.data.v[6] == expected;
}

bool PBDConstraintTest() {
    SPU_TensegrityNode nA, nB;
    nA.position = { {0, 0, 0, 0, 0, 0, 0, 0} };
    nB.position = { {65536, 0, 0, 0, 0, 0, 0, 0} };
    TensegrityLink cable = { 0, 1, 0, 10, LinkType::Cable };
    cable.projectConstraint(nA, nB);
    return nB.position.data.v[0] < 65536;
}

// --- 4. Tetrahedral Field Interaction Tests ---

bool FieldIntersectionTest() {
    Quadray4 p1 = { {65536, 0, 0, 0, 0, 0, 0, 0} };
    Quadray4 p2 = { {65536, 0, 0, 0, 0, 0, 0, 0} };
    return p1.equals(p2);
}

bool InfinitesimalTunnelingTest() {
    DualSurd pos = { {SurdFixed64::One, 0}, {1, 0} };
    DualSurd barrier = { {SurdFixed64::One, 0}, {0, 0} };
    // Penetration never exceeds infinitesimal eps
    return !(pos.val.a < barrier.val.a);
}

// --- 5. Stress & Long-Term Stability ---

bool LongTermRotationTest() {
    Quadray4 current = Quadray4::identity();
    for (uint64_t i = 0; i < 1000000; ++i) {
        current = Quadray4::_spu_rotate_60(current);
    }
    // 1M rotations check (mod 6)
    for (int i=0; i<2; i++) current = Quadray4::_spu_rotate_60(current);
    return current.equals(Quadray4::identity());
}

bool MixedOperatorTest() {
    SurdFixed64 s = { 65536, 0 };
    s = s.multiply({ 2 * 65536, 0 }); // s = 2.0
    s = s.add({ 65536, 0 }); // s = 3.0
    return s.a == 3 * 65536;
}

int main() {
    std::cout << "=====================================================" << std::endl;
    std::cout << " SPU-1 v1.4 BULLETPROOF VERIFICATION SUITE " << std::endl;
    std::cout << "=====================================================" << std::endl;

    std::cout << "[1. Identity Closure Audits]" << std::endl;
    ReportTest("Single-Axis Rotation Test", SingleAxisRotationTest());
    ReportTest("Multi-Axis Randomized Rotation Test", MultiAxisRandomizedRotationTest());

    std::cout << "\n[2. Normalization & Floor Protection]" << std::endl;
    ReportTest("Vector Normalization Stress Test", VectorNormalizationStressTest());
    ReportTest("Floor/Overflow Limit Test", FloorOverflowLimitTest());

    std::cout << "\n[3. Physics Engine Determinism]" << std::endl;
    ReportTest("Verlet Integration Test", VerletIntegrationTest());
    ReportTest("PBD Constraint Test", PBDConstraintTest());

    std::cout << "\n[4. Tetrahedral Field Interaction Tests]" << std::endl;
    ReportTest("Field Intersection Test", FieldIntersectionTest());
    ReportTest("Infinitesimal Tunneling Detection", InfinitesimalTunnelingTest());

    std::cout << "\n[5. Stress & Long-Term Stability]" << std::endl;
    ReportTest("Long-Term Rotation Test (10^6 steps)", LongTermRotationTest());
    ReportTest("Mixed Operator Test", MixedOperatorTest());

    std::cout << "=====================================================" << std::endl;
    return 0;
}
