# SPU-13 Universal Software Bridge (v3.0.8)
# Objective: Connect the Python Golden Core to either Metal or Vulkan backend.

import subprocess
import time
import sys
import platform
import os
from spu13_emulator import GoldenSurd

def main():
    print("--- SPU-13 Universal Bridge Active ---")
    
    # 1. Platform Detection
    system = platform.system()
    binary_path = "./build/synergetic-sqr"
    
    if not os.path.exists(binary_path):
        print(f"Error: {binary_path} not found. Please build the project first.")
        return

    print(f"Detected System: {system} | Backend: {'Metal' if system == 'Darwin' else 'Vulkan'}")

    # 2. Launch the Sovereign Renderer
    try:
        renderer = subprocess.Popen([binary_path, "--forensic"], 
                                   stdin=subprocess.PIPE, text=True)
    except Exception as e:
        print(f"Failed to launch renderer: {e}")
        return

    # 3. Execute the 10-Second Golden Pulse
    phi = GoldenSurd.Phi()
    current_state = GoldenSurd(65536, 0, 0, 0)

    print("Executing 10-Second Safe Pulse...")
    start_time = time.time()
    
    try:
        while time.time() - start_time < 10:
            current_state = current_state.multiply(phi)
            # Universal Bridge: In Stage 2, this feeds the register bus
            print(f"BRIDGE: Isotropic State {current_state.a} -> GPU Clip-Plane", end='\r')
            time.sleep(0.1)
            
    except KeyboardInterrupt:
        pass

    print("\nWATCHDOG: Pulse Complete. Terminating Bridge.")
    renderer.terminate()

if __name__ == "__main__":
    main()
