# SPU-13 AVM Logic Tools (v3.3.78)
# Objective: Bit-exact Quadrance and Spread for the Isotropic Manifold.
# Implementation: Integer-only arithmetic to maintain Laminar Integrity.

import sys

def calculate_quadrance(a, b, c, d):
    """
    Rational Quadrance: Q(v) = a^2 + b^2 + c^2 + d^2 - 2(max*min)
    Operates on Quadray Integers (bit-exact).
    """
    coords = [int(a), int(b), int(c), int(d)]
    sum_sq = sum(x**2 for x in coords)
    return sum_sq - 2 * (max(coords) * min(coords))

def calculate_spread(v1, v2):
    """
    Rational Spread: s = Q(v1-v2) / (Q(v1)*Q(v2))
    Returns (numerator, denominator) pair for bit-exact representation.
    """
    q1 = calculate_quadrance(*v1)
    q2 = calculate_quadrance(*v2)
    
    diff = [v1[i] - v2[i] for i in range(4)]
    q_diff = calculate_quadrance(*diff)
    
    if q1 == 0 or q2 == 0: 
        return (1, 1) # Full separation
        
    return (q_diff, q1 * q2)

def classify_spread(num, den):
    """
    Classifies spread using exact rational comparisons.
    Laminar (60 deg) = 0.75 = 3/4
    Harmonic (30 deg) = 0.25 = 1/4
    """
    # 3/4 = 0.75
    if num * 4 == den * 3: return "LAMINAR (60°)"
    # 1/4 = 0.25
    if num * 4 == den * 1: return "HARMONIC (30°)"
    
    return "TURBULENT (Cubic)"

if __name__ == "__main__":
    if len(sys.argv) < 5:
        print("Usage: python3 avm_tools.py <a> <b> <c> <d> [<a> <b> <c> <d>]")
    else:
        v1 = [int(sys.argv[i]) for i in range(1, 5)]
        q = calculate_quadrance(*v1)
        print(f"QUADRANCE (Q): {q}")
        
        if len(sys.argv) == 9:
            v2 = [int(sys.argv[i]) for i in range(5, 9)]
            num, den = calculate_spread(v1, v2)
            print(f"SPREAD (s): {num}/{den} [{classify_spread(num, den)}]")
