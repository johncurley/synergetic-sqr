# SPU-13 Bloom View UI (v3.0.27)
# Real-time Phyllotaxis Visualization with Laminar Stabilization.
# Objective: Restore Homeostasis via Frequency Regulation.

import serial
import pygame
import math
import sys
import time

# --- CONFIGURATION ---
SERIAL_PORT = '/dev/tty.usbserial-12345'
BAUD_RATE = 115200
PHI = 137.508 * (math.pi / 180.0)
PURPLE_GLOW = (138, 43, 226) # Dielectric discharge
NEUTRAL_GRAY = (100, 100, 100) # Achromatic base

# --- STABILIZATION CONSTANTS ---
ZETA_BASE = 0.08
STABILIZE_FLAG = "--stabilize" in sys.argv

# --- INITIALIZE UI ---
pygame.init()
WIDTH, HEIGHT = 800, 800
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("SPU-13 Laminar Stabilization UI")
clock = pygame.time.Clock()

class Node:
    def __init__(self, index):
        self.index = index
        self.target_radius = 15 * math.sqrt(index)
        self.current_radius = 0.0
        self.intensity = 0.0

    def update(self, surd_val, zeta):
        # Numerical Flywheel: Weighting the LSBs to smooth jitter
        weighted_val = round(surd_val / 65536.0, 12)
        self.current_radius += (self.target_radius - self.current_radius) * zeta
        self.intensity = min(1.0, abs(weighted_val))

    def render(self, screen, pulse_val, glow_fade):
        theta = self.index * PHI
        forward_lean = self.intensity * pow(0.618, self.index % 13)
        r_sync = self.current_radius * (1.0 + 0.02 * pulse_val)
        
        x = (WIDTH // 2) + r_sync * math.cos(theta) * (1.0 + forward_lean)
        y = (HEIGHT // 2) + r_sync * math.sin(theta) * (1.0 + forward_lean)
        
        # Color Logic: Transition from Grey to Purple based on glow_fade
        base_color = NEUTRAL_GRAY
        target_color = PURPLE_GLOW
        
        current_color = (
            int(base_color[0] + (target_color[0] - base_color[0]) * glow_fade),
            int(base_color[1] + (target_color[1] - base_color[1]) * glow_fade),
            int(base_color[2] + (target_color[2] - base_color[2]) * glow_fade)
        )
        
        pygame.draw.circle(screen, current_color, (int(x), int(y)), 4)

def main():
    print(f"--- SPU-13 Stabilization Active [Mode: {'Silent' if STABILIZE_FLAG else 'Standard'}] ---")
    try:
        ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=0.1)
    except:
        print("Serial Error: Simulation running in virtual mode.")
        ser = None

    nodes = [Node(i) for i in range(500)]
    running = True
    start_time = time.time()
    glow_fade = 0.0 if STABILIZE_FLAG else 1.0

    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT: running = False

        # 1. Laminar Fade: Slowly introduce color if stabilizing
        if STABILIZE_FLAG and glow_fade < 1.0:
            glow_fade += 0.005 # Slow breathing ascent

        current_surd = 65536 # Default Identity
        if ser and ser.in_waiting >= 4:
            current_surd = int.from_bytes(ser.read(4), byteorder='little', signed=True)

        # 2. Resonant Pulse (Heart-Sync)
        elapsed = time.time() - start_time
        pulse_val = math.sin(2.0 * math.pi * 1.024 * elapsed)

        screen.fill((18, 18, 18)) # Deep Space Black
        
        for node in nodes:
            node.update(current_surd, ZETA_BASE)
            node.render(screen, pulse_val, glow_fade)
        
        pygame.display.flip()
        clock.tick(60)

    if ser: ser.close()
    pygame.quit()

if __name__ == "__main__":
    main()
