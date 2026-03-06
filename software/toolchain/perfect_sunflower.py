# SPU-13 Silicon Rosetta Stone: The Perfect Sunflower (v3.0.33)
# Objective: Zero-Drift Sunflower with Gentle Entry Safety Toggle.
# Requirements: pip install sympy numpy matplotlib

from sympy import sqrt, simplify, expand, Rational
import numpy as np
import matplotlib.pyplot as plt

class QuadrayField:
    PHI = (1 + sqrt(5)) / 2 
    def __init__(self, a=0, b=0, c=0, d=0):
        self.coords = [simplify(a), simplify(b), simplify(c), simplify(d)]
    def phi_scale(self, power=1):
        scale = self.PHI ** power
        return QuadrayField(*[c * scale for c in self.coords])
    def to_vec4(self):
        return np.array([float(c.evalf()) for c in self.coords], dtype=np.float32)

def generate_gentle_lattice(n_seeds=1200, zeta=0.05, slow_fade=True):
    """Constructs the sunflower with gradual emanation and rhythmic damping."""
    print(f"--- SPU-13: Synthesizing {n_seeds} Gentle Seeds ---")
    lattice = []
    golden_angle = 137.508 * (np.pi / 180.0)
    
    for i in range(n_seeds):
        # 1. ZETA Modulation (Rhythmic Vibration)
        radius = np.sqrt(i) * (1 + zeta * np.sin(i * 0.3))
        angle = i * golden_angle
        
        # 2. Polar to Cartesian Projection
        x = radius * np.cos(angle)
        y = radius * np.sin(angle)
        
        # 3. Slow Fade (Neurological Safety)
        alpha = 1.0
        if slow_fade:
            alpha = min(1.0, i / 300.0) # Fade in over first 300 nodes
            
        lattice.append((x, y, alpha))
        
    return np.array(lattice)

def main():
    lattice = generate_gentle_lattice(1200)
    
    plt.figure(figsize=(10, 10), facecolor='#121212')
    plt.scatter(lattice[:,0], lattice[:,1], c='#8A2BE2', s=10, 
                alpha=lattice[:,2], edgecolors='none')
    plt.axis('off')
    plt.title("SPU-13 Gentle Bloom: Phase 1 Orientation", color='white')
    
    print("HENOSIS: Gentle Lattice Manifested. System at Rest.")
    plt.show()

if __name__ == "__main__":
    main()
