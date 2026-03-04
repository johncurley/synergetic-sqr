#include <iostream>
#include "spu/LatticeLock.hpp"

using namespace Synergetics;
using namespace Synergetics::Security;

/**
 * SPU-13 Security Verification Suite
 * 
 * Objective: Verify Geometric Encryption (Lattice-Lock) identity restoration.
 */

void VerifyLatticeLock() {
    std::cout << "--- Test 16: Lattice-Lock Geometric Encryption ---" << std::endl;
    
    Quadray4 secret_data = Quadray4::identity();
    int curvature_key = 3; // P7 Hyper-Flip

    // 1. Lock the data
    Quadray4 locked = LatticeLock::Lock(secret_data, curvature_key);
    
    std::cout << "Data Locked via Manifold Curvature (Key: " << curvature_key << ")" << std::endl;

    // 2. Verify Incompatibility (Should not equal identity)
    if (!locked.equals(secret_data)) {
        std::cout << "PASS: Data is Incompatible with standard observation." << std::endl;
    } else {
        std::cerr << "FAIL: Data was not correctly folded!" << std::endl;
    }

    // 3. Unlock the data
    Quadray4 restored = LatticeLock::Unlock(locked, curvature_key);

    // 4. Verify Identity Restoration
    if (restored.equals(secret_data)) {
        std::cout << "PASS: Bit-Exact Identity restored via Reciprocal Key." << std::endl;
    } else {
        std::cerr << "FAIL: Identity Restoration Failed!" << std::endl;
    }
}

int main() {
    std::cout << "=======================================" << std::endl;
    std::cout << " SPU-13 Pleroma Guard Audit v2.9.1     " << std::endl;
    std::cout << "=======================================" << std::endl;
    
    VerifyLatticeLock();
    
    std::cout << "=======================================" << std::endl;
    return 0;
}
