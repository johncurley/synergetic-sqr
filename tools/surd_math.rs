/// SPU-13: Surd-Fixed-Point Arithmetic (Rust Reference)
/// A deterministic implementation of the Q(sqrt(3)) field for software-to-hardware C&C.
/// (v3.1.27 "Sunday Morning Launch")

/// A Surd-Fixed-Point representation of I + S*sqrt(3)
/// This maintains exact algebraic identity across all field transformations.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default)]
pub struct SurdFixed {
    /// The Rational/Integer component (I)
    pub i: i64, 
    /// The Surd (sqrt(3)) component (S)
    pub s: i64, 
}

impl SurdFixed {
    /// Initialize a new SurdFixed value (I + S*sqrt(3))
    pub fn new(i: i64, s: i64) -> Self {
        SurdFixed { i, s }
    }

    /// Exact addition in the Q(sqrt(3)) field
    pub fn add(self, other: Self) -> Self {
        SurdFixed {
            i: self.i + other.i,
            s: self.s + other.s,
        }
    }

    /// Exact subtraction in the Q(sqrt(3)) field
    pub fn sub(self, other: Self) -> Self {
        SurdFixed {
            i: self.i - other.i,
            s: self.s - other.s,
        }
    }

    /// Exact multiplication in the Q(sqrt(3)) field
    /// (i1 + s1*sqrt(3)) * (i2 + s2*sqrt(3)) = (i1*i2 + 3*s1*s2) + (i1*s2 + s1*i2)*sqrt(3)
    /// This operation is bit-exact and algebraically closed.
    pub fn mul(self, other: Self) -> Self {
        SurdFixed {
            i: (self.i * other.i) + (3 * self.s * other.s),
            s: (self.i * other.s) + (self.s * other.i),
        }
    }

    /// Convert to float only when necessary for legacy I/O or visualization.
    /// Warning: This introduces floating-point approximation drift.
    pub fn to_float(self) -> f64 {
        (self.i as f64) + (self.s as f64) * 3.0_f64.sqrt()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_exact_identity() {
        // (1 + 1*sqrt(3)) * (1 + 1*sqrt(3)) = (1*1 + 3*1*1) + (1*1 + 1*1)*sqrt(3) = 4 + 2*sqrt(3)
        let a = SurdFixed::new(1, 1);
        let b = SurdFixed::new(1, 1);
        let c = a.mul(b);
        
        assert_eq!(c.i, 4);
        assert_eq!(c.s, 2);
    }

    #[test]
    fn test_zero_drift_closure() {
        // Prove that repeated multiplication remains bit-exact in the integer domain.
        let mut val = SurdFixed::new(1, 1);
        for _ in 0..100 {
            val = val.mul(SurdFixed::new(1, 0)); // Multiply by Identity (1 + 0*sqrt(3))
        }
        assert_eq!(val.i, 1);
        assert_eq!(val.s, 1);
    }
}
