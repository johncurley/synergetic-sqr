# SPU-13 Laminar Sandbox (v3.3.93)
# Objective: Interactive human-to-manifold resonant coupling.
# Implementation: Dual-domain dashboard for strikes and telemetry.

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
            "pressure": 0,
            "last_payload": 0
        }
        print(f"--- SPU-13 Laminar Sandbox: Connected to {port} ---")
        print("Protocol: Standard I/O (Draft 1.0) | Target: Bowman Core")
        print("Commands: Type to strike the manifold. [ESC] to ground.\n")

    def telemetry_loop(self):
        while self.running:
            # Each frame is 8 bytes (64 bits)
            frame_raw = self.ser.read(8)
            if len(frame_raw) == 8:
                frame = int.from_bytes(frame_raw, byteorder='little')
                
                # Unpack Laminar Frame
                symmetry_ok = (frame >> 63) & 0x1
                footer      = (frame >> 32) & 0xFF
                payload     = (frame & 0xFFFFFFFF)
                
                self.stats["symmetry"] = 100.0 if symmetry_ok else 0.0
                self.stats["resonance"] = 100.0 if (footer & 0x1) else 0.0
                self.stats["last_payload"] = payload
                
                # Update dashboard
                self.refresh_dashboard()

    def refresh_dashboard(self):
        sys.stdout.write(f"\r[SYMMETRY: {self.stats['symmetry']:>5.1f}%] "
                         f"[LOCK: {self.stats['resonance']:>5.1f}%] "
                         f"[STATE: 0x{self.stats['last_payload']:08X}] "
                         f"Strike to Resonate... ")
        sys.stdout.flush()

    def start(self):
        # Start telemetry thread
        t = threading.Thread(target=self.telemetry_loop)
        t.daemon = True
        t.start()
        
        # Main interaction loop
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
                    # Send strike to FPGA
                    self.ser.write(char.encode('ascii'))
                    self.refresh_dashboard()
            finally:
                termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
        except ImportError:
            # Fallback for systems without tty support
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
