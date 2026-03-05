# SPU-13 Isotropic Scope (v2.11.8)
# Visualizes the ABCD Vector Trajectory in real-time.
# Objective: Prove Laminar Spiral Flow.

import serial
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import numpy as np

# --- CONFIGURATION ---
SERIAL_PORT = '/dev/tty.usbserial-12345'
BAUD_RATE = 115200

def abcd_to_xyz(a, b, c, d):
    # Thomson Projection
    x = (a - b - c + d) / 2.0
    y = (a - b + c - d) / 2.0
    z = (a + b - c - d) / 2.0
    return x, y, z

def main():
    print("--- SPU-13 Isotropic Scope Active ---")
    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')
    ax.set_title("SPU-13 Vector Trajectory (Laminar Flow)")
    
    path_x, path_y, path_z = [], [], []
    
    try:
        ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=0.1)
        while True:
            raw = ser.read(16) # Read 4x 32-bit ABCD components
            if len(raw) == 16:
                a = int.from_bytes(raw[0:4], 'little', signed=True)
                b = int.from_bytes(raw[4:8], 'little', signed=True)
                c = int.from_bytes(raw[8:12], 'little', signed=True)
                d = int.from_bytes(raw[12:16], 'little', signed=True)
                
                x, y, z = abcd_to_xyz(a, b, c, d)
                path_x.append(x)
                path_y.append(y)
                path_z.append(z)
                
                if len(path_x) > 100: # Keep sliding window
                    path_x.pop(0); path_y.pop(0); path_z.pop(0)
                
                ax.cla()
                ax.plot(path_x, path_y, path_z, color='purple')
                plt.pause(0.01)
                
    except:
        print("Scope Terminated.")

if __name__ == "__main__":
    main()
