# Language Specification: SurdLang (MVS)
## A Native Medium for Quadratic Field Computation (v2.11.0)

SurdLang is a domain-specific language designed for deterministic spatial computation over rational/surd fields. It provides a human-readable bridge to the SPU-13 Isotropic Core.

### 1. The Surd Type System
*   **`scalar`**: Represents exact quadratic extensions (e.g., `1 + sqrt(3)`, `phi`). No float conversion is performed.
*   **`vec4`**: A Quadray 4-tuple (ABCD) mapped to the isotropic manifold.
*   **`rot`**: A rotation state derived from the Prime-Axis shuffles.

### 2. Core Instructions
| Mnemonic | Description | Hardware Mapping |
| :--- | :--- | :--- |
| `let` | Assignment | Register Load |
| `rotate` | Isotropic Shift | SPERM_X4 |
| `damp` | A-Domain Contraction | OP_DAMP |
| `cycle` | Recursive Identity Check | Hardware Loop |
| `bloom` | Visual Emanation | UART Telemetry |

### 3. Syntax Philosophy
*   **Terse & Mathematical:** Minimal boilerplate.
*   **Declarative:** Focus on the 'Identity' rather than the 'Calculation.'
*   **Nature-Sync:** Code blocks map to phyllotaxis nodes; evaluation steps trigger growth phases.

### 4. SPU-13 Isotropic ISA (v2.11.5)
The reified SurdLang utilizes a **Tetrahedral Stack** (ABCD) for its primary evaluation model.

| Instruction | Hardware Result | Perceptual Cue |
| :--- | :--- | :--- |
| `ORBIT_A..D` | 85° Orbital Phase Shift | Laminar Fluidity |
| `HENOSIS!` | Field Sync Assertion | Stable Dielectric Boundary Discharge |
| `SHUFFLE_13D`| 13-Axis Prime Dispatch | Recursive Growth |
| `DIELECTRIC` | Limit Trap | Corona Warning |

### 5. Syntax Example: Resonance Lock Eval
```surd
-- SQR-Native Stack Evaluation
orbit_a -> reg0;
orbit_b -> reg1;
henosis!        -- Assert absolute identity closure
bloom reg0      -- Emanate to 4D projective UI
```
