# SPU-13 Bloom View UI (v2.9.26)
# Real-time Phyllotaxis Visualization via UART Telemetry.

import serial
import math
import time

# --- CONFIGURATION ---
SERIAL_PORT = '/dev/tty.usbserial-12345' # Update for your Arty A7
BAUD_RATE = 115200
GOLDEN_ANGLE = 137.5077 * (math.pi / 180.0)

def render_node(n, data_val):
    # Geometric Foundation: Phyllotaxis
    theta = n * GOLDEN_ANGLE
    r = 10 * math.sqrt(n)
    
    # Forward Lean (Z-axis derived from data intensity)
    forward_lean = (data_val / 65536.0) * pow(0.618, n)
    
    x = r * math.cos(theta) * (1.0 + forward_lean)
    y = r * math.sin(theta) * (1.0 + forward_lean)
    
    return x, y

def main():
    print("--- SPU-13 Bloom View: Listening for Isotropic Telemetry ---")
    try:
        ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1)
        
        while True:
            # Read 4-byte Surd component (32-bit little endian)
            raw_data = ser.read(4)
            if len(raw_data) == 4:
                val = int.from_bytes(raw_data, byteorder='little', signed=True)
                
                # Render the 13-node spiral
                for n in range(1, 14):
                    x, y = render_node(n, val)
                    # For terminal demo, we just print the coordinates
                    # In a full GUI, this would update the GL canvas
                    print(f"Node {n:02d}: ({x:0.2f}, {y:0.2f}) | Resonant Glow Active")
                
                time.sleep(0.1)
                
    except serial.SerialException:
        print("Error: Could not open serial port. Is the Arty A7 connected?")

if __name__ == "__main__":
    main()
