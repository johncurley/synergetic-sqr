#!/usr/bin/env python3
# SPU-13 Laminar Sandbox (v1.0)
# Objective: Prototype Quadray/IVM math without compiling C++.
# Vibe: The Algebraic Playground.

import math

class Quadray:
    def __init__(self, a=0, b=0, c=0, d=0):
        self.v = [a, b, c, d]

    def simplify(self):
        m = min(self.v)
        return Quadray(*(x - m for x in self.v))

    def to_cartesian(self):
        # A=(0,0,1), B=(sqrt(8/9), 0, -1/3), C=(-sqrt(2/9), sqrt(2/3), -1/3), D=(-sqrt(2/9), -sqrt(2/3), -1/3)
        # Standard projection for verification
        a, b, c, d = self.v
        x = (math.sqrt(8/9) * b) - (math.sqrt(2/9) * c) - (math.sqrt(2/9) * d)
        y = (math.sqrt(2/3) * c) - (math.sqrt(2/3) * d)
        z = a - (1/3 * b) - (1/3 * c) - (1/3 * d)
        return (x, y, z)

    def __repr__(self):
        return f"Quadray{tuple(self.v)}"

def test_resonance():
    print("--- SPU-13 Algebraic Resonance Check ---")
    identity = Quadray(1, 0, 0, 0) # Vector A (Up)
    print(f"Vector A: {identity} -> Cartesian: {identity.to_cartesian()}")
    
    # The Zero-Sum Gasket Check
    gasket = Quadray(1, 1, 1, 1)
    print(f"Gasket {gasket} simplifies to {gasket.simplify()}")

if __name__ == "__main__":
    test_resonance()
