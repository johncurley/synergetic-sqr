# SurdLang MVS Interpreter (v2.11.0)
# Requirements: pip install sympy

from sympy import sqrt, Rational, simplify, expand
import sys

class Surd:
    def __init__(self, expr):
        self.expr = simplify(expr)
    def __add__(self, other): return Surd(self.expr + other.expr)
    def __mul__(self, other): return Surd(expand(self.expr * other.expr))
    def __repr__(self): return str(self.expr)

class SurdLang:
    def __init__(self):
        self.vars = {}
        self.phi = Surd((1 + sqrt(5))/2)
        self.psi = Surd((1 - sqrt(5))/2)

    def execute(self, line):
        parts = line.split()
        if not parts: return
        
        if parts[0] == "let":
            name = parts[1]
            # Simple scalar assignment simulation
            if "sqrt" in line:
                val = line.split("=")[1].strip()
                self.vars[name] = val
            print(f"IDENTITY: {name} assigned to {self.vars[name]}")

        elif parts[0] == "rotate":
            vec_name = parts[1]
            print(f"SHUFFLE: Rotating {vec_name} by Prime-Phase P3")

        elif parts[0] == "bloom":
            target = parts[1]
            print(f"EMANATION: Sending {target} to Phyllotaxis UI")

def main():
    print("--- SurdLang MVS Interpreter Active ---")
    interpreter = SurdLang()
    
    # Simple Bootstrap Program
    program = [
        "let phi = (1 + sqrt(5)) / 2",
        "let v = [1, 0, 0, 0]",
        "rotate v",
        "bloom v"
    ]

    for line in program:
        interpreter.execute(line)

if __name__ == "__main__":
    main()
