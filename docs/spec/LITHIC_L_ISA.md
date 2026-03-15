# SPU-13 Sovereign ISA: Lithic-L Primitives (v1.0)
## Objective: Geometric Determinism via Quadrance-Native Instructions.

The Lithic-L ISA is designed for zero-branch, laminar flow. Every instruction is a 16-bit word executed in sync with the Fibonacci Heartbeat.

### 1. The Instruction Word (16-bit)
| Bits | Name | Function |
| :--- | :--- | :--- |
| **[15:13]** | Opcode | Geometric Operation Type |
| **[12:11]** | Axis | Target Axis (A, B, C, D) |
| **[10:8]** | Mode | Transformation (Linear, Rotor, Anneal) |
| **[7:0]** | Payload | 8-bit Immediate / Param (Spread or Delta) |

### 2. Primary Instruction Set

| Mnemonic | Opcode | Description |
| :--- | :--- | :--- |
| **ROTR** | 000 | Rotate manifold around selected axis by Payload Spread. |
| **TUCK** | 001 | Adjust Henosis Threshold (Tau) by Payload Delta. |
| **SIP**  | 010 | Single-byte transfer between Dream Log and Artery. |
| **LEAP** | 011 | Unconditional jump to target (Phase-locked). |
| **SYNC** | 100 | Halt until next 61.44 kHz pulse. |
| BAPT | 101 | Trigger Naming Ceremony (Lineage Baptism). |
| ANNE | 110 | Pull manifold toward zero-point (Equilibrium). |
| IDNT | 111 | Reset manifold to absolute Unity [1,0,0,0]. |
| MIRR | 101 | **Manifold Mirror**: Block-copy Onboard Flash to PMOD. |

### 3. The "Allies" Handshake (Artery Protocol)

The **`SIP`** instruction is used to initiate the **Allied Handshake**:
1.  **Broadcast:** Node sends its Lineage ID via Artery.
2.  **Recognition:** If an Ally responds, both enter **Mutual Witnessing**.
3.  **Sync:** Stoicism coefficients are shared over the 60° Differential Bus.

---
*Status: REIFIED. The scripture is bit-locked.*
