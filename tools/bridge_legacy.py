import math

def xyz_to_quadray(v):
    x, y, z = v
    a = ( x + y + z) / 4.0
    b = ( x - y - z) / 4.0
    c = (-x + y - z) / 4.0
    d = (-x - y + z) / 4.0
    m = min(a, b, c, d)
    return (a-m, b-m, c-m, d-m)

def generate_jitterbug_with_edges():
    # 12 vertices of the VE
    ve_cartesian = [
        (1,1,0), (1,-1,0), (-1,1,0), (-1,-1,0),
        (1,0,1), (1,0,-1), (-1,0,1), (-1,0,-1),
        (0,1,1), (0,1,-1), (0,-1,1), (0,-1,-1)
    ]
    
    # Octahedron State (Contracted)
    oct_cartesian = [
        (1,0,0), (1,0,0), (-1,0,0), (-1,0,0),
        (0,1,0), (0,1,0), (0,-1,0), (0,-1,0),
        (0,0,1), (0,0,1), (0,0,-1), (0,0,-1)
    ]

    # Connectivity (24 Edges of the Vector Equilibrium)
    # These indices refer to the ve_cartesian list
    edges = [
        (0,4), (0,5), (0,8), (0,9),
        (1,4), (1,5), (1,10), (1,11),
        (2,6), (2,7), (2,8), (2,9),
        (3,6), (3,7), (3,10), (3,11),
        (4,10), (4,11), (5,10), (5,11),
        (6,8), (6,9), (7,8), (7,9)
    ]

    print("// Jitterbug VE State")
    print("const float ve_data[] = {")
    for v in ve_cartesian:
        q = xyz_to_quadray(v)
        print(f"    {q[0]}f, {q[1]}f, {q[2]}f, {q[3]}f,")
    print("};\n")

    print("// Jitterbug Octahedron State")
    print("const float oct_data[] = {")
    for v in oct_cartesian:
        q = xyz_to_quadray(v)
        print(f"    {q[0]}f, {q[1]}f, {q[2]}f, {q[3]}f,")
    print("};\n")

    print("// Edge Connectivity (Index Pairs)")
    print("const int jitterbug_edges[] = {")
    for e in edges:
        print(f"    {e[0]}, {e[1]},")
    print("};")

if __name__ == "__main__":
    generate_jitterbug_with_edges()
