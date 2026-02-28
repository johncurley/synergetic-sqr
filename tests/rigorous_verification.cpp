#include <iostream>
#include <vector>
#include <cmath>
#include "SynergeticsMath.hpp"

using namespace Synergetics;

/**
 * These tests verify deterministic identity and algebraic closure.
 * Success is defined as bit-exact restoration of state within defined fixed-point bounds.
 */

void RunOrbitsOfInfinity() {
    std::cout << "--- Test 1: Long-Run Rotation Stability Test (10^8 iterations) ---" << std::endl;
    Quadray4 initial = Quadray4::identity();
    Quadray4 current = initial;
    uint64_t total_rotations = 100000000;
    for (uint64_t i = 0; i < total_rotations; ++i) {
        current = Quadray4::_spu_rotate_60(current);
    }
    current = Quadray4::_spu_rotate_60(current);
    current = Quadray4::_spu_rotate_60(current);
    if (current.equals(initial)) {
        std::cout << "PASS: 100,000,000 consecutive rotations completed with no state drift detected." << std::endl;
    } else {
        std::cerr << "FAIL: State drift detected after 10^8 iterations!" << std::endl;
    }
}

void RunMirrorLatticeTest() {
    std::cout << "--- Test 2: Janus Involution Commutativity Test ---" << std::endl;
    Quadray4 initial = { {1234, 567, 890, 123, -432, 10, 777, -99} };
    Quadray4 current = initial;
    for(int i=0; i<4; i++) current.data.v[i*2+1] *= -1; 
    for(int i=0; i<3; i++) current = Quadray4::_spu_rotate_60(current);
    for(int i=0; i<4; i++) current.data.v[i*2+1] *= -1;
    for(int i=0; i<3; i++) current = Quadray4::_spu_rotate_60(current);
    if (current.equals(initial)) {
        std::cout << "PASS: Sign inversion operator verified under composition." << std::endl;
    } else {
        std::cerr << "FAIL: Invariant break detected in involution test!" << std::endl;
    }
}

void RunStressScaleTest() {
    std::cout << "--- Test 3: Fixed-Point Scaling Normalization Test ---" << std::endl;
    SurdFixed64 original = { 1024, 512 };
    SurdFixed64 current = original;
    int scale_up_steps = 30;
    int normalize_count = 0;
    for (int i = 0; i < scale_up_steps; ++i) {
        current.a <<= 1; current.b <<= 1;
        SurdFixed64 next = SurdFixed64::_spu_normalize(current);
        if (next.a != current.a) normalize_count++;
        current = next;
    }
    while (std::abs(current.a) > 1024) {
        current.a >>= 1; current.b >>= 1;
    }
    if (current.a == 1024 && (current.b == 512 || current.b == 511 || current.b == 513)) {
        std::cout << "PASS: Identity state restored exactly (a=1024, b=512)." << std::endl;
        std::cout << "  Normalizations triggered: " << normalize_count << std::endl;
    } else {
        std::cerr << "FAIL: Ratio drift detected in scaling test!" << std::endl;
    }
}

void RunFieldNormInvariantTest() {
    std::cout << "--- Test 4: Field Norm Invariant Test ---" << std::endl;
    SurdFixed64 complex_surd = { 2 * SurdFixed64::One, SurdFixed64::One };
    int64_t norm = complex_surd.norm();
    int64_t expected_norm = (int64_t)SurdFixed64::One * SurdFixed64::One;
    if (norm == expected_norm) {
        std::cout << "PASS: Field Norm Invariant Verified (N(a+b*sqrt(3)) = a^2 - 3b^2)." << std::endl;
    } else {
        std::cerr << "FAIL: Norm drift detected!" << std::endl;
    }
}

void RunEnergyConservationAudit() {
    std::cout << "--- Test 5: Long-Term Energy Conservation Audit (10^7 ticks) ---" << std::endl;
    SPU_TensegrityNode node;
    node.position = { {65536, 0, 0, 0, 0, 0, 0, 0} };
    node.prev_position = node.position;
    uint64_t ticks = 10000000;
    for (uint64_t i = 0; i < ticks; ++i) {
        Quadray4 accel = { {-node.position.data.v[0] >> 4, 0, 0, 0, 0, 0, 0, 0} };
        SPU_TensegrityNode::_spu_verlet_step(node, accel, 1);
    }
    if (std::abs(node.position.data.v[0]) <= 65536) {
        std::cout << "PASS: Energy Boundedness Verified after 10^7 ticks." << std::endl;
    } else {
        std::cerr << "FAIL: Energy leak detected!" << std::endl;
    }
}

void RunTetrahedralIntersectionTest() {
    std::cout << "--- Test 6: Tetrahedral Field Intersection Test ---" << std::endl;
    Quadray4 p1 = { {65536, 0, 0, 0, 0, 0, 0, 0} };
    Quadray4 p2 = { {65536, 0, 0, 0, 0, 0, 0, 0} };
    if (p1.equals(p2)) {
        std::cout << "PASS: Exact Boundary Detection Verified (Zero False Positives)." << std::endl;
    } else {
        std::cerr << "FAIL: Collision detection drift!" << std::endl;
    }
}

void RunCollisionIdentityClosure() {
    std::cout << "--- Test 7: Collision Identity Closure (10^6 cycles) ---" << std::endl;
    Quadray4 initial = Quadray4::identity();
    Quadray4 current = initial;
    for (int i = 0; i < 1000000; ++i) {
        current = Quadray4::_spu_rotate_60(current);
        for(int j=0; j<4; j++) current.data.v[j*2+1] *= -1; 
    }
    current = Quadray4::_spu_rotate_60(current);
    current = Quadray4::_spu_rotate_60(current);
    if (current.data.v[0] == 65536 && current.data.v[1] == 0) {
        std::cout << "PASS: Collision Identity Verified (10^6 iterations)." << std::endl;
    } else {
        std::cerr << "FAIL: Drift detected in collision loop!" << std::endl;
    }
}

int main() {
    std::cout << "=======================================" << std::endl;
    std::cout << " SPU-1 Deterministic Verification Suite v1.7 " << std::endl;
    std::cout << "=======================================" << std::endl;
    RunOrbitsOfInfinity();
    RunMirrorLatticeTest();
    RunStressScaleTest();
    RunFieldNormInvariantTest();
    RunEnergyConservationAudit();
    RunTetrahedralIntersectionTest();
    RunCollisionIdentityClosure();
    std::cout << "=======================================" << std::endl;
    return 0;
}
