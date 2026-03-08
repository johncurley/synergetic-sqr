import math

# SPU-13 Geodesic Fractal Trace Generator (v3.1)
# Implements the Sierpinski-Lindermayer recursive rules for Q(3) manifolds.
# Seed: 60-degree 'V' shape.
# Constraint: All lengths scale by the Surd (1/sqrt(3)).

def generate_geodesic_fractal(iterations, length):
    """
    Generates an SVG path for the geodesic fractal.
    Rule: F -> F+F--F+F (using 60-degree increments)
    """
    # L-System Rules
    axiom = "F"
    rules = {"F": "F+F--F+F"}
    
    current = axiom
    for _ in range(iterations):
        next_str = ""
        for char in current:
            next_str += rules.get(char, char)
        current = next_str
        
    # Translate to SVG Path
    angle = 0
    x, y = 100, 100
    path_data = [f"M {x} {y}"]
    
    # Scale length by surd factor for each iteration to keep it bounded
    step = length / (math.sqrt(3) ** iterations)
    
    for cmd in current:
        if cmd == "F":
            x += step * math.cos(math.radians(angle))
            y -= step * math.sin(math.radians(angle))
            path_data.append(f"L {x} {y}")
        elif cmd == "+":
            angle += 60
        elif cmd == "-":
            angle -= 60
            
    return " ".join(path_data)

def save_svg(path_data, filename="geodesic_trace.svg"):
    svg_template = f"""<svg width="800" height="800" viewBox="0 0 800 800" xmlns="http://www.w3.org/2000/svg">
    <rect width="100%" height="100%" fill="#050505"/>
    <path d="{path_data}" stroke="#00FFCC" stroke-width="1" fill="none" opacity="0.8"/>
    </svg>"""
    with open(filename, "w") as f:
        f.write(svg_template)
    print(f"Laminar Trace Map manifested at: {filename}")

if __name__ == "__main__":
    # Level 4 Iteration provides high-density laminar flow
    trace_path = generate_geodesic_fractal(iterations=4, length=300)
    save_svg(trace_path)
