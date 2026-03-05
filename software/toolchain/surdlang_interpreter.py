# SurdLang MVS Interpreter (v2.11.13)
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
        # Remove comments
        line = line.split("--")[0].strip()
        if not line: return
        
        parts = line.split()
        if parts[0] == "let":
            name = parts[1]
            if "sqrt" in line:
                val_expr = line.split("=")[1].strip()
                # Use SymPy to evaluate the string expression
                self.vars[name] = Surd(eval(val_expr.replace('sqrt', 'sqrt')))
            print(f"IDENTITY: {name} = {self.vars.get(name)}")

        elif parts[0] == "growth":
            target = parts[1]
            factor = self.vars.get(parts[2], self.phi)
            print(f"EXPANSION: Unfolding {target} via {factor}")

        elif parts[0] == "damp":
            target = parts[1]
            factor = self.vars.get(parts[2], self.psi)
            print(f"CONTRACTION: Folding {target} via {factor}")

        elif parts[0] == "bloom":
            target = parts[1]
            print(f"HENOSIS: {target} emanated to Phyllotaxis UI")

def main():
    print("--- SPU-13 Aperiodic Growth Emulator Active ---")
    interpreter = SurdLang()
    
    # Path to the .surd file
    if len(sys.argv) > 1:
        with open(sys.argv[1], 'r') as f:
            for line in f:
                interpreter.execute(line)
    else:
        print("Usage: python surdlang_interpreter.py <source.surd>")

if __name__ == "__main__":
    main()
