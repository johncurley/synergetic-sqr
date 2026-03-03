#include <iostream>
#include <vector>
#include "spu/SDK.hpp"

using namespace Synergetics::SDK;

/**
 * Robotics Verification Suite
 * 
 * Objective: Verify bit-exact identity restoration in a long kinematic chain.
 */

void VerifyKinematicStability() {
    std::cout << "--- Test 15: Kinematic Chain Stability (100 Joints) ---" << std::endl;
    
    KinematicChain arm;
    // 1. Initialize 100 joints with distinct rational offsets
    for (int i = 0; i < 100; ++i) {
        arm.AddJoint({ {65536, 0, 0, 0, 0, 0, 0, 0} }); // 1 unit Q1 offset
    }

    Synergetics::Quadray4 initial_hand = arm.CalculateEndEffector();

    // 2. Perform 1,000,000 global rotations (Stress test)
    for (int i = 0; i < 1000000; ++i) {
        for (auto& j : arm.joints) {
            j.Rotate(1); // Rotate each joint by one prime phase
        }
    }

    // 3. Perform enough rotations to return to P1 (1,000,000 is 250,000 full cycles)
    Synergetics::Quadray4 final_hand = arm.CalculateEndEffector();

    if (final_hand.equals(initial_hand)) {
        std::cout << "PASS: Kinematic Chain bit-perfect after 1,000,000 rotations." << std::endl;
    } else {
        std::cerr << "FAIL: Joint drift detected! Bitmask mismatch." << std::endl;
    }
}

int main() {
    std::cout << "=======================================" << std::endl;
    std::cout << " SPU-1 Robotics Verification Suite v2.5 " << std::endl;
    std::cout << "=======================================" << std::endl;
    
    VerifyKinematicStability();
    
    std::cout << "=======================================" << std::endl;
    return 0;
}
