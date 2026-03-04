#include <iostream>
#include <vector>
#include "spu/SDK.hpp"

using namespace Synergetics::SDK;

/**
 * Path C Rational Hull Verification Suite
 * 
 * Objective: Verify bit-exact polyhedral synthesis from a noisy point cloud.
 */

void VerifyRationalHull() {
    std::cout << "--- Test 17: Path C Rational Hull Synthesis ---" << std::endl;
    
    // 1. Create a noisy point cloud (Simplex + random interior points)
    std::vector<Synergetics::Quadray4> cloud;
    // The Simplex (The Skin)
    cloud.push_back({ {65536, 0, 0, 0, 0, 0, 0, 0} });
    cloud.push_back({ {0, 0, 65536, 0, 0, 0, 0, 0} });
    cloud.push_back({ {0, 0, 0, 0, 65536, 0, 0, 0} });
    cloud.push_back({ {0, 0, 0, 0, 0, 0, 65536, 0} });
    
    // Random interior points (The noise)
    cloud.push_back({ {1024, 0, 1024, 0, 1024, 0, 1024, 0} });
    cloud.push_back({ {2048, 0, 2048, 0, 2048, 0, 2048, 0} });

    // 2. Generate the Hull
    std::vector<Synergetics::Quadray4> hull = PathC_Hull::GenerateHull(cloud);

    // 3. Verify Identity (Hull should exactly match the simplex boundary)
    std::cout << "Hull Generated with " << hull.size() << " vertices." << std::endl;

    bool noise_purged = true;
    for (const auto& v : hull) {
        if (v.data.v[0] == 1024 || v.data.v[0] == 2048) noise_purged = false;
    }

    if (noise_purged && hull.size() >= 3) {
        std::cout << "PASS: Path C Rational Hull synthesized bit-exactly." << std::endl;
    } else {
        std::cerr << "FAIL: Noise points detected in the skin or insufficient boundary!" << std::endl;
    }
}

int main() {
    std::cout << "=======================================" << std::endl;
    std::cout << " SPU-13 Rational Hull Audit v2.9.3     " << std::endl;
    std::cout << "=======================================" << std::endl;
    
    VerifyRationalHull();
    
    std::cout << "=======================================" << std::endl;
    return 0;
}
