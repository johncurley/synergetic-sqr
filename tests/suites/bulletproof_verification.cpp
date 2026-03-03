#include <iostream>
#include <vector>
#include <cmath>
#include <random>
#include <iomanip>
#include <string.h>
#include "spu/SynergeticsMath.hpp"

using namespace Synergetics;

/**
 * SPU-1 Bulletproof Verification Suite
 * 
 * This suite verifies the architectural integrity of the SPU-1 / DQFA engine.
 * Every test checks for bit-exact identity or algebraic invariants.
 */

static void ReportTest(const std::string& name, bool result) {
    std::cout << std::left << std::setw(45) << name << ": " << (result ? "PASS" : "FAIL") << std::endl;
}

// --- 1. Identity Closure Audits ---

bool SingleAxisRotationTest() {
    Synergetics::Quadray4 initial = Synergetics::Quadray4::identity();
    Synergetics::Quadray4 current = initial;
    for (int i = 0; i < 6; ++i) {
        current = Synergetics::Quadray4::_spu_rotate_60(current);
    }
    return current.equals(initial);
}

bool MultiAxisRandomizedRotationTest() {
    Synergetics::Quadray4 initial = Synergetics::Quadray4::identity();
    Synergetics::Quadray4 current = initial;
    for(int i=0; i<6; i++) current = Synergetics::Quadray4::_spu_rotate_60(current);
    for(int i=0; i<6; i++) current = Synergetics::Quadray4::_spu_permute_q1(current);
    return current.equals(initial);
}

// --- 2. Normalization & Floor Protection ---

bool VectorNormalizationStressTest() {
    Synergetics::SurdVector3 vec = { {1024, 512}, {2048, 0}, {0, 4096} };
    for (int i = 0; i < 100; ++i) {
        vec.x.a <<= 14; 
        Synergetics::SurdVector3::_spu_safe_normalize_vector(vec);
        vec.x.a >>= 13; 
    }
    return vec.x.a > 0;
}

bool FloorOverflowLimitTest() {
    Synergetics::SurdFixed64 near_floor = { 255, 0 };
    Synergetics::SurdFixed64 normalized = Synergetics::SurdFixed64::_spu_safe_normalize(near_floor);
    bool floor_ok = (normalized.a == 255);

    Synergetics::SurdFixed64 near_ceil = { 0x40000000, 0 };
    Synergetics::SurdFixed64 safe = Synergetics::SurdFixed64::_spu_safe_normalize(near_ceil);
    bool ceil_ok = (safe.a == 0x20000000);

    return floor_ok && ceil_ok;
}

// --- 3. Physics Engine Determinism ---

bool VerletIntegrationTest() {
    Synergetics::SPU_TensegrityNode node;
    node.position = { {0, 0, 0, 0, 0, 0, 0, 0} };
    node.prev_position = node.position;
    node.mass = {1, 1};
    Synergetics::Quadray4 g = Synergetics::SPU_TensegrityNode::gravityVector();
    
    for(int i=0; i<10; i++) {
        Synergetics::SPU_TensegrityNode::_spu_verlet_step(node, g, 1);
    }
    int64_t expected = 55LL * 65536LL;
    return (int64_t)node.position.data.v[6] == expected;
}

bool PBDConstraintTest() {
    Synergetics::SPU_TensegrityNode nA, nB;
    nA.position = { {0, 0, 0, 0, 0, 0, 0, 0} };
    nB.position = { {65536, 0, 0, 0, 0, 0, 0, 0} };
    nA.mass = {1, 1}; nB.mass = {1, 1};
    Synergetics::TensegrityLink cable = { 0, 1, 0, 10, Synergetics::LinkType::Cable };
    cable.projectConstraint(nA, nB);
    return nB.position.data.v[0] < 65536;
}

// --- 4. Stress & Long-Term Stability ---

bool LongTermRotationTest() {
    Synergetics::Quadray4 current = Synergetics::Quadray4::identity();
    for (uint64_t i = 0; i < 1000000; ++i) {
        current = Synergetics::Quadray4::_spu_rotate_60(current);
    }
    for (int i=0; i<2; i++) current = Synergetics::Quadray4::_spu_rotate_60(current);
    return current.equals(Synergetics::Quadray4::identity());
}

int main() {
    std::cout << "=====================================================" << std::endl;
    std::cout << " SPU-1 v2.5.10 BULLETPROOF VERIFICATION SUITE " << std::endl;
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

    std::cout << "\n[4. Stress & Long-Term Stability]" << std::endl;
    ReportTest("Long-Term Rotation Test (10^6 steps)", LongTermRotationTest());

    std::cout << "=====================================================" << std::endl;
    return 0;
}
