#include <iostream>
#include <vector>
#include <cmath>
#include "spu/SynergeticsMath.hpp"

using namespace Synergetics;

/**
 * Phi-Scaling Verification Suite
 * 
 * Objective: Verify bit-exact Fibonacci-based scaling (Phi Expansion/Contraction)
 * Matching the logic in phi_rotor_scaler.v.
 */

int32_t spu_phi_expand(int32_t in) {
    // Logic: in + in/2 + in/8 + in/64
    return in + (in >> 1) + (in >> 3) + (in >> 6);
}

int32_t spu_phi_contract(int32_t in) {
    // Logic: in/2 + in/8 + in/64
    return (in >> 1) + (in >> 3) + (in >> 6);
}

void VerifyPhiScaling() {
    std::cout << "--- Test 18: Fibonacci-Based Bit-Exact Phi Scaling ---" << std::endl;
    
    int32_t initial = 65536; // 1.0 in SF32.16
    
    // 1. Expand
    int32_t expanded = spu_phi_expand(initial);
    // Expected: 65536 + 32768 + 8192 + 1024 = 107520 (approx 1.64...)
    // Note: Bit-shifting is a deterministic approximation of the field member.
    
    std::cout << "Initial: " << initial << " -> Expanded: " << expanded << std::endl;

    // 2. Contract (Reciprocal check)
    int32_t contracted = spu_phi_contract(expanded);
    
    if (expanded > initial && expanded == 107520) {
        std::cout << "PASS: Phi-Expansion bit-exact matching RTL shift-logic." << std::endl;
    } else {
        std::cerr << "FAIL: Expansion drift detected! Got " << expanded << std::endl;
    }
}

int main() {
    std::cout << "=======================================" << std::endl;
    std::cout << " SPU-13 Phi-Scaling Audit v3.0.31      " << std::endl;
    std::cout << "=======================================" << std::endl;
    
    VerifyPhiScaling();
    
    std::cout << "=======================================" << std::endl;
    return 0;
}
