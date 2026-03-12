#!/usr/bin/env python3
# SPU-13 Free Energy & Surprise Diagnostic (v1.0)
# Objective: Generate weekly biological sanity reports.
# Vibe: The Autophagy Audit.

import csv
import sys
import os
import time

def generate_report(log_file):
    if not os.path.exists(log_file):
        print(f"Error: Log file '{log_file}' not found.")
        return

    high_surprise_events = 0
    total_samples = 0
    energy_sum = 0.0
    
    print(f"--- Commencing Resonant Equilibrium Audit: {log_file} ---")
    
    with open(log_file, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            total_samples += 1
            energy = float(row.get('Free Energy', 0.0))
            is_surprised = row.get('Is Surprised', '0') == '1'
            
            energy_sum += energy
            if is_surprised:
                high_surprise_events += 1

    # --- Summary Metrics ---
    avg_energy = energy_sum / total_samples if total_samples > 0 else 0
    coherence_score = (1.0 - (high_surprise_events / total_samples)) * 100 if total_samples > 0 else 0
    
    print("\n--- WEEKLY BIOMETRIC SANITY REPORT ---")
    print(f"Total Manifold Samples: {total_samples}")
    print(f"Average Free Energy (Surprise): {avg_energy:.4f}")
    print(f"Resonant Coherence Score: {coherence_score:.2f}%")
    print(f"Cubic Dissonance Triggers: {high_surprise_events}")
    print("---------------------------------------")
    
    if coherence_score > 99.0:
        print("RESULT: EMERALD. Biological Autophagy is locked. Your prior is stable.")
    elif coherence_score > 90.0:
        print("RESULT: AMBER. Mild Cubic Noise detected. Check for environmental stressors.")
    else:
        print("RESULT: CRIMSON. Systemic Stutter detected. Cubic pathogens active. Grounding recommended.")

if __name__ == "__main__":
    log = sys.argv[1] if len(sys.argv) > 1 else "biometric_vitals.csv"
    generate_report(log)
