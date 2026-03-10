// ULX3S Lean Manifold (v1.1 HAL)
// Target: Lattice ECP5-85k
// Objective: Single-core parity with iCeSugar for bit-exact verification.

`include "../../include/spu/spu13_pins.vh"

module ulx3s_top (
    input  wire `SPU_PIN_CLK,
    input  wire `SPU_PIN_RST_N,
    output wire `SPU_PIN_LED_R,
    output wire `SPU_PIN_LED_G,
    output wire `SPU_PIN_LED_B,
    output wire `SPU_PIN_UART_TX
);

    // Instantiate the Shared Lean Core with 25MHz Clock
    spu13_lean_core #(
        .CLK_HZ(25000000)
    ) u_shared_core (
        .`SPU_PIN_CLK(`SPU_PIN_CLK),
        .`SPU_PIN_RST_N(`SPU_PIN_RST_N),
        .`SPU_PIN_LED_R(`SPU_PIN_LED_R),
        .`SPU_PIN_LED_G(`SPU_PIN_LED_G),
        .`SPU_PIN_LED_B(`SPU_PIN_LED_B),
        .`SPU_PIN_UART_TX(`SPU_PIN_UART_TX)
    );

endmodule
