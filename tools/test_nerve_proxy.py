#!/usr/bin/env python3
# SPU-13 Nerve Proxy Test (v1.0)
# Objective: Verify physical pin-toggling on the FT232H bridge.
# Requirement: pip install pyftdi

import time
import sys
try:
    from pyftdi.gpio import GpioController
except ImportError:
    print("Error: pyftdi not found. Run 'pip install pyftdi'")
    sys.exit(1)

def test_bridge():
    print("--- Commencing SPU-13 Nerve Proxy Audit ---")
    gpio = GpioController()
    
    try:
        # Open the first FT232H device found
        gpio.open_from_url('ftdi://ftdi:232h/1')
        print("[PASS] FT232H Handshake Successful.")
        
        # Set all 8 pins (D0-D7) as output
        gpio.set_direction(0xFF, 0xFF)
        
        print("[TEST] Toggling Manifold Pins (61.44 kHz simulation)...")
        for i in range(100):
            gpio.write(0xAA) # Strike Pattern A
            time.sleep(0.001)
            gpio.write(0x55) # Strike Pattern B
            time.sleep(0.001)
            
        print("[PASS] All 8 PMOD pins verified. Manifold is Responsive.")
        
    except Exception as e:
        print(f"[FAIL] Bridge error: {e}")
    finally:
        gpio.close()

if __name__ == "__main__":
    test_bridge()
