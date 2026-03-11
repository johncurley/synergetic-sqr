; --- SPU-13 Stress Test: The Vacuum Sip ---
; Objective: Run at near-zero energy and test Evaporator stability.
; Expected Result: Green LED remains steady at Identity.

START:
    ANNE QA, 0       ; Relax the field
    ANNE QA, 0       ; Pull closer to zero...
    ANNE QA, 0
    ANNE QA, 0
    SIP  QA, UART    ; Report Identity K
    LEAP START       ; Stay in the void
