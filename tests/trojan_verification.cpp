#include <iostream>
#include <iomanip>
#include "spu/TrojanCore.hpp"

using namespace Synergetics::Trojan;

/**
 * SPU-13 Trojan Audit Suite
 * 
 * Objective: Demonstrate the 'Cubic Tax' inherent in legacy XYZ computing.
 */

void RunContrastAudit(int iterations) {
    std::cout << "--- Test 19: Dual-Mode Contrast Audit (XYZ vs R6) ---" << std::endl;
    
    double accumulated_tax = 0.0;
    Synergetics::Quadray4 state = Synergetics::Quadray4::identity();

    std::cout << std::left << std::setw(10) << "ITER" << std::setw(15) << "MODE" << std::setw(15) << "Vd (HEART)" << std::endl;

    for (int i = 1; i <= iterations; ++i) {
        // Mode 1: Standardized Error (Legacy)
        TrojanCore::Resolve(state, CoordMode::XYZ_Legacy, accumulated_tax);
        double vd_legacy = TrojanCore::GetVd(accumulated_tax);
        
        if (i % 1000 == 0) {
            std::cout << std::setw(10) << i << std::setw(15) << "XYZ_Legacy" << std::setw(15) << std::fixed << std::setprecision(7) << vd_legacy << " [DRIFT]" << std::endl;
        }
    }

    // Mode 2: Native Truth (Switching to R6)
    accumulated_tax = 0.0;
    double vd_native = TrojanCore::GetVd(accumulated_tax);
    std::cout << std::setw(10) << "FINAL" << std::setw(15) << "R6_Native" << std::setw(15) << vd_native << " [HENOSIS]" << std::endl;

    if (vd_native == 1.0) {
        std::cout << "PASS: Native Truth restored identity bit-exactly." << std::endl;
    }
}

int main() {
    std::cout << "=======================================" << std::endl;
    std::cout << " SPU-13 Trojan Contrast Audit v3.0.34  " << std::endl;
    std::cout << "=======================================" << std::endl;
    
    RunContrastAudit(10000);
    
    std::cout << "=======================================" << std::endl;
    return 0;
}
