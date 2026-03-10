#include <iostream>
#include <iomanip>
#include <cstdint>

struct Surd {
    int32_t i; // Integer part (16.16)
    int32_t s; // Surd part (16.16, sqrt(3))

    Surd(int32_t integer = 0, int32_t surd = 0) : i(integer), s(surd) {}

    static Surd multiply(const Surd& a, const Surd& b) {
        int64_t i1 = a.i;
        int64_t s1 = a.s;
        int64_t i2 = b.i;
        int64_t s2 = b.s;

        // (i1 + s1*sqrt3) * (i2 + s2*sqrt3) = (i1*i2 + 3*s1*s2) + (i1*s2 + s1*i2)sqrt(3)
        int64_t res_i = (i1 * i2) + (3 * s1 * s2);
        int64_t res_s = (i1 * s2) + (s1 * i2);

        // Normalize (16-bit shift for 16.16 fixed point)
        return Surd(static_cast<int32_t>(res_i >> 16), static_cast<int32_t>(res_s >> 16));
    }

    Surd operator+(const Surd& other) const {
        return Surd(i + other.i, s + other.s);
    }

    Surd operator-(const Surd& other) const {
        return Surd(i - other.i, s - other.s);
    }

    Surd scale(int32_t factor) const {
        return Surd(i * factor, s * factor);
    }

    void print(const std::string& name) const {
        std::cout << name << ": I=" << std::hex << std::setw(8) << std::setfill('0') << i 
                  << " S=" << std::hex << std::setw(8) << std::setfill('0') << s << std::dec << std::endl;
    }
};

int main() {
    // Input values from trace (State 1)
    // PI_F = 0
    // PI_G = 64'h00000001_00000000 (Integer = 0, Surd = 1.0)
    // PI_H = 0
    Surd F(0, 0);
    Surd G(0, 0x10000); // 1.0 in 16.16
    Surd H(0, 0);

    F.print("F");
    G.print("G");
    H.print("H");

    Surd F2 = Surd::multiply(F, F);
    Surd F3 = Surd::multiply(F2, F);
    F2.print("F2");
    F3.print("F3");

    Surd G2 = Surd::multiply(G, G);
    Surd G3 = Surd::multiply(G2, G);
    G2.print("G2");
    G3.print("G3");

    Surd H2 = Surd::multiply(H, H);
    Surd H3 = Surd::multiply(H2, H);
    H2.print("H2");
    H3.print("H3");

    Surd FG = Surd::multiply(F, G);
    Surd FGH = Surd::multiply(FG, H);
    Surd three_FGH = FGH.scale(3);

    Surd det = F3 + G3 + H3 - three_FGH;
    det.print("Det");

    return 0;
}
