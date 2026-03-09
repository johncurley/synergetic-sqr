# SPU-13 Laminar Sandbox (v3.4.0)
# Objective: Interactive human-to-manifold resonant coupling.
# Implementation: Dual-domain dashboard with Metabolic Telemetry.

import serial
import time
import sys
import threading

class LaminarSandbox:
    def __init__(self, port, baud=115200):
        self.ser = serial.Serial(port, baud, timeout=0.1)
        self.running = True
        self.stats = {
            "symmetry": 100.0,
            "resonance": 100.0,
            "sip": False,
            "microwatts": 0,
            "last_payload": 0
        }
        print(f"--- SPU-13 Laminar Sandbox: Connected to {port} ---")
        print("Protocol: Standard I/O (Draft 1.1) | Target: Bowman Core")
        print("Commands: Type to strike the manifold. [ESC] to ground.\n")

    def telemetry_loop(self):
        while self.running:
            # Each frame is 8 bytes (64 bits)
            frame_raw = self.ser.read(8)
            if len(frame_raw) == 8:
                frame = int.from_bytes(frame_raw, byteorder='little')
                
                # Unpack Laminar Frame v1.1
                # [Bit 63: Symmetry]
                # [Bits 62-47: Microwatts]
                # [Bits 46-40: Res]
                # [Bits 39-32: Footer]
                # [Bits 31-0: Payload]
                symmetry_ok = (frame >> 63) & 0x1
                microwatts  = (frame >> 47) & 0xFFFF
                footer      = (frame >> 32) & 0xFF
                payload     = (frame & 0xFFFFFFFF)
                
                self.stats["symmetry"] = 100.0 if symmetry_ok else 0.0
                self.stats["microwatts"] = microwatts
                self.stats["sip"] = bool(footer & 0x2)
                self.stats["resonance"] = 100.0 if (footer & 0x1) else 0.0
                self.stats["last_payload"] = payload
                
                self.refresh_dashboard()

    def refresh_dashboard(self):
        sip_status = "SIP" if self.stats["sip"] else "GULP"
        sys.stdout.write(f"\r[SYMM: {self.stats['symmetry']:>5.1f}%] "
                         f"[LOCK: {self.stats['resonance']:>5.1f}%] "
                         f"[PWR: {self.stats['microwatts']:>4d} uW ({sip_status})] "
                         f"[STATE: 0x{self.stats['last_payload']:08X}] ")
        sys.stdout.flush()

    def start(self):
        t = threading.Thread(target=self.telemetry_loop)
        t.daemon = True
        t.start()
        
        try:
            import tty, termios
            fd = sys.stdin.fileno()
            old_settings = termios.tcgetattr(fd)
            try:
                tty.setraw(sys.stdin.fileno())
                while True:
                    char = sys.stdin.read(1)
                    if ord(char) == 27: # ESC
                        break
                    self.ser.write(char.encode('ascii'))
            finally:
                termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
        except ImportError:
            while True:
                line = input()
                self.ser.write(line.encode('ascii'))

    def stop(self):
        self.running = False
        self.ser.close()
        print("\n--- Manifold Grounded. Session Complete. ---")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 laminar_sandbox.py <serial_port>")
        sys.exit(1)
    
    sandbox = LaminarSandbox(sys.argv[1])
    try:
        sandbox.start()
    except KeyboardInterrupt:
        pass
    finally:
        sandbox.stop()
