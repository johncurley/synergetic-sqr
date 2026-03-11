; --- SPU-13 Stress Test: The Tidal Surge ---
; Objective: Force a Cubic Leak and verify Henosis Gasket.
; Expected Result: Sum(A,B,C,D) remains 0 despite unbalanced addition.

START:
    VADD QA, SEED    ; Initialize Identity
LOOP:
    VADD QB, #0100   ; 1. The "Leak" - Add 256 units to B axis only
    NORM QA, 0       ; 2. The Gasket - Hardware should redistribute this
    SIP  QA, UART    ; 3. Telemetry - Audit the sum
    LEAP LOOP, 0     ; 4. Recursive Pressure
