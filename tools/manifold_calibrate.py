# SPU-13 Manifold Calibration Utility (v3.3.87)
# Objective: Parse 64-bit Laminar Frames and Verify Resonance Lock.
# Implementation: Integer-only bit-exact auditing.

import serial
import time
import sys

class ManifoldAuditor:
    def __init__(self, port, baud=115200):
        self.ser = serial.Serial(port, baud, timeout=1)
        print(f"--- SPU-13 Manifold Calibration: Listening on {port} ---")

    def run_audit(self, duration=10):
        print("Commencing Full-Frame Resonance Audit...")
        samples = []
        friction_events = 0
        symmetry_failures = 0
        phase_stalls = 0
        
        start_time = time.time()
        
        while (time.time() - start_time) < duration:
            # Each frame is 8 bytes
            frame_raw = self.ser.read(8)
            if len(frame_raw) == 8:
                frame = int.from_bytes(frame_raw, byteorder='little')
                
                # 1. Unpack Laminar Frame
                # [Bit 63: Symmetry][Bits 62-40: Res][Bits 39-32: Footer][Bits 31-0: Payload]
                symmetry_ok = (frame >> 63) & 0x1
                footer      = (frame >> 32) & 0xFF
                payload     = (frame & 0xFFFFFFFF)
                
                # 2. Forensic Checks
                if not symmetry_ok:
                    symmetry_failures += 1
                if not (footer & 0x1): # Coherence bit
                    phase_stalls += 1
                
                if samples and abs(payload - samples[-1]) != 0:
                    friction_events += 1
                
                samples.append(payload)

        total_obs = len(samples)
        
        print("\n--- Manifold Health Report: REIFIED ---")
        print(f"Total Frames Observed: {total_obs}")
        print(f"Symmetry Integrity:    {((total_obs - symmetry_failures) * 100 / total_obs):.2f}%" if total_obs > 0 else "N/A")
        print(f"Phase-Lock Stability:  {((total_obs - phase_stalls) * 100 / total_obs):.2f}%" if total_obs > 0 else "N/A")
        print(f"Laminar Coherence:     {((total_obs - friction_events) * 100 / total_obs):.2f}%" if total_obs > 0 else "N/A")
        
        if symmetry_failures == 0 and phase_stalls == 0 and friction_events == 0:
            print("Status: LAMINAR LOCK ACHIEVED. Manifold is Bit-Perfect.")
        elif symmetry_failures > (total_obs // 10):
            print("Status: TURBULENT. High Cubic Incursion detected.")
        else:
            print("Status: STABILIZING. Minimal torsion observed.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 manifold_calibrate.py <serial_port>")
        sys.exit(1)
    
    auditor = ManifoldAuditor(sys.argv[1])
    auditor.run_audit()
