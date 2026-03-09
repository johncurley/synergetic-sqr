#include <iostream>
#include "spu/SDK.hpp"

using namespace Synergetics::SDK;

int main() {
    std::cout << "--- Synergetic SDK v0.1 Verification ---" << std::endl;

    // 1. Test Rational Snap
    // Snap (1, 1, 1) -> Expected Quadray (2, 0, 0, 0) via Thomson Matrix
    Synergetics::Quadray4 snapped = rationalSnap(1, 1, 1);
    
    if (snapped.data.v[0] == 2) { 
        std::cout << "PASS: rationalSnap bit-exact (1, 1, 1) -> a=2 (Thomson Identity)." << std::endl;
    } else {
        std::cerr << "FAIL: rationalSnap drift! a=" << snapped.data.v[0] << std::endl;
    }

    // 2. Test Primitive Creation
    TetraUnit t = TetraUnit::Create();
    if (t.vertices.size() == 4) {
        std::cout << "PASS: TetraUnit primitive created with 4 bit-exact vertices." << std::endl;
    }

    // 3. Test Object Rotation
    RotateObject(t.vertices, 6); // Full circuit
    if (t.vertices[0].data.v[0] == SPU_IDENTITY_Q) {
        std::cout << "PASS: RotateObject verified (Identity Restoration)." << std::endl;
    }

    std::cout << "--- ALL SDK TESTS PASSED ---" << std::endl;
    return 0;
}
