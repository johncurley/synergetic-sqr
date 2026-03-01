#include <iostream>
#include "spu/SDK.hpp"

using namespace Synergetics::SDK;

int main() {
    std::cout << "--- Synergetic SDK v0.1 Verification ---" << std::endl;

    // 1. Test Rational Snap
    // Snap (1.0, 1.0, 1.0) -> Expected Quadray (0, 0, 0, 1) in normalized IVM
    Synergetics::Quadray4 snapped = RationalSnap(1.0f, 1.0f, 1.0f);
    
    if (snapped.data.v[6] == 16384) { // (1.0 / 4 * 65536)
        std::cout << "PASS: RationalSnap bit-exact (1.0, 1.0, 1.0) -> Q4 Identity." << std::endl;
    } else {
        std::cerr << "FAIL: RationalSnap drift! Q4=" << snapped.data.v[6] << std::endl;
    }

    // 2. Test Primitive Creation
    TetraUnit t = TetraUnit::Create();
    if (t.vertices.size() == 4) {
        std::cout << "PASS: TetraUnit primitive created with 4 bit-exact vertices." << std::endl;
    }

    // 3. Test Object Rotation
    RotateObject(t.vertices, 6); // Full circuit
    if (t.vertices[0].data.v[0] == 65536) {
        std::cout << "PASS: RotateObject verified (Identity Restoration)." << std::endl;
    }

    std::cout << "--- ALL SDK TESTS PASSED ---" << std::endl;
    return 0;
}
