# SPU-13 Bloom View UI (v2.9.28)
# Real-time Phyllotaxis Visualization with Laminar Damping.
# Requirements: pip install pyserial pygame

import serial
import pygame
import math
import sys

# --- CONFIGURATION ---
SERIAL_PORT = '/dev/tty.usbserial-12345' # Update for your Arty A7
BAUD_RATE = 115200
PHI = 137.508 * (math.pi / 180.0)  # The Golden Angle
PURPLE_GLOW = (138, 43, 226)       # #8A2BE2 Achromatic Center

# --- DAMPING CONSTANTS ---
ZETA = 0.1  # The Damping Factor: 1.0 is rigid, 0.05 is fluid/moss-like

# --- INITIALIZE UI ---
pygame.init()
WIDTH, HEIGHT = 800, 800
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("SPU-13 Phyllotaxis Real-Time Telemetry (Damped)")
clock = pygame.time.Clock()

class Node:
    def __init__(self, index):
        self.index = index
        self.target_radius = 15 * math.sqrt(index)
        self.current_radius = 0.0
        self.intensity = 0.0

    def update(self, surd_val):
        # Apply the Damper (Temporal Easing for the 'Lean')
        self.current_radius += (self.target_radius - self.current_radius) * ZETA
        self.intensity = min(1.0, abs(surd_val) / 65536.0)

    def render(self, screen):
        theta = self.index * PHI
        # Forward Lean (Projective Scale derived from Surd magnitude)
        forward_lean = self.intensity * pow(0.618, self.index % 13)
        
        x = (WIDTH // 2) + self.current_radius * math.cos(theta) * (1.0 + forward_lean)
        y = (HEIGHT // 2) + self.current_radius * math.sin(theta) * (1.0 + forward_lean)
        
        brightness = int(255 * self.intensity)
        node_color = (
            min(255, PURPLE_GLOW[0] + brightness // 4),
            min(255, PURPLE_GLOW[1] + brightness // 4),
            min(255, PURPLE_GLOW[2] + brightness // 4)
        )
        
        pygame.draw.circle(screen, node_color, (int(x), int(y)), 4 + int(2 * self.intensity))

def main():
    print("--- SPU-13 Bloom View: Visualizing the Absolute (Damped) ---")
    try:
        ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=0.1)
    except Exception as e:
        print(f"Error: Could not open {SERIAL_PORT}. {e}")
        sys.exit(1)

    nodes = [Node(i) for i in range(500)]
    running = True
    current_surd = 0

    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False

        # Read 32-bit Surd from FPGA
        if ser.in_waiting >= 4:
            raw_data = ser.read(4)
            current_surd = int.from_bytes(raw_data, byteorder='little', signed=True)

        screen.fill((18, 18, 18)) # Deep Space Black
        
        # Update and render the full lattice bloom
        for node in nodes:
            node.update(current_surd)
            node.render(screen)
        
        pygame.display.flip()
        clock.tick(60)

    ser.close()
    pygame.quit()

if __name__ == "__main__":
    main()
