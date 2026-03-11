#!/usr/bin/env python3
# SPU-13 Laminar Audit & Certification (v1.0)
# Objective: Generate a 'Sovereign Birth Certificate' from the manifold log.

import csv
import sys
import os

def generate_certificate(log_file):
    if not os.path.exists(log_file):
        print(f"Error: Log file '{log_file}' not found.")
        return

    leaks = 0
    recoveries = 0
    total_states = 0
    max_k = 0.0
    
    print(f"--- Commencing SPU-13 Integrity Audit: {log_file} ---")
    
    with open(log_file, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            total_states += 1
            a, b, c, d = float(row['A']), float(row['B']), float(row['C']), float(row['D'])
            sum_val = a + b + c + d
            
            # 1. Leak Check (Zero-Sum Invariant)
            if abs(sum_val) > 0.05: # Allowing for fixed-point rounding floor
                leaks += 1
                
            # 2. Recovery Check
            if row['Observation'] == "RECOVERY":
                recoveries += 1
                
            # 3. Peak Tension
            k = float(row['Davis Ratio (C)'])
            if k != float('inf') and k > max_k:
                max_k = k

    # --- Generate Report ---
    leak_rate = (leaks / total_states) * 100 if total_states > 0 else 0
    print("\n--- SOVEREIGN BIRTH CERTIFICATE ---")
    print(f"Manifold Status: {'CRYSTALLINE' if leak_rate == 0 else 'TURBULENT'}")
    print(f"Total Cycles Observed: {total_states}")
    print(f"Leak Rate: {leak_rate:.4f}%")
    print(f"Henosis Interventions: {recoveries}")
    print(f"Laminar Stability Index: {100.0 - leak_rate:.2f}%")
    print("------------------------------------\n")
    
    if leak_rate == 0:
        print("RESULT: LAMINAR PASS. Hardware integrity certified.")
    else:
        print("RESULT: CUBIC FAIL. Check silicon for grounding or logic leaks.")

if __name__ == "__main__":
    log = sys.argv[1] if len(sys.argv) > 1 else "laminar_log.csv"
    generate_certificate(log)
