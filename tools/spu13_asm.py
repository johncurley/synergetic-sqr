#!/usr/bin/env python3
# SPU-13 "Laminar" Assembler (v1.1)
# Objective: Convert SAS into bit-exact control words with axis-mapping.
# Encoding: [Opcode:3][Axis/Phase:2][Sign:1][Unused:2]

import sys
import os

class SPUAssembler:
    def __init__(self):
        self.opcodes = {
            "VADD": 0b000, "RROT": 0b001, "FQUD": 0b011,
            "LEAP": 0b100, "SIP":  0b101, "NORM": 0b110, "ANNE": 0b111,
        }
        self.axes = {"QA": 0, "QB": 1, "QC": 2, "QD": 3}
        
    def assemble_line(self, line):
        clean_line = line.split(';')[0].strip().upper()
        if not clean_line: return None
            
        parts = clean_line.replace(',', ' ').split()
        if not parts: return None
            
        mnemonic = parts[0]
        if mnemonic.endswith(':'): return None
        
        if mnemonic not in self.opcodes:
            print(f"Error: Unknown mnemonic '{mnemonic}'")
            return None
            
        opcode = self.opcodes[mnemonic]
        phase = 0
        sign = 0
        
        # Parse Axis or Phase
        if len(parts) > 1:
            target = parts[1]
            if target in self.axes:
                phase = self.axes[target]
            elif target.isdigit():
                phase = int(target) & 0x3
                
        # Parse Sign or Value
        if len(parts) > 2:
            arg = parts[2]
            if arg.endswith('+'): sign = 1
                
        # Encode: [Opcode:3][Phase:2][Sign:1][00]
        control_word = (opcode << 5) | (phase << 3) | (sign << 2)
        return control_word

    def assemble(self, input_file, output_file):
        print(f"--- SPU-13 SAS Assembler v1.1: {input_file} -> {output_file} ---")
        hex_data = []
        with open(input_file, 'r') as f:
            for line in f:
                word = self.assemble_line(line)
                if word is not None: hex_data.append(f"{word:02x}")
        with open(output_file, 'w') as f:
            f.write("\n".join(hex_data))
        print(f"SUCCESS: {len(hex_data)} instructions reified.")

if __name__ == "__main__":
    if len(sys.argv) < 2: sys.exit(1)
    input_sas = sys.argv[1]
    output_hex = sys.argv[2] if len(sys.argv) > 2 else input_sas.replace(".sas", ".hex")
    SPUAssembler().assemble(input_sas, output_hex)
