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

---
*Status: REIFIED. The language of the lattice is live.*
