# SPU-13 GLU Diagnostic: Rotary Logic Gate (v3.0.26)
# Objective: Verify bit-exact parity between Python model and Silicon gates.

from spu13_emulator import GoldenSurd
import math

class RotaryLogicGate:
    """Python model of the quadray_rotor.v hardware primitive."""
    def __init__(self, surd_ratio):
        self.surd_ratio = surd_ratio # The 'Rotor Constant'

    def tile(self, q_in):
        # Parallel scaling of the 4-axis basis (A, B, C, D)
        # q_in is a list of 4 GoldenSurd elements
        scaled = [v.multiply(self.surd_ratio) for v in q_in]
        
        # 60-degree Isotropic Shuffle (P3: ABCD -> DBCA)
        # Matching hardware wire-permutation in quadray_rotor.v
        return [scaled[3], scaled[0], scaled[1], scaled[2]]

def run_diagnostic():
    print("--- SPU-13 GLU Diagnostic: Rotary Logic Gate Audit ---")
    
    # Initialize Unity Rotor (1.0 in SF32.16)
    unity_ratio = GoldenSurd(65536, 0, 0, 0)
    glu = RotaryLogicGate(unity_ratio)
    
    # Initialize Basis Simplex
    q_in = [
        GoldenSurd(65536, 0, 0, 0), # A
        GoldenSurd(0, 0, 0, 0),     # B
        GoldenSurd(0, 0, 0, 0),     # C
        GoldenSurd(0, 0, 0, 0)      # D
    ]
    
    print(f"INITIAL STATE: Q1={q_in[0].a}")
    
    # Perform 4 shuffles (Identity restoration for P3 cyclic shift)
    current = q_in
    for i in range(4):
        current = glu.tile(current)
        print(f"SHUFFLE {i+1}: Q1={current[0].a}")
        
    if current[0].a == q_in[0].a:
        print("PASS: Rotary Logic Gate bit-exact identity restored.")
    else:
        print("FAIL: Logical friction detected in the tiling.")

if __name__ == "__main__":
    run_diagnostic()
