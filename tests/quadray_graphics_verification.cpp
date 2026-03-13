// SPU-13 Quadray Graphics Verification (v1.0)
// Objective: Verify Quadray-to-IVM conversion and Rational Scaling.
// Vibe: The End of Cartesian Drift.

#include <iostream>
#include <iomanip>
#include "spu/SynergeticsMath.hpp"

using namespace Synergetics;

int main() {
    std::cout << "--- SPU-13 Quadray-to-IVM Accelerator Audit ---" << std::endl;

    // 1. Establish a Quadray point: Vector A (Up)
    Quadray4 pos = Quadray4::identity(); // Standard identity is Vector A [1,0,0,0]
    
    // 2. Rational Scale (1.5x)
    SurdFixed64 scale = { (1 << 16) + (1 << 15), 0 }; // 1.5 in 1.16 fixed-point
    Quadray4 scaled_pos = pos * scale;

    // 3. Project to 2D IVM Grid
    float x, y;
    scaled_pos.toIVM(x, y);

    std::cout << "Original Pos (A): {1, 0, 0, 0}" << std::endl;
    std::cout << "Scaled Pos (1.5x): {" << (float(scaled_pos.data.v[0])/65536.0f) << ", 0, 0, 0}" << std::endl;
    std::cout << "Projected IVM: X=" << std::fixed << std::setprecision(4) << x << ", Y=" << y << std::endl;

    // Verification: Vector A should project to (0, 1.5)
    if (std::abs(x - 0.0f) < 0.001f && std::abs(y - 1.5f) < 0.001f) {
        std::cout << "[PASS] Vector A projection is perfectly aligned." << std::endl;
    } else {
        std::cout << "[FAIL] Vector A projection drift detected." << std::endl;
        return 1;
    }

    // 4. Verify Vector B (120 degrees)
    Quadray4 pos_b;
    std::memset(pos_b.data.v, 0, 32);
    pos_b.data.v[2] = 1 << 16; // Vector B = [0, 1, 0, 0]
    pos_b.toIVM(x, y);
    
    std::cout << "Vector B Projected IVM: X=" << x << ", Y=" << y << std::endl;
    // B = (sqrt(3)/2, -1/2) = (0.866, -0.5)
    if (std::abs(x - 0.8660f) < 0.001f && std::abs(y - (-0.5f)) < 0.001f) {
        std::cout << "[PASS] Vector B projection is perfectly aligned." << std::endl;
    } else {
        std::cout << "[FAIL] Vector B projection drift detected." << std::endl;
        return 1;
    }

    std::cout << "--- Audit Complete: The Manifold is Aligned ---" << std::endl;
    return 0;
}
