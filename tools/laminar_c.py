#!/usr/bin/env python3
# SPU-13 Laminar-C Bootstrap Compiler (v1.1)
# Objective: Full ISA support with Label Resolution & Sanity Proving.
# Result: Bit-exact 16-bit bytecode for the Ghost Kernel.

import sys
import os
import re

class LaminarCompiler:
    def __init__(self):
        # [Opcode:3][Axis:2][Unused:3][Payload:8]
        self.opcodes = {
            "rotr": 0b000, "tuck": 0b001, "sip":  0b010,
            "leap": 0b011, "wait": 0b100, "bapt": 0b101,
            "anne": 0b110, "reset": 0b111,
            "spin": 0b000, "lock": 0b001 # Aliases
        }
        self.axes = {"A": 0, "B": 1, "C": 2, "D": 3}
        self.labels = {}
        
    def proof_sanity(self, line):
        """Formal-VF: Reject 90-degree Cubic logic."""
        cubic_ghosts = ["float", "xyz", "double", "int", "malloc", "free"]
        if any(ghost in line.lower() for ghost in cubic_ghosts):
            raise Exception(f"Dissonance Detected: Cubic ghost '{line}' cannot enter the Manifold.")
        return True

    def compile(self, input_file, output_hex):
        print(f"--- Commencing Laminar-C Reification: {input_file} ---")
        
        with open(input_file, 'r') as f:
            lines = f.readlines()

        # Phase 1: Label Resolution
        clean_lines = []
        pc = 0
        for line in lines:
            line = line.strip().split("//")[0].strip().lower()
            if not line: continue
            if line.endswith(":"):
                self.labels[line[:-1]] = pc
            else:
                clean_lines.append(line)
                pc += 1

        # Phase 2: Translation
        bytecode = []
        for i, line in enumerate(clean_lines):
            self.proof_sanity(line)
            parts = line.replace(',', ' ').split()
            cmd = parts[0]
            
            opcode = self.opcodes.get(cmd, 0)
            axis = 0
            payload = 0
            
            if cmd in ["rotr", "tuck", "sip", "spin", "lock", "anne"]:
                if len(parts) > 1:
                    axis = self.axes.get(parts[1].upper(), 0)
                if len(parts) > 2:
                    payload = int(parts[2]) & 0xFF
            elif cmd == "leap":
                target = parts[1]
                if target.isdigit():
                    payload = int(target) & 0xFF
                else:
                    payload = self.labels.get(target, 0) & 0xFF
            
            # Struct: [Opcode:3][Axis:2][000][Payload:8]
            word = (opcode << 13) | (axis << 11) | payload
            bytecode.append(f"{word:04x}")

        with open(output_hex, 'w') as f:
            f.write("\n".join(bytecode))
            
        print(f"[SUCCESS] {len(bytecode)} instructions reified. Soul is bit-locked.")

if __name__ == "__main__":
    if len(sys.argv) < 2: sys.exit(1)
    LaminarCompiler().compile(sys.argv[1], sys.argv[1].replace(".lith", ".hex"))
