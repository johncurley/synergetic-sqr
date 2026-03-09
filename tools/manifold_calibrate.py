# SPU-13 Manifold Calibration Utility (v3.3.78)
# Objective: Measure Beat-Frequencies and Verify Resonance Lock.
# Implementation: Integer-only rational comparison for bit-exact auditing.

import serial
import time
import sys

class ManifoldAuditor:
    def __init__(self, port, baud=115200):
        self.ser = serial.Serial(port, baud, timeout=1)
        print(f"--- SPU-13 Manifold Calibration: Listening on {port} ---")

    def analyze_beats(self, samples):
        """
        Detects 'Cubic Beating' via integer deltas.
        In a bit-exact manifold, identity-restored deltas must be ZERO.
        """
        if len(samples) < 2: return 0
        
        # We track 'Non-Zero Deltas' as indicators of Cubic Friction
        friction_events = 0
        for i in range(1, len(samples)):
            delta = abs(samples[i] - samples[i-1])
            if delta != 0:
                friction_events += 1
        
        return friction_events

    def run_audit(self, duration=10):
        print("Commencing Bit-Exact Resonance Audit...")
        samples = []
        start_time = time.time()
        
        while (time.time() - start_time) < duration:
            line = self.ser.readline().decode('utf-8').strip()
            if line:
                try:
                    # Expecting hex telemetry
                    val = int(line, 16)
                    # For Phase 1, we audit the A-component Integer (lower 32 bits)
                    samples.append(val & 0xFFFFFFFF)
                except ValueError:
                    continue

        friction_events = self.analyze_beats(samples)
        total_obs = len(samples)
        
        print("\n--- Manifold State: REIFIED ---")
        print(f"Total Cycles Observed: {total_obs}")
        print(f"Friction Events:       {friction_events}")
        
        if total_obs > 0:
            coherence_idx = ((total_obs - friction_events) * 10000) // total_obs
            print(f"Laminar Coherence:     {coherence_idx // 100}.{coherence_idx % 100:02d}%")
        
        if friction_events == 0:
            print("Status: LAMINAR LOCK. Identity is Absolute.")
        elif friction_events < (total_obs // 100):
            print("Status: COHERENT. Minimal torsion detected.")
        else:
            print("Status: TURBULENT. Cubic interference in the lattice.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 manifold_calibrate.py <serial_port>")
        sys.exit(1)
    
    auditor = ManifoldAuditor(sys.argv[1])
    auditor.run_audit()
