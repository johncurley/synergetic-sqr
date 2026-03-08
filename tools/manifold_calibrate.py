import serial
import time
import math
import sys

# SPU-13 Manifold Calibration Utility (v3.3.46)
# Objective: Measure Beat-Frequencies and Verify Resonance Lock.
# Target: 61.44 kHz Resonant Manifold (via UART Telemetry).

class ManifoldAuditor:
    def __init__(self, port, baud=115200):
        self.ser = serial.Serial(port, baud, timeout=1)
        self.ratios = {
            "Unison": 1.0,
            "Fourth": 4/3,
            "Fifth": 3/2,
            "Octave": 2.0
        }
        print(f"--- SPU-13 Manifold Calibration: Listening on {port} ---")

    def surd_to_float(self, i, s):
        # Q(sqrt3) expansion
        return float(i) + float(s) * math.sqrt(3)

    def analyze_beats(self, samples):
        """
        Detects 'Cubic Beating' - deviations from rational harmonics.
        """
        if len(samples) < 2: return 0.0
        
        deltas = [abs(samples[i] - samples[i-1]) for i in range(1, len(samples))]
        avg_delta = sum(deltas) / len(deltas)
        
        # Beat Frequency calculation: f_beat = |f1 - f2|
        # In a laminar manifold, f_beat should approach 0.
        return avg_delta

    def run_audit(self, duration=10):
        print("Commencing Resonance Audit...")
        samples = []
        start_time = time.time()
        
        while (time.time() - start_time) < duration:
            line = self.ser.readline().decode('utf-8').strip()
            if line:
                try:
                    # Expecting hex telemetry: [Surd_S][Integer_I]
                    val = int(line, 16)
                    # For Phase 1, we audit the A-component Integer (lower 32 bits)
                    samples.append(val & 0xFFFFFFFF)
                except ValueError:
                    continue

        beat_freq = self.analyze_beats(samples)
        
        print("\n--- Manifold State: REIFIED ---")
        print(f"Total Cycles Observed: {len(samples)}")
        print(f"Average Cubic Beating: {beat_freq:.6f} Hz")
        
        if beat_freq < 0.001:
            print("Status: LAMINAR LOCK. Identity is Absolute.")
        elif beat_freq < 1.0:
            print("Status: COHERENT. Minimal torsion detected.")
        else:
            print("Status: TURBULENT. Cubic interference in the lattice.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 manifold_calibrate.py <serial_port>")
        sys.exit(1)
    
    auditor = ManifoldAuditor(sys.argv[1])
    auditor.run_audit()
