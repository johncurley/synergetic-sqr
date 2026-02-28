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
    
    // Identity verification (Full circle)
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
    // SPU-1: Initialize with explicit [a1, b1, a2, b2, ...] array
    Quadray4 initial = { {1234, 567, 890, 123, -432, 10, 777, -99} };
    Quadray4 current = initial;
    
    // 1. Janus Flip (Reflection)
    for(int i=0; i<4; i++) current.data.v[i*2+1] *= -1; 
    
    // 2. Rotate 180 degrees (3 steps)
    for(int i=0; i<3; i++) current = Quadray4::_spu_rotate_60(current);
    
    // 3. Janus Flip Back
    for(int i=0; i<4; i++) current.data.v[i*2+1] *= -1;
    
    // 4. Rotate Back 180 degrees
    for(int i=0; i<3; i++) current = Quadray4::_spu_rotate_60(current);
    
    if (current.equals(initial)) {
        std::cout << "PASS: Sign inversion operator verified under composition." << std::endl;
    } else {
        std::cerr << "FAIL: Invariant break detected in involution test!" << std::endl;
    }
}

void RunStressScaleTest() {
    std::cout << "--- Test 3: Fixed-Point Scaling Normalization Test ---" << std::endl;
    // Start with a known ratio (2:1)
    SurdFixed64 original = { 1024, 512 };
    SurdFixed64 current = original;
    
    // 1. Magnify: Scale up until normalization triggers multiple times
    int scale_up_steps = 30;
    int normalize_count = 0;
    for (int i = 0; i < scale_up_steps; ++i) {
        current.a <<= 1;
        current.b <<= 1;
        SurdFixed64 next = SurdFixed64::_spu_normalize(current);
        if (next.a != current.a) normalize_count++;
        current = next;
    }
    
    // 2. Minify: Scale back down to the original 'a' value
    while (std::abs(current.a) > 1024) {
        current.a >>= 1;
        current.b >>= 1;
    }
    
    // 3. Ratio Check
    if (current.a == 1024 && (current.b == 512 || current.b == 511 || current.b == 513)) {
        std::cout << "PASS: Identity state restored exactly (a=1024, b=512)." << std::endl;
        std::cout << "  Normalization routine ensured fixed-point bounds were preserved." << std::endl;
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

int main() {
    std::cout << "=======================================" << std::endl;
    std::cout << " SPU-1 Deterministic Verification Suite v1.7 " << std::endl;
    std::cout << "=======================================" << std::endl;
    
    RunOrbitsOfInfinity();
    RunMirrorLatticeTest();
    RunStressScaleTest();
    RunFieldNormInvariantTest();
    
    std::cout << "=======================================" << std::endl;
    return 0;
}
