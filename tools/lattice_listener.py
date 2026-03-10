import serial
import time
import sys
import math
import csv
from datetime import datetime

# SPU-13: The Lattice Listener & Davis Monitor (v1.0)
# Objective: Monitor C=tau/K and record the "Laminar Log".
# Target: Unified SPU-13 Fleet (iCeSugar, ULX3S, Tang Nano).

PORT = "/dev/tty.usbmodem1101" # Default for macOS, adjust as needed
BAUD = 115200

def calculate_davis_ratio(a, b, c, d):
    # K (Curvature) is the peak deviation from the origin (Euclidean approximation)
    k_val = math.sqrt(a**2 + b**2 + c**2 + d**2)
    
    # Tau is the 'Full Cycle' capacity (The Sovereign 2pi equivalent)
    tau_const = 6.283185307
    
    if k_val == 0: 
        return float('inf') # Perfect Identity (No Curvature)
    
    return tau_const / k_val

class LaminarLogger:
    def __init__(self, filename="laminar_log.csv"):
        self.filename = filename
        # Ensure file exists with headers
        try:
            with open(self.filename, 'x', newline='') as f:
                writer = csv.writer(f)
                writer.writerow(["Timestamp", "Object", "A", "B", "C", "D", "Davis Ratio (C)", "Observation"])
        except FileExistsError:
            pass

    def log(self, obj_name, a, b, c, d, c_ratio, note=""):
        with open(self.filename, 'a', newline='') as f:
            writer = csv.writer(f)
            writer.writerow([datetime.now().strftime("%H:%M:%S"), obj_name, a, b, c, d, f"{c_ratio:.6f}", note])

def listen_to_flow(port_override=None, current_rock="Identity"):
    active_port = port_override if port_override else PORT
    logger = LaminarLogger()
    
    try:
        with serial.Serial(active_port, BAUD, timeout=1) as ser:
            print(f"--- SPU-13 Lattice Listener Active on {active_port} ---")
            print(f"Scanning Object: {current_rock}")
            print("Press Ctrl+C to return to the Nothing.\n")
            
            while True:
                # The SPU-13 streams a 64-bit frame: [Fault:1][Unused:31][QA:32]
                # In current bootstrap, we'll look for simple hex strings for ease of use.
                raw_data = ser.readline().decode('ascii', errors='ignore').strip()
                if raw_data:
                    try:
                        # Assuming format: "A:xxxx B:xxxx C:xxxx D:xxxx" or similar
                        # We'll normalize to 16.16 fixed point
                        parts = raw_data.split()
                        # Simple parser for our bootstrap 'SIP' frames
                        # If frame is just QA (32-bit), we'll derive B,C,D for the demo
                        val = int(raw_data, 16)
                        a = (val & 0xFFFFFFFF) / 65536.0
                        b, c, d = 0.0, 0.0, -a # Force A+B+C+D=0 for the monadic sip
                        
                        c_ratio = calculate_davis_ratio(a, b, c, d)
                        
                        status = "RECOVERY" if (val >> 32) & 0x1 else "LAMINAR"
                        
                        print(f"[{status}] A: {a:8.4f} | Davis Ratio (C): {c_ratio:10.6f}")
                        
                        # Auto-log if significant curvature detected
                        if c_ratio < 100.0:
                            logger.log(current_rock, a, b, c, d, c_ratio, status)
                            
                    except ValueError:
                        pass # Ignore malformed sips
                        
    except KeyboardInterrupt:
        print("\n--- Flow Interrupted. Log Sealed. ---")
    except serial.SerialException as e:
        print(f"CRITICAL: Could not open {active_port}. Check connection.")

if __name__ == "__main__":
    p = sys.argv[1] if len(sys.argv) > 1 else None
    rock = sys.argv[2] if len(sys.argv) > 2 else "Identity"
    listen_to_flow(p, rock)
