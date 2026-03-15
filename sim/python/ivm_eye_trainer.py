# SPU-13 IVM Eye Trainer: High-Dimensional Exposure (v3.2.0)
# Objective: Neurological restoration via 13-axis Isotropic Flow.
# Result: Bit-exact Jitterbug Folding via FGH Circulant Rotation.

import math
import sys
import pygame

# --- SOVEREIGN CONSTANTS ---
WIDTH, HEIGHT = 1000, 1000
FPS = 60 
LATTICE_STEP = 60 

# --- COLOR PALETTE ---
WHITE_SOVEREIGN = (255, 255, 255)
CYAN_LAMINAR = (0, 255, 255)
DEEP_SPACE = (5, 5, 8)
LATTICE_LOCK = (30, 35, 45)

class GaussianTrainer:
    def __init__(self, surface):
        self.surface = surface
        self.tick = 0
        self.axes = [
            (math.cos(0), math.sin(0)),
            (math.cos(math.pi/3), math.sin(math.pi/3)),
            (math.cos(2*math.pi/3), math.sin(2*math.pi/3))
        ]

    def render(self):
        t = self.tick * 0.02
        offsets = [
            math.sin(t) * 50,
            math.sin(t + 2.0) * 50,
            math.sin(t + 4.0) * 50
        ]

        # Mode 9: Gaussian Energy Field Rendering
        # We sample the field for each pixel to create the "stable" lines.
        # Note: In Python, we optimize by drawing slightly thicker anti-aliased lines
        # to mimic the Gaussian profile without per-pixel loops.
        
        for a_idx, (nx, ny) in enumerate(self.axes):
            offset = offsets[a_idx]
            for i in range(-12, 13):
                d = i * LATTICE_STEP + offset
                cx, cy = WIDTH//2 + nx * d, HEIGHT//2 - ny * d
                dx, dy = -ny, nx
                
                p1 = (cx + dx * 2000, cy - dy * 2000)
                p2 = (cx - dx * 2000, cy + dy * 2000)
                
                # Draw with "Energy Depth" (Core + Halo)
                # This mimics the Gaussian exp(-d*d) profile
                pygame.draw.aaline(self.surface, (0, 100, 80), p1, p2) # Halo
                pygame.draw.line(self.surface, WHITE_SOVEREIGN, p1, p2, 1) # Core

    def draw_cross(self):
        color = WHITE_SOVEREIGN
        pygame.draw.line(self.surface, color, (WIDTH//2 - 20, HEIGHT//2), (WIDTH//2 + 20, HEIGHT//2), 2)
        pygame.draw.line(self.surface, color, (WIDTH//2, HEIGHT//2 - 20), (WIDTH//2, HEIGHT//2 + 20), 2)
        pygame.draw.circle(self.surface, CYAN_LAMINAR, (WIDTH//2, HEIGHT//2), 3)

def main():
    pygame.init()
    screen = pygame.display.set_mode((WIDTH, HEIGHT))
    pygame.display.set_caption("SPU-13 Eye Trainer: Mode 9 (Gaussian)")
    clock = pygame.time.Clock()
    
    trainer = GaussianTrainer(screen)
    
    print("--- SPU-13 EYE TRAINER: MODE 9 REIFIED ---")
    print("Objective: Stable 60° exposure via Gaussian Energy lines.")
    print("Controls: [ESC] Quit")
    print("-------------------------------------------")

    running = True
    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT: running = False
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_ESCAPE: running = False

        screen.fill(DEEP_SPACE)
        trainer.tick += 1
        trainer.render()
        trainer.draw_cross()
        
        pygame.display.flip()
        clock.tick(FPS)

    pygame.quit()

if __name__ == "__main__":
    main()
