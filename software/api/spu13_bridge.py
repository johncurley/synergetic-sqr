# SPU-13 Software Bridge (v3.0.7)
# Objective: Connect the Python Golden Core Emulator to the Metal Renderer.

import subprocess
import time
import math
from spu13_emulator import GoldenSurd

def main():
    print("--- SPU-13 Software Bridge: Joining Mind and Eye ---")
    
    # 1. Initialize the Metal Renderer in a subprocess
    # We use the --forensic flag to allow external register control
    try:
        renderer = subprocess.Popen(["./build/synergetic-sqr", "--forensic"], 
                                   stdin=subprocess.PIPE, text=True)
    except FileNotFoundError:
        print("Error: Metal renderer binary not found in ./build/")
        return

    # 2. Initialize the Golden Core (The Mind)
    phi = GoldenSurd.Phi()
    current_state = GoldenSurd(65536, 0, 0, 0) # SF32.16 'One'

    print("Executing 10-Second Golden Pulse...")
    start_time = time.time()
    
    try:
        while time.time() - start_time < 10:
            # Aperiodic Growth Step
            current_state = current_state.multiply(phi)
            
            # Bridge to Metal: Send the Surd component 'a' to the renderer
            # For this prototype, we simulate the interaction via console log
            # In Stage 2, we use shared memory / sockets for zero-latency.
            print(f"BRIDGE: State {current_state.a} -> Metal Clip-Plane", end='')
            
            time.sleep(0.1) # 10 Hz Bridge Sync
            
    except KeyboardInterrupt:
        pass

    print("
WATCHDOG: Pulse Complete. Terminating Bridge.")
    renderer.terminate()

if __name__ == "__main__":
    main()
