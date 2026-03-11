; --- SPU-13 Stress Test: The Zero-G Gulp ---
; Objective: Flood the manifold and hit the TAU threshold.
; Expected Result: RED LED triggers as tension exceeds TAU_Q.

START:
    VADD QA, 0       ; Recursive displacement on Axis A
    VADD QA, 0       ; Keep pushing the tension...
    VADD QA, 0
    VADD QA, 0
    SIP  QA, UART    ; Report Tension K
    LEAP START       ; Repeat until breach
