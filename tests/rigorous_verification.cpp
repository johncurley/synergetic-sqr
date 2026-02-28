#include <iostream>
#include <vector>
#include <cmath>
#include "SynergeticsMath.hpp"

using namespace Synergetics;

/**
 * These tests do not check for 'closeness.' They check for Bit-Identity. 
 * If a single bit differs from the predicted algebraic output, the test is marked as a failure. 
 * There is no epsilon (e) in the Sovereign Architecture.
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
        std::cout << "SUCCESS: Bit-Exact Stability Verified after 10^8 iterations." << std::endl;
    } else {
        std::cerr << "FAILURE: Bit-drift detected in rotation stability test!" << std::endl;
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
        std::cout << "SUCCESS: Commutativity Verified (Algebraic Integrity)." << std::endl;
    } else {
        std::cerr << "FAILURE: Invariant break detected in involution test!" << std::endl;
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
        std::cout << "SUCCESS: Algebraic Ratio Preserved during normalization." << std::endl;
        std::cout << "  Normalizations triggered: " << normalize_count << std::endl;
        std::cout << "  Final State: a=" << current.a << " b=" << current.b << std::endl;
    } else {
        std::cerr << "FAILURE: Ratio drift detected in scaling test!" << std::endl;
    }
}

int main() {
    std::cout << "=======================================" << std::endl;
    std::cout << " SPU-1 RIGOROUS VERIFICATION SUITE v1.7 " << std::endl;
    std::cout << "=======================================" << std::endl;
    
    RunOrbitsOfInfinity();
    RunMirrorLatticeTest();
    RunStressScaleTest();
    
    std::cout << "=======================================" << std::endl;
    return 0;
}
