#ifndef SPU_ASSEMBLER_HPP
#define SPU_ASSEMBLER_HPP

#include <stdint.h>

/**
 * SPU-13 RISC-V Macro-Assembler (v2.7.1)
 * Emits custom-0 opcodes for Isotropic Instruction Dispatch.
 * Aligned with RISC-V Little-Endian R-Type Specification.
 */

namespace Synergetics {
namespace Assembler {

    // RISC-V custom-0 Opcode: 0001011 (0x0B)
    #define SQR_OPCODE 0x0B

    // R-Type packing: | funct7 | rs2 | rs1 | funct3 | rd | opcode |
    static uint32_t encode_sqr(uint8_t funct7, uint8_t rs2, uint8_t rs1, uint8_t funct3, uint8_t rd) {
        return ((uint32_t)funct7 << 25) | 
               ((uint32_t)(rs2 & 0x1F) << 20) | 
               ((uint32_t)(rs1 & 0x1F) << 15) | 
               ((uint32_t)(funct3 & 0x07) << 12) | 
               ((uint32_t)(rd & 0x1F) << 7) | 
               (uint32_t)SQR_OPCODE;
    }

    static inline uint32_t SADD(uint8_t rd, uint8_t rs1, uint8_t rs2) {
        return encode_sqr(0x00, rs2, rs1, 0x00, rd);
    }

    static inline uint32_t SPERM_X4(uint8_t rd, uint8_t rs1, uint8_t phase) {
        return encode_sqr(phase & 0x03, 0, rs1, 0x02, rd);
    }

    static inline uint32_t DAMP(uint8_t rd, uint8_t rs1) {
        return encode_sqr(0x00, 0, rs1, 0x04, rd);
    }

} // namespace Assembler
} // namespace Synergetics

#endif
