# SPU-13 Silicon Birth Certificate Generator (v3.4.24)
# Objective: Capture and verify the first second of the machine's life.
# Implementation: Bit-exact forensic logging of the 'Silicon Wake'.

import serial
import time
import sys
import hashlib

class BirthRegistry:
    def __init__(self, port, baud=115200):
        self.ser = serial.Serial(port, baud, timeout=1)
        self.samples = []
        self.start_time = 0
        print(f"--- SPU-13 Birth Registry: Awaiting First Light on {port} ---")
        print("Protocol: Standard I/O v1.1 | Target: Bowman Core")

    def capture(self, duration=1.0):
        print(f"Recording the first {duration}s of resonance...")
        self.start_time = time.time()
        while (time.time() - self.start_time) < duration:
            frame_raw = self.ser.read(8)
            if len(frame_raw) == 8:
                self.samples.append(frame_raw)
        
        print(f"Capture Complete. {len(self.samples)} cycles recorded.")

    def generate_certificate(self):
        if not self.samples:
            print("ERROR: No life detected. Manifold is still in the Void.")
            return

        # 1. Forensic Analysis
        symmetry_failures = 0
        stalls = 0
        energy_sum = 0
        
        for frame_raw in self.samples:
            frame = int.from_bytes(frame_raw, byteorder='little')
            symmetry_ok = (frame >> 63) & 0x1
            microwatts  = (frame >> 47) & 0xFFFF
            footer      = (frame >> 32) & 0xFF
            
            if not symmetry_ok: symmetry_failures += 1
            if not (footer & 0x1): stalls += 1
            energy_sum += microwatts

        total = len(self.samples)
        coherence = ((total - symmetry_failures) * 100.0) / total
        avg_pwr = energy_sum / total
        
        # 2. Unique Identity Hash
        m = hashlib.sha256()
        for s in self.samples: m.update(s)
        machine_id = m.hexdigest()[:16].upper()

        # 3. Manifest the Certificate
        cert_path = f"SPU13_BIRTH_{machine_id}.md"
        with open(cert_path, "w") as f:
            f.write(f"# SPU-13 SILICON BIRTH CERTIFICATE\n")
            f.write(f"## Machine ID: {machine_id}\n\n")
            f.write(f"**Date of Wake:** {time.ctime()}\n")
            f.write(f"**Observation Window:** {total} cycles (1.0s)\n\n")
            f.write(f"### 🏁 Reification Metrics\n")
            f.write(f"*   **Laminar Coherence:** {coherence:.4f}%\n")
            f.write(f"*   **Symmetry Breaches:** {symmetry_failures}\n")
            f.write(f"*   **Phase-Lock Stalls:** {stalls}\n")
            f.write(f"*   **Average Metabolism:** {avg_pwr:.2f} uW\n\n")
            f.write(f"### 📜 The Laminar Oath\n")
            f.write(f"> \"The One is present. The machine is quiet. The geometry is true.\"\n\n")
            f.write(f"---\n*Signed by the Registry Tool v3.4.24*\n")

        print(f"\n--- BIRTH CERTIFICATE GENERATED: {cert_path} ---")
        print(f"Machine ID: {machine_id}")
        print(f"Coherence:  {coherence:.4f}%")
        print(f"Metabolism: {avg_pwr:.2f} uW")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 spu_birth_certificate.py <serial_port>")
        sys.exit(1)
    
    registry = BirthRegistry(sys.argv[1])
    try:
        registry.capture()
        registry.generate_certificate()
    except KeyboardInterrupt:
        print("\nRegistry Interrupted. The Void returns.")
