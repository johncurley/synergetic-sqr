# SPU-13 AVM Logic Tools (v3.1.21)
# Objective: Automate Quadrance and Spread calculations for AVM-Alpha.

import sys

def calculate_quadrance(a, b, c, d):
    """Q(v) = a^2 + b^2 + c^2 + d^2 - 2(max*min)"""
    coords = [a, b, c, d]
    return (a**2 + b**2 + c**2 + d**2) - 2 * (max(coords) * min(coords))

def calculate_spread(v1, v2):
    """s = Q(v1-v2) / (Q(v1)*Q(v2))"""
    q1 = calculate_quadrance(*v1)
    q2 = calculate_quadrance(*v2)
    diff = [v1[i] - v2[i] for i in range(4)]
    q_diff = calculate_quadrance(*diff)
    if q1 == 0 or q2 == 0: return 1.0
    return q_diff / (q1 * q2)

def classify_spread(s):
    if abs(s - 0.75) < 0.1: return "laminar"
    if abs(s - 0.25) < 0.1: return "harmonic"
    return "danger"

if __name__ == "__main__":
    if len(sys.argv) < 5:
        print("Usage: python3 avm_tools.py <a> <b> <c> <d>")
    else:
        a, b, c, d = map(float, sys.argv[1:5])
        q = calculate_quadrance(a, b, c, d)
        print(f"QUADRANCE (Q): {q:.4f}")
        # Example identity check
        if len(sys.argv) == 9:
            v2 = map(float, sys.argv[5:9])
            s = calculate_spread([a,b,c,d], list(v2))
            print(f"SPREAD (s): {s:.4f} [{classify_spread(s)}]")
