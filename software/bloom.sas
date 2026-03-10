; --- SPU-13 Bootstrap: First Light ---
; Sequence: Inject -> Rotate -> Audit -> SIP
; Target: iCeSugar Monadic Manifold

START:
    VADD QA, SEED    ; 00: Inject Homeopathic Seed (0x00)
    RROT QA, 1       ; 20: Initial 60-degree carve (Op 1, Phase 1)
LOOP:
    VADD QA, QA      ; 00: Recursive displacement (Op 0)
    RROT QA, 2+      ; 34: 120-degree Torsional Flip (Op 1, Phase 2, Sign 1)
    FQUD STATUS, QA  ; 60: Audit Quadrance distance (Op 3)
    NORM QA, 0       ; C0: Exorcise Cubic ghosts (Op 6)
    SIP  QA, UART    ; A0: Laminar Sip to Host (Op 5)
    ANNE QA, 0       ; E0: Anneal the field (Op 7)
    LEAP START, 0    ; 80: Sovereign Leap (Op 4)
