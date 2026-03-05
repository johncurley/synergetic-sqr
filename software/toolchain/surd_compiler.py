# SPU-13 Isotropic Compiler (v2.11.1)
# Translates SurdLang (.surd) to SQR-ASIC Machine Code.

import sys

# RISC-V custom-0 Opcode: 0001011 (0x0B)
SQR_OPCODE = 0x0B

def encode_r_type(funct7, rs2, rs1, funct3, rd):
    return (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | SQR_OPCODE

class SurdCompiler:
    def __init__(self):
        self.registers = {'v': 1, 'phi': 2, 'psi': 3} # Virtual register map

    def compile_line(self, line):
        parts = line.split()
        if not parts: return None
        
        if parts[0] == "rotate":
            # Map 'rotate v' to SPERM_X4(rd=1, rs1=1, phase=P3)
            # funct3: 010, funct7: 0000001
            return encode_r_type(0x01, 0, 1, 0x02, 1)
            
        elif parts[0] == "damp":
            # Map 'damp v' to OP_DAMP(rd=1, rs1=1)
            # funct3: 100, funct7: 0000000
            return encode_r_type(0x00, 0, 1, 0x04, 1)
            
        elif parts[0] == "bloom":
            # Map 'bloom v' to HENOSIS opcode (0x05)
            return 0x0000_0005
            
        return None

def main():
    print("--- SPU-13 Isotropic Compiler v2.11.1 ---")
    compiler = SurdCompiler()
    
    source_program = [
        "rotate v",
        "damp v",
        "bloom v"
    ]

    print("Compiling SurdLang to Machine Code...")
    for line in source_program:
        binary = compiler.compile_line(line)
        if binary:
            print(f"SOURCE: {line:10} -> BIN: 0x{binary:08X}")

if __name__ == "__main__":
    main()
