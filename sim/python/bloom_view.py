# SPU-13 Bloom View UI (v3.1.12)
# Real-time Isotropic Visualization with Dependency Guidance.

import math
import sys
import time

# --- DEPENDENCY AUDIT ---
MISSING_DEPS = []
try:
    import pygame
except ImportError:
    MISSING_DEPS.append("pygame")

try:
    import serial
    SERIAL_AVAILABLE = True
except ImportError:
    SERIAL_AVAILABLE = False
    # pyserial is only critical if --port is used
    if "--port" in sys.argv:
        MISSING_DEPS.append("pyserial")

if MISSING_DEPS:
    print("--- SPU-13 Dependency Audit ---")
    print(f"CRITICAL: Missing Python libraries: {', '.join(MISSING_DEPS)}")
    print(f"FIX: Run 'pip install {' '.join(MISSING_DEPS)}' to enable the visualizer.")
    sys.exit(1)

# --- CONFIGURATION ---
SERIAL_PORT = None
for i in range(len(sys.argv)):
    if sys.argv[i] == "--port" and i + 1 < len(sys.argv):
        SERIAL_PORT = sys.argv[i+1]

BAUD_RATE = 115200
PHI = 137.508 * (math.pi / 180.0)
PURPLE_GLOW = (138, 43, 226) 
NEUTRAL_GRAY = (100, 100, 100)
ZETA_BASE = 0.08
STABILIZE_FLAG = "--stabilize" in sys.argv

# --- INITIALIZE UI ---
pygame.init()
WIDTH, HEIGHT = 800, 800
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("SPU-13 Isotropic Bloom")
clock = pygame.time.Clock()

class Node:
    def __init__(self, index):
        self.index = index
        self.target_radius = 15 * math.sqrt(index)
        self.current_radius = 0.0
        self.intensity = 0.0

    def update(self, surd_val, zeta):
        weighted_val = round(surd_val / 65536.0, 12)
        self.current_radius += (self.target_radius - self.current_radius) * zeta
        self.intensity = min(1.0, abs(weighted_val))

    def render(self, screen, pulse_val, glow_fade):
        theta = self.index * PHI
        forward_lean = self.intensity * pow(0.618, self.index % 13)
        r_sync = self.current_radius * (1.0 + 0.02 * pulse_val)
        x = (WIDTH // 2) + r_sync * math.cos(theta) * (1.0 + forward_lean)
        y = (HEIGHT // 2) + r_sync * math.sin(theta) * (1.0 + forward_lean)
        
        c_val = [int(NEUTRAL_GRAY[i] + (PURPLE_GLOW[i] - NEUTRAL_GRAY[i]) * glow_fade) for i in range(3)]
        pygame.draw.circle(screen, tuple(c_val), (int(x), int(y)), 4)

def main():
    print(f"--- SPU-13 Bloom Active [Mode: {'Hardware' if SERIAL_PORT else 'Virtual'}] ---")
    
    ser = None
    if SERIAL_PORT:
        try:
            ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=0.1)
        except Exception as e:
            print(f"Serial Error: {e}")
            return

    nodes = [Node(i) for i in range(500)]
    running = True
    start_time = time.time()
    glow_fade = 0.0 if STABILIZE_FLAG else 1.0

    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT: running = False

        if STABILIZE_FLAG and glow_fade < 1.0:
            glow_fade += 0.005

        current_surd = 65536 
        if ser and ser.in_waiting >= 4:
            current_surd = int.from_bytes(ser.read(4), byteorder='little', signed=True)

        elapsed = time.time() - start_time
        pulse_val = math.sin(2.0 * math.pi * 1.024 * elapsed)
        screen.fill((18, 18, 18)) 
        
        for node in nodes:
            node.update(current_surd, ZETA_BASE)
            node.render(screen, pulse_val, glow_fade)
        
        pygame.display.flip()
        clock.tick(60)

    if ser: ser.close()
    pygame.quit()

if __name__ == "__main__":
    main()
