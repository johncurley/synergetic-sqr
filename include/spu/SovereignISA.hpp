#ifndef SOVEREIGN_ISA_HPP
#define SOVEREIGN_ISA_HPP

#include <stdint.h>

namespace Synergetics {

// SPU-13 Sovereign Draw (SDRAW) Opcodes
enum SDRAW_Opcode : uint8_t {
    SDRAW_V = 0x40, // Draw Sovereign Vector
    SPROJ_P = 0x41, // Project Sovereign Point
    SFILL_H = 0x42, // Fill Hexagonal Field
    SET_SOV = 0xA9, // Toggle Global Sovereignty
    SET_LMN = 0xAC, // Set Laminar Stride
    LUT_LD  = 0xAF  // Load Inverse-Gamma LUT
};

// SPU-13 Instruction Word Construction
struct SovereignCommand {
    uint8_t  opcode;
    int16_t  q_a, q_b, q_c, q_d; // 12-bit native quadrays
    uint8_t  energy;

    // Compiles the command into a 64-bit "Sovereign Word"
    uint64_t compile() const {
        uint64_t word = 0;
        // [63:56] Opcode
        word |= ((uint64_t)opcode << 56);
        // [55:44] Q_A (12-bit signed)
        word |= (((uint64_t)q_a & 0x0FFF) << 44);
        // [43:32] Q_B (12-bit signed)
        word |= (((uint64_t)q_b & 0x0FFF) << 32);
        // [31:24] Energy
        word |= ((uint64_t)energy << 24);
        // [23:12] Q_C (12-bit signed)
        word |= (((uint64_t)q_c & 0x0FFF) << 12);
        // [11:0]  Q_D (12-bit signed)
        word |= ((uint64_t)q_d & 0x0FFF);
        return word;
    }
};

} // namespace Synergetics

#endif
