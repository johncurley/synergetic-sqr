#include <iostream>
#include <iomanip>
#include "spu/SPU_Assembler.hpp"

using namespace Synergetics::Assembler;

/**
 * SPU-13 Toolchain Verification Suite
 * 
 * Objective: Verify that the Macro-Assembler emits bit-exact RISC-V custom-0 opcodes.
 */

void VerifyOpcode(const std::string& name, uint32_t op, uint32_t expected) {
    std::cout << std::left << std::setw(10) << name << ": 0x" 
              << std::hex << std::setfill('0') << std::setw(8) << op;
    if (op == expected) {
        std::cout << " [PASS]" << std::endl;
    } else {
        std::cout << " [FAIL] Expected 0x" << std::hex << expected << std::endl;
    }
}

int main() {
    std::cout << "=======================================" << std::endl;
    std::cout << " SPU-13 Toolchain Audit v2.7.1         " << std::endl;
    std::cout << "=======================================" << std::endl;

    // Test SADD: rd=1, rs1=2, rs2=3
    // binary: 0000000 00011 00010 000 00001 0001011 -> 0x0031008B
    VerifyOpcode("SADD", SADD(1, 2, 3), 0x0031008B);

    // Test SPERM_X4: rd=5, rs1=6, phase=P3(1)
    // binary: 0000001 00000 00110 010 00101 0001011 -> 0x0203228B
    VerifyOpcode("SPERM_X4", SPERM_X4(5, 6, 1), 0x0203228B);

    // Test DAMP: rd=10, rs1=11
    // binary: 0000000 00000 01011 100 01010 0001011 -> 0x0005C50B
    VerifyOpcode("DAMP", DAMP(10, 11), 0x0005C50B);

    std::cout << "=======================================" << std::endl;
    return 0;
}
