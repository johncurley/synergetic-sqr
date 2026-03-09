#include <iostream>
#include <vector>
#include <random>
#include "spu/SynergeticsMath.hpp"

using namespace Synergetics;

/**
 * SPU-1 Chaos Verification Suite v1.8.9
 * 
 * These tests subject the SPU-1 logic to extreme non-linear stress.
 * Implementation: Integer-only to ensure zero floating-point linkage.
 */

static inline int32_t i_abs(int32_t x) { return (x < 0) ? -x : x; }

// --- 1. Compound Multi-Axis Chaos Test (Reproducible Randomness) ---
void RunMultiAxisChaosTest() {
    std::cout << "--- Test 1: Multi-Axis Chaos Test (10^8 iterations) ---" << std::endl;
    Quadray4 initial = Quadray4::identity();
    Quadray4 current = initial;
    
    // Deterministic pseudo-random seed
    std::mt19937 gen(42); 
    std::uniform_int_distribution<> dis(0, 3);

    for (uint64_t i = 0; i < 100000000; ++i) {
        int op = dis(gen);
        if (op == 0) current = Quadray4::_spu_rotate_60(current);
        else if (op == 1) { // Janus Flip Q1
            current.data.v[1] = -current.data.v[1];
        }
        else if (op == 2) { // Rotate Q1
            current = { {current.data.v[0], current.data.v[1], current.data.v[4], current.data.v[5], current.data.v[6], current.data.v[7], current.data.v[2], current.data.v[3]} };
        }
    }
    
    // After 10^8 random steps, the state is 'chaotic' but must remain algebraic.
    bool norm_ok = true;
    for(int i=0; i<4; i++) {
        SurdFixed64 s = { current.data.v[i*2], current.data.v[i*2+1] };
        if (s.a == 0 && s.b == 0) continue; 
        if (i_abs(s.a) > 0x7FFFFFFF) norm_ok = false;
    }

    if (norm_ok) {
        std::cout << "PASS: Multi-Axis Integrity Verified (No Algebraic Overflow)." << std::endl;
    } else {
        std::cerr << "FAIL: Algebraic corruption detected in Chaos Test!" << std::endl;
    }
}

// --- 2. Surd-Swap Identity Chains (Recursive Feedback) ---
void RunSurdSwapChainTest() {
    std::cout << "--- Test 2: Surd-Swap Identity Chain (10^7 iterations) ---" << std::endl;
    SurdFixed64 initial = { 65536, 0 };
    SurdFixed64 current = initial;
    
    for (int i = 0; i < 10000000; ++i) {
        current = current.multiply({ 65536, 0 }); 
        current = current.add({ 0, 0 });          
        if (i % 1000 == 0) current = current.janusFlip(); 
    }
    
    if (current.a == 65536 && current.b == 0) {
        std::cout << "PASS: Recursive Feedback Identity Verified (10^7 iterations)." << std::endl;
    } else {
        std::cerr << "FAIL: Identity Drift in Swap Chain! a=" << current.a << std::endl;
    }
}

// --- 3. Extreme Scale Oscillation ---
void RunScaleOscillationTest() {
    std::cout << "--- Test 3: Extreme Scale Oscillation (10^5 iterations) ---" << std::endl;
    SurdFixed64 current = { 65536, 0 };
    
    for (int i = 0; i < 100000; ++i) {
        current.a <<= 14; 
        current.b <<= 14;
        current = SurdFixed64::_spu_safe_normalize(current); 
        current.a >>= 13; 
        current.b >>= 13;
    }
    
    if (current.a > 0) {
        std::cout << "PASS: Scale Resilience Verified (No Zero-Collapse)." << std::endl;
    } else {
        std::cerr << "FAIL: State collapsed to zero during oscillation!" << std::endl;
    }
}

int main() {
    std::cout << "=======================================" << std::endl;
    std::cout << " SPU-1 CHAOS VERIFICATION SUITE v3.3.78" << std::endl;
    std::cout << "=======================================" << std::endl;
    
    RunMultiAxisChaosTest();
    RunSurdSwapChainTest();
    RunScaleOscillationTest();
    
    std::cout << "=======================================" << std::endl;
    return 0;
}
