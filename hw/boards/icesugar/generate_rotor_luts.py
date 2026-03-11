# SPU-13 Rotor LUT Generator (v4.0.0)
# Objective: Generate bit-exact Rational Coefficients for the Spread Rotor.
# Methodology: Parametric Rational Trigonometry (t-parameter)

import math

def generate_luts():
    size = 4096
    scale = 65536 # 16.16 Fixed Point
    
    with open("rotor_cos.hex", "w") as f_cos, \
         open("rotor_sin.hex", "w") as f_sin, \
         open("rotor_den.hex", "w") as f_den:
        
        for i in range(size):
            # Map index 0-4095 to rational rotation parameter t
            # Using a simple linear ramp for the "Liquid" lean
            # t = tan(theta/2)
            angle = (i / size) * (math.pi / 3) # 0 to 60 degrees
            t = math.tan(angle / 2)
            
            # Rational Parametrization:
            # cos = (1 - t^2) / (1 + t^2)
            # sin = (2t) / (1 + t^2)
            
            num_cos = int((1 - t**2) * scale)
            num_sin = int((2 * t) * scale)
            den = int((1 + t**2) * scale)
            
            # Write as 24-bit Hex (6 hex digits)
            f_cos.write(f"{num_cos & 0xFFFFFF:06x}\n")
            f_sin.write(f"{num_sin & 0xFFFFFF:06x}\n")
            f_den.write(f"{den & 0xFFFFFF:06x}\n")

    print(f"SUCCESS: Generated {size} steps of Rational Rotation coefficients.")

if __name__ == "__main__":
    generate_luts()
