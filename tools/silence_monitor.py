import serial
import time
import math
import sys

# SPU-13 Silence Monitor (v3.1)
# Objective: Verify the "Black Background" by monitoring bitstream jitter.
# Target: 61.44 kHz Resonant Clock

def analyze_silence(port, baudrate=115200, duration=10):
    try:
        ser = serial.Serial(port, baudrate, timeout=1)
        print(f"--- Listening for Laminar Silence on {port} ---")
        print("Monitoring for non-harmonic jitter deviations...")
        
        start_time = time.time()
        samples = []
        
        while (time.time() - start_time) < duration:
            line = ser.readline().decode('utf-8').strip()
            if line:
                try:
                    # Expecting hex values representing rotor state
                    val = int(line, 16)
                    samples.append(val)
                except ValueError:
                    pass # Ignore non-data lines
        
        ser.close()
        
        if not samples:
            print("No signal detected. The Silence is absolute (or connection failed).")
            return

        # Calculate Jitter / Deviation from Expected Harmonic
        # In a perfect Null Hysteresis state, deviations should be zero.
        deltas = [abs(samples[i] - samples[i-1]) for i in range(1, len(samples))]
        avg_delta = sum(deltas) / len(deltas) if deltas else 0
        
        print(f"\n--- Audit Results ---")
        print(f"Total Samples: {len(samples)}")
        print(f"Average Delta (Noise Floor): {avg_delta:.6f}")
        
        if avg_delta < 1.0:
            print("Status: LAMINAR SILENCE CONFIRMED. Null Hysteresis Active.")
        else:
            print("Status: TURBULENCE DETECTED. Check geometric constraints.")

    except serial.SerialException as e:
        print(f"Error connecting to board: {e}")
        print("Ensure iCeSugar is connected via USB-C.")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 silence_monitor.py <serial_port>")
        sys.exit(1)
    
    port = sys.argv[1]
    analyze_silence(port)
