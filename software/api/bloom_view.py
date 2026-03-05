# SPU-13 Bloom View UI (v2.9.34)
# Real-time Phyllotaxis Visualization with Heart-Sync Tuning.
# Requirements: pip install pyserial pygame

import serial
import pygame
import math
import sys

# --- CONFIGURATION ---
SERIAL_PORT = '/dev/tty.usbserial-12345'
BAUD_RATE = 115200
PHI = 137.508 * (math.pi / 180.0)
PURPLE_GLOW = (138, 43, 226)

# --- BIO-SYNC CALIBRATION ---
ZETA = 0.1
RESTING_BPM = 60 # Tune to your heart rate for entrainment
PULSE_FREQ = RESTING_BPM / 60.0 # Frequency in Hz

# --- INITIALIZE UI ---
pygame.init()
WIDTH, HEIGHT = 800, 800
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("SPU-13 Bio-Resonant Telemetry (Heart-Sync)")
clock = pygame.time.Clock()

class Node:
    def __init__(self, index):
        self.index = index
        self.target_radius = 15 * math.sqrt(index)
        self.current_radius = 0.0
        self.intensity = 0.0

    def update(self, surd_val):
        self.current_radius += (self.target_radius - self.current_radius) * ZETA
        self.intensity = min(1.0, abs(surd_val) / 65536.0)

    def render(self, screen, pulse_val):
        theta = self.index * PHI
        forward_lean = self.intensity * pow(0.618, self.index % 13)
        
        # Apply Heart-Sync Pulse to the radial position
        r_sync = self.current_radius * (1.0 + 0.02 * pulse_val)
        
        x = (WIDTH // 2) + r_sync * math.cos(theta) * (1.0 + forward_lean)
        y = (HEIGHT // 2) + r_sync * math.sin(theta) * (1.0 + forward_lean)
        
        node_color = (
            min(255, PURPLE_GLOW[0] + int(64 * self.intensity)),
            min(255, PURPLE_GLOW[1] + int(64 * self.intensity)),
            min(255, PURPLE_GLOW[2] + int(64 * self.intensity))
        )
        pygame.draw.circle(screen, node_color, (int(x), int(y)), 4)

def main():
    print(f"--- SPU-13 Heart-Sync: Entraining to {RESTING_BPM} BPM ---")
    try:
        ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=0.1)
    except:
        print("Serial Error: Check Arty A7 connection.")
        sys.exit(1)

    nodes = [Node(i) for i in range(500)]
    running = True
    start_time = time.time()

    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT: running = False

        # 1. Read Surd (The Machine State)
        current_surd = 0
        if ser.in_waiting >= 4:
            current_surd = int.from_bytes(ser.read(4), byteorder='little', signed=True)

        # 2. Calculate Bio-Pulse (The Human Rhythm)
        elapsed = time.time() - start_time
        pulse_val = math.sin(2.0 * math.pi * PULSE_FREQ * elapsed)

        screen.fill((18, 18, 18))
        
        # 3. Render Resonant Circuit
        for node in nodes:
            node.update(current_surd)
            node.render(screen, pulse_val)
        
        pygame.display.flip()
        clock.tick(60)

    ser.close()
    pygame.quit()

import time
if __name__ == "__main__":
    main()
