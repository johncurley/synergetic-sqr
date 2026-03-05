# SPU-13 Bloom View UI (v2.9.27)
# Real-time Phyllotaxis Visualization via UART Telemetry.
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

# --- INITIALIZE UI ---
pygame.init()
WIDTH, HEIGHT = 800, 800
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("SPU-13 Phyllotaxis Real-Time Telemetry")
clock = pygame.time.Clock()

def render_node(index, surd_val):
    # Geometric Foundation: Phyllotaxis
    r = 15 * math.sqrt(index)
    theta = index * PHI
    
    # Forward Lean (Projective Scale derived from Surd magnitude)
    # 65536 is the SF32.16 'One'
    intensity = min(1.0, abs(surd_val) / 65536.0)
    forward_lean = intensity * pow(0.618, index % 13)
    
    x = (WIDTH // 2) + r * math.cos(theta) * (1.0 + forward_lean)
    y = (HEIGHT // 2) + r * math.sin(theta) * (1.0 + forward_lean)
    
    # Resonant Glow tied to Henosis state
    brightness = int(255 * intensity)
    node_color = (
        min(255, PURPLE_GLOW[0] + brightness // 4),
        min(255, PURPLE_GLOW[1] + brightness // 4),
        min(255, PURPLE_GLOW[2] + brightness // 4)
    )
    
    pygame.draw.circle(screen, node_color, (int(x), int(y)), 4 + int(2 * intensity))

def main():
    print("--- SPU-13 Bloom View: Visualizing the Absolute ---")
    try:
        ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=0.1)
    except Exception as e:
        print(f"Error: Could not open {SERIAL_PORT}. {e}")
        sys.exit(1)

    running = True
    node_index = 0
    surd_history = [0] * 500

    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False

        # Read 32-bit Surd from FPGA
        if ser.in_waiting >= 4:
            raw_data = ser.read(4)
            surd_a = int.from_bytes(raw_data, byteorder='little', signed=True)
            surd_history[node_index] = surd_a
            node_index = (node_index + 1) % 500

        screen.fill((18, 18, 18)) # Deep Space Black
        
        # Render the full lattice bloom
        for i in range(500):
            if surd_history[i] != 0:
                render_node(i, surd_history[i])
        
        pygame.display.flip()
        clock.tick(60)

    ser.close()
    pygame.quit()

if __name__ == "__main__":
    main()
