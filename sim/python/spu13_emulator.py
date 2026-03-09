# SPU-13 Golden Emulator (v3.4.15)
# Objective: Bit-exact software model of the SPU-13 Isotropic Manifold.
# Implementation: Integer arithmetic in Q(sqrt3, sqrt5) field.

import time

class GoldenSurd:
    """
    Bit-exact Surd implementation for Q(sqrt3, sqrt5).
    Representation: a + b*sqrt3 + c*sqrt5 + d*sqrt15
    """
    SHIFT = 16
    ONE = 1 << SHIFT

    def __init__(self, a=0, b=0, c=0, d=0):
        self.a = int(a)
        self.b = int(b)
        self.c = int(c)
        self.d = int(d)

    @classmethod
    def Phi(cls):
        # Golden Ratio scaled to 16.16: 32768 + 32768*sqrt5
        return cls(32768, 0, 32768, 0)

    def multiply(self, other):
        aa = self.a * other.a
        bb = self.b * other.b
        cc = self.c * other.c
        dd = self.d * other.d
        
        ab = self.a * other.b + self.b * other.a
        ac = self.a * other.c + self.c * other.a
        ad = self.a * other.d + self.d * other.a
        bc = self.b * other.c + self.c * other.b
        bd = self.b * other.d + self.d * other.b
        cd = self.c * other.d + self.d * other.c
        
        res_a = (aa + 3*bb + 5*cc + 15*dd) >> self.SHIFT
        res_b = (ab + 5*cd) >> self.SHIFT
        res_c = (ac + 3*bd) >> self.SHIFT
        res_d = (ad + bc) >> self.SHIFT
        
        return GoldenSurd(res_a, res_b, res_c, res_d)

    def add(self, other):
        return GoldenSurd(self.a + other.a, self.b + other.b, self.c + other.c, self.d + other.d)

    def janus_flip(self):
        """Bit-exact sign inversion of the surd component."""
        return GoldenSurd(self.a, -self.b, self.c, -self.d)

    def norm(self):
        """Calculates the rational norm of the surd."""
        return (self.a**2 - 3*self.b**2 - 5*self.c**2 + 15*self.d**2)

class BowmanSequencer:
    """Software model of the 5-phase automated wake-up."""
    WITHDRAWAL = 0
    HANDSHAKE  = 1
    SATURATION = 2
    ALIGNMENT  = 3
    RESONANCE  = 4

    def __init__(self):
        self.phase = self.WITHDRAWAL
        self.timer = 0

    def step(self, en, handshake_done, identity_lock):
        if not en:
            self.phase = self.WITHDRAWAL
            self.timer = 0
            return self.phase

        if self.phase == self.WITHDRAWAL:
            self.phase = self.HANDSHAKE
        elif self.phase == self.HANDSHAKE:
            if handshake_done: self.phase = self.SATURATION
        elif self.phase == self.SATURATION:
            self.timer += 1
            if self.timer >= 10: 
                self.phase = self.ALIGNMENT
                self.timer = 0
        elif self.phase == self.ALIGNMENT:
            if identity_lock: self.phase = self.RESONANCE
            
        return self.phase

class ResonantMembrane:
    """Software model of the Harmonic Transducer."""
    def __init__(self):
        self.state = [0, 0, 0, 0] # ABCD

    def strike(self, ascii_char):
        code = ord(ascii_char)
        self.state[0] += (code & 0x3) << 16
        self.state[1] += ((code >> 2) & 0x3) << 16
        self.state[2] += ((code >> 4) & 0x3) << 16
        self.state[3] += ((code >> 6) & 0x3) << 16

    def decay(self):
        for i in range(4):
            self.state[i] -= (self.state[i] >> 4)
