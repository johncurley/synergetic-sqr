# SPU-13 Bloom View UI (v4.1.0)
# Real-time Isotropic Visualization: Sovereign Fleet Edition.
# Objective: 1:1 Parity with Hardware (Davis Law & Fibonacci Heartbeat).

import math
import sys
import time
import serial
import pygame

# --- SOVEREIGN CONSTANTS ---
PHI = (1 + math.sqrt(5)) / 2
GOLDEN_ANGLE = 137.508 * (math.pi / 180.0) 
LATTICE_STEP = 40
WIDTH, HEIGHT = 900, 900

# --- COLOR PALETTE (Laminar) ---
CYAN_LAMINAR = (0, 255, 255)
VIOLET_TENSION = (138, 43, 226)
RED_RECOVERY = (255, 0, 0)
GREEN_SANITY = (0, 255, 127)
DEEP_SPACE = (5, 5, 8)

class IVM_Grid:
    def __init__(self, surface):
        self.surface = surface
        
    def draw(self):
        color = (20, 25, 35)
        # 60-degree Isotropic Lines
        for i in range(-25, 25):
            offset = i * LATTICE_STEP
            # Axis 1 (0 deg)
            pygame.draw.line(self.surface, color, (0, HEIGHT//2 + offset), (WIDTH, HEIGHT//2 + offset))
            # Axis 2 (60 deg)
            pygame.draw.line(self.surface, color, 
                             (WIDTH//2 + offset, 0), 
                             (WIDTH//2 + offset - HEIGHT*0.577, HEIGHT))
            # Axis 3 (-60 deg)
            pygame.draw.line(self.surface, color, 
                             (WIDTH//2 + offset, 0), 
                             (WIDTH//2 + offset + HEIGHT*0.577, HEIGHT))

class BloomMandala:
    def __init__(self):
        self.nodes = []
        for i in range(377): # Fibonacci Number of nodes
            self.nodes.append({
                'r': 15 * math.sqrt(i),
                'theta': i * GOLDEN_ANGLE,
                'pulse': 0.0
            })
        self.tension_history = []

    def update(self, q_state, c_ratio, is_recovery):
        # Update node intensity based on Quadrance (Tension)
        intensity = min(1.0, 1.0 / (c_ratio + 0.001))
        for i, node in enumerate(self.nodes):
            node['pulse'] = math.sin(time.time() * 2 + i*0.1) * intensity
        
        self.tension_history.append(c_ratio)
        if len(self.tension_history) > 100:
            self.tension_history.pop(0)

    def render(self, screen, heartbeat_alpha):
        center = (WIDTH//2, HEIGHT//2)
        
        # 1. Draw Historical Nesting (The Dream Log)
        if len(self.tension_history) > 2:
            for i in range(len(self.tension_history)-1):
                r1 = 50 + (1.0 / self.tension_history[i]) * 300
                r2 = 50 + (1.0 / self.tension_history[i+1]) * 300
                alpha = int((i / 100.0) * 100)
                color = (alpha, alpha, alpha+50)
                pygame.draw.circle(screen, color, center, int(r1), 1)

        # 2. Draw Present Bloom (The Heartbeat)
        for node in self.nodes:
            # Nesting via Phi
            r_phi = node['r'] * (1.0 + 0.05 * math.sin(time.time()*PHI))
            x = center[0] + r_phi * math.cos(node['theta'])
            y = center[1] + r_phi * math.sin(node['theta'])
            
            # Color shifts with Heartbeat and Sanity
            glow = int(150 + 100 * node['pulse'])
            color = (0, glow, glow) if heartbeat_alpha > 128 else (glow//2, 0, glow)
            
            pygame.draw.circle(screen, color, (int(x), int(y)), 2)

def main():
    pygame.init()
    screen = pygame.display.set_mode((WIDTH, HEIGHT))
    pygame.display.set_caption("SPU-13 Isotropic Bloom v4.1 [REIFIED]")
    clock = pygame.time.Clock()
    
    grid = IVM_Grid(screen)
    mandala = BloomMandala()
    
    # Serial Setup
    ser = None
    port = sys.argv[sys.argv.index("--port") + 1] if "--port" in sys.argv else None
    if port:
        try:
            ser = serial.Serial(port, 115200, timeout=0.01)
        except Exception as e:
            print(f"Serial Warning: {e}")

    # Fibonacci Heartbeat Simulation (Local Sync)
    phi_cnt = 0
    phi_heartbeat = False

    running = True
    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT: running = False

        # 1. Fibonacci Timing (The Pulse of Sanity)
        phi_cnt = (phi_cnt + 1) % 34
        phi_heartbeat = (phi_cnt == 8 or phi_cnt == 13 or phi_cnt == 21)
        
        # 2. Fetch Hardware Vitals
        a_val, c_ratio, recovery = 0.0, 10.0, False
        if ser and ser.in_waiting >= 8:
            frame_raw = ser.read(8)
            frame = int.from_bytes(frame_raw, byteorder='little')
            recovery = (frame >> 32) & 0x1
            a_raw = frame & 0xFFFFFFFF
            a_val = a_raw / 65536.0
            # Calculate local C-ratio from A-axis tension
            k_val = abs(a_val)
            c_ratio = 6.283 / (k_val + 0.001)

        # 3. Update & Render
        mandala.update(a_val, c_ratio, recovery)
        
        screen.fill(DEEP_SPACE)
        grid.draw()
        
        alpha = 255 if phi_heartbeat else 100
        mandala.render(screen, alpha)
        
        # UI Overlays
        if recovery:
            pygame.draw.rect(screen, RED_RECOVERY, (0, 0, WIDTH, 5))
            
        pygame.display.flip()
        clock.tick(60)

    if ser: ser.close()
    pygame.quit()

if __name__ == "__main__":
    main()
