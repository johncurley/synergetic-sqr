#!/usr/bin/env python3
# SPU-13 Laminar Bridge (v1.0)
# Objective: Proxy standard USB keyboard inputs into L-CLK/L-DAT pulses.
# Vibe: The Neural Proxy.

import sys
import time
import serial
import pygame # Used for raw keyboard capture

# --- QUADRAY MAPPING (Cubic -> 60 deg) ---
KEY_MAP = {
    pygame.K_w: 0x000F, # Apex (A)
    pygame.K_a: 0x00F0, # Base-Left (B)
    pygame.K_d: 0x0F00, # Base-Right (C)
    pygame.K_s: 0xF000, # Center (D)
    pygame.K_SPACE: 0xFFFF # Identity Flush
}

def start_bridge(port):
    print(f"--- SPU-13 Laminar Bridge Active on {port} ---")
    pygame.init()
    screen = pygame.display.set_mode((100, 100))
    pygame.display.set_caption("L-Bridge")
    
    try:
        ser = serial.Serial(port, 115200)
        
        running = True
        while running:
            for event in pygame.event.get():
                if event.type == pygame.QUIT: running = False
                
                if event.type == pygame.KEYDOWN:
                    if event.key in KEY_MAP:
                        vector = KEY_MAP[event.key]
                        # We send as [L-DAT_LOW][L-DAT_HIGH]
                        ser.write(vector.to_bytes(2, byteorder='little'))
                        print(f"[*] Strike: {hex(vector)}")
                        
        ser.close()
    except Exception as e:
        print(f"Error: {e}")
    pygame.quit()

if __name__ == "__main__":
    p = sys.argv[1] if len(sys.argv) > 1 else "/dev/tty.usbmodemXXXX"
    start_bridge(p)
