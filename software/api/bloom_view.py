# SPU-13 Bloom View UI (v2.11.2)
# Real-time Phyllotaxis Visualization with Stability Anchor.
# Requirements: pip install pyserial pygame

import serial
import pygame
import math
import sys
import time

# --- CONFIGURATION ---
SERIAL_PORT = '/dev/tty.usbserial-12345'
BAUD_RATE = 115200
PHI = 137.508 * (math.pi / 180.0)
PURPLE_GLOW = (138, 43, 226)

# --- COHERENCE CONSTANTS ---
ZETA_BASE = 0.08
RESTING_BPM = 61 # Aligned to 1.024 Hz sub-harmonic
PULSE_FREQ = 1.024

# --- INITIALIZE UI ---
pygame.init()
WIDTH, HEIGHT = 800, 800
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("SPU-13 Temporal Coherence Visualizer")
clock = pygame.time.Clock()

class Node:
    def __init__(self, index):
        self.index = index
        self.target_radius = 15 * math.sqrt(index)
        self.current_radius = 0.0
        self.intensity = 0.0

    def update(self, surd_val, zeta):
        self.current_radius += (self.target_radius - self.current_radius) * zeta
        self.intensity = min(1.0, abs(surd_val) / 65536.0)

    def render(self, screen, pulse_val):
        theta = self.index * PHI
        forward_lean = self.intensity * pow(0.618, self.index % 13)
        r_sync = self.current_radius * (1.0 + 0.02 * pulse_val)
        x = (WIDTH // 2) + r_sync * math.cos(theta) * (1.0 + forward_lean)
        y = (HEIGHT // 2) + r_sync * math.sin(theta) * (1.0 + forward_lean)
        pygame.draw.circle(screen, PURPLE_GLOW, (int(x), int(y)), 4)

def main():
    print(f"--- SPU-13 Stability Anchor: Active ---")
    try:
        ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=0.1)
    except:
        print("Serial Error: Check Arty A7 connection.")
        sys.exit(1)

    nodes = [Node(i) for i in range(500)]
    running = True
    start_time = time.time()
    last_loop_time = time.time()
    current_zeta = ZETA_BASE

    while running:
        # 1. Jitter Detection (The Stability Anchor)
        current_time = time.time()
        loop_duration = current_time - last_loop_time
        last_loop_time = current_time
        
        # If processing jitter is high, increase damping to help re-center
        if loop_duration > 0.02: # Threshold for 'Cubic Jitter'
            current_zeta = max(0.02, current_zeta - 0.01) # Slow down
        else:
            current_zeta = min(ZETA_BASE, current_zeta + 0.005) # Return to base

        for event in pygame.event.get():
            if event.type == pygame.QUIT: running = False

        current_surd = 0
        if ser.in_waiting >= 4:
            current_surd = int.from_bytes(ser.read(4), byteorder='little', signed=True)

        elapsed = time.time() - start_time
        pulse_val = math.sin(2.0 * math.pi * PULSE_FREQ * elapsed)

        screen.fill((18, 18, 18))
        for node in nodes:
            node.update(current_surd, current_zeta)
            node.render(screen, pulse_val)
        
        pygame.display.flip()
        clock.tick(60)

    ser.close()
    pygame.quit()

if __name__ == "__main__":
    main()
