// SPU-13 Artery Interface (v1.0)
// Objective: Standardized modular interconnect for the Sovereign Fleet.
// Vibe: The Universal Synapse.

`ifndef SPU_ARTERY_INTERFACE_VH
`define SPU_ARTERY_INTERFACE_VH

`define ARTERY_BUS_SIGNALS \
    input  wire        clk,           /* 61.44 kHz phase-aligned pulse */ \
    input  wire        reset,         /* System reset */                  \
    input  wire [31:0] rational_num,  /* Rational numerator */            \
    input  wire [31:0] rational_den,  /* Rational denominator (Scale) */  \
    input  wire        valid,         /* Logic high on resonance */       \
    output wire        ready          /* Logic high when manifold clear */

`endif
