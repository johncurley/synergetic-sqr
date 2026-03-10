#!/usr/bin/env python3
# SPU-13 "Laminar" Assembler (v1.0)
# Objective: Convert SAS (SPU Assembly Syntax) into bit-exact control words.
# Encoding: [Opcode:3][Phase:2][Sign:1][Unused:2]

import sys
import os

class SPUAssembler:
    def __init__(self):
        self.opcodes = {
            "VADD": 0b000, # Snap/Add
            "RROT": 0b001, # Spread Rotor
            "FQUD": 0b011, # Quadrance Audit
            "LEAP": 0b100, # G-RAM Access
            "SIP":  0b101, # Fluid/UART Stream
            "NORM": 0b110, # 13-Lane Rebalance
            "ANNE": 0b111, # Anneal Field
        }
        
    def assemble_line(self, line):
        # Remove comments and whitespace
        clean_line = line.split(';')[0].strip().upper()
        if not clean_line:
            return None
            
        parts = clean_line.replace(',', ' ').split()
        if not parts:
            return None
            
        mnemonic = parts[0]
        if mnemonic.endswith(':'):
            return None
        
        if mnemonic not in self.opcodes:
            print(f"Error: Unknown mnemonic '{mnemonic}'")
            return None
            
        opcode = self.opcodes[mnemonic]
        phase = 0
        sign = 0
        
        # Simple Phase/Sign parsing from arguments
        # Example: RROT QA, 2+  => Opcode 1, Phase 2, Sign 1 (Flip)
        if len(parts) > 2:
            arg = parts[2]
            if arg.isdigit():
                phase = int(arg) & 0x3
            if arg.endswith('+'):
                sign = 1
                phase = int(arg[:-1]) & 0x3
                
        # Encode: [Opcode:3][Phase:2][Sign:1][00]
        control_word = (opcode << 5) | (phase << 3) | (sign << 2)
        return control_word

    def assemble(self, input_file, output_file):
        print(f"--- SPU-13 SAS Assembler: {input_file} -> {output_file} ---")
        hex_data = []
        
        with open(input_file, 'r') as f:
            for line_num, line in enumerate(f, 1):
                word = self.assemble_line(line)
                if word is not None:
                    hex_data.append(f"{word:02x}")
                    
        with open(output_file, 'w') as f:
            f.write("\n".join(hex_data))
            
        print(f"SUCCESS: {len(hex_data)} instructions reified.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 spu13_asm.py <input.sas> [output.hex]")
        sys.exit(1)
        
    input_sas = sys.argv[1]
    output_hex = sys.argv[2] if len(sys.argv) > 2 else input_sas.replace(".sas", ".hex")
    
    asm = SPUAssembler()
    asm.assemble(input_sas, output_hex)
