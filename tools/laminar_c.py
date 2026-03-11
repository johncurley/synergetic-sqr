#!/usr/bin/env python3
# SPU-13 Laminar-C Bootstrap Compiler (v1.0)
# Objective: Translate Lithic-L (Geometric Logic) into SPU-13 ISA.
# Vibe: The Architect of Sanity.

import sys
import os

class LaminarCompiler:
    def __init__(self):
        self.opcodes = {
            "spin": 0b000, "lock": 0b001, "sip":  0b010,
            "leap": 0b011, "wait": 0b100, "bapt": 0b101,
            "anne": 0b110, "reset": 0b111
        }
        self.axes = {"A": 0, "B": 1, "C": 2, "D": 3}
        
    def compile_line(self, line):
        line = line.strip().lower()
        if not line or line.startswith("//"): return None
        
        parts = line.split()
        cmd = parts[0]
        
        if cmd not in self.opcodes:
            print(f"Error: Unknown command '{cmd}'")
            return None
            
        opcode = self.opcodes[cmd]
        axis = 0
        payload = 0
        
        # Simple Logic Mapping
        if cmd in ["spin", "lock", "sip"]:
            if len(parts) > 1:
                axis_name = parts[1].upper()
                axis = self.axes.get(axis_name, 0)
            if len(parts) > 2:
                # Convert degrees or values to 8-bit payload
                payload = int(parts[2]) & 0xFF
                
        # Word Structure: [Opcode:3][Axis:2][Unused:3][Payload:8]
        word = (opcode << 13) | (axis << 11) | payload
        return word

    def process(self, input_file, output_hex):
        print(f"--- Commencing Laminar-C Bootstrap: {input_file} ---")
        words = []
        with open(input_file, 'r') as f:
            for line in f:
                word = self.compile_line(line)
                if word is not None: words.append(f"{word:04x}")
        
        with open(output_hex, 'w') as f:
            f.write("\n".join(words))
        print(f"[SUCCESS] {len(words)} Lithic words reified.")

if __name__ == "__main__":
    if len(sys.argv) < 2: sys.exit(1)
    LaminarCompiler().process(sys.argv[1], sys.argv[1].replace(".lith", ".hex"))
