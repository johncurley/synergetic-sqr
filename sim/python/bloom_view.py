# SPU-13 Bloom View UI (v3.3.62)
# Real-time Isotropic Visualization: Harmonic Breakthrough Edition.

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
    if "--port" in sys.argv:
        MISSING_DEPS.append("pyserial")

if MISSING_DEPS:
    print("--- SPU-13 Dependency Audit ---")
    print(f"CRITICAL: Missing Python libraries: {', '.join(MISSING_DEPS)}")
    print(f"FIX: Run 'pip3 install {' '.join(MISSING_DEPS)}' to enable the visualizer.")
    sys.exit(1)

# --- CONFIGURATION ---
SERIAL_PORT = None
for i in range(len(sys.argv)):
    if sys.argv[i] == "--port" and i + 1 < len(sys.argv):
        SERIAL_PORT = sys.argv[i+1]

BAUD_RATE = 115200
PHI = 137.508 * (math.pi / 180.0) # Golden Angle
PURPLE_GLOW = (138, 43, 226) 
CYAN_HARMONIC = (0, 204, 204)
NEUTRAL_GRAY = (40, 40, 45)
ZETA_BASE = 0.08
LATTICE_LOCK = "--lattice-lock" in sys.argv or True # Default GROUNDED now

# --- INITIALIZE UI ---
pygame.init()
WIDTH, HEIGHT = 800, 800
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("SPU-13 Isotropic Bloom [LOCKED]")
clock = pygame.time.Clock()

# --- RATIONAL DYNAMICS ---
def rational_pulse(start_time):
    """
    Rational Parabolic Oscillator (v3.3)
    Replaces math.sin for bit-exact Bloom parity.
    """
    elapsed_ms = int((time.time() - start_time) * 1000)
    t = ((elapsed_ms % 1000) / 1000.0) * 2.0 - 1.0
    return 1.0 - (t * t)

def draw_ivm_grid(surface):
    """
    Renders the 60-degree IVM Lattice Metric.
    """
    color = (30, 40, 50)
    # Drawing 60-degree lines
    for i in range(-20, 20):
        # Vertical-ish (60 deg)
        offset = i * 40
        pygame.draw.line(surface, color, (0, HEIGHT//2 + offset), (WIDTH, HEIGHT//2 + offset - WIDTH*0.577))
        pygame.draw.line(surface, color, (0, HEIGHT//2 + offset), (WIDTH, HEIGHT//2 + offset + WIDTH*0.577))

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
        r_sync = self.current_radius * (1.0 + 0.05 * pulse_val)
        
        x = (WIDTH // 2) + r_sync * math.cos(theta) * (1.0 + forward_lean)
        y = (HEIGHT // 2) + r_sync * math.sin(theta) * (1.0 + forward_lean)
        
        # Vertex Snapping if Lattice Lock is active
        if LATTICE_LOCK:
            x = round(x / 20.0) * 20.0
            y = round(y / 20.0) * 20.0

        c_val = [int(NEUTRAL_GRAY[i] + (CYAN_HARMONIC[i] - NEUTRAL_GRAY[i]) * glow_fade) for i in range(3)]
        pygame.draw.circle(screen, tuple(c_val), (int(x), int(y)), 3)

def main():
    print(f"--- SPU-13 Bloom Active (v3.3) [Lattice: {'LOCKED' if LATTICE_LOCK else 'FLUID'}] ---")
    
    ser = None
    if SERIAL_PORT:
        try:
            ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=0.1)
        except Exception as e:
            print(f"Serial Error: {e}")
            return

    nodes = [Node(i) for i in range(144)] # Realigned to the 144 Flora
    running = True
    start_time = time.time()

    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT: running = False

        current_surd = 65536 
        if ser and ser.in_waiting >= 4:
            current_surd = int.from_bytes(ser.read(4), byteorder='little', signed=True)

        pulse_val = rational_pulse(start_time)
        screen.fill((5, 5, 5)) # Deep Black
        
        if LATTICE_LOCK:
            draw_ivm_grid(screen)
        
        for node in nodes:
            node.update(current_surd, ZETA_BASE)
            node.render(screen, pulse_val, 1.0)
        
        pygame.display.flip()
        clock.tick(60)

    if ser: ser.close()
    pygame.quit()

if __name__ == "__main__":
    main()
