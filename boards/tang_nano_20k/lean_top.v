// Tang Nano 20k Lean Manifold (v1.2 HAL)
// Target: Gowin GW2A-18C
// Objective: Single-core parity with iCeSugar for bit-exact verification.

`include "../../include/spu/spu13_pins.vh"

module tang_nano_20k_top (
    input  wire `SPU_PIN_CLK,
    input  wire `SPU_PIN_RST_N,
    output wire `SPU_PIN_LED_R,
    output wire `SPU_PIN_LED_G,
    output wire `SPU_PIN_LED_B,
    output wire `SPU_PIN_UART_TX,
    input  wire `SPU_PIN_UART_RX,
    output wire oled_scl,
    output wire oled_sda
);

    // Instantiate the Shared Lean Core with 27MHz Clock (Tang Nano 20K)
    spu13_lean_core #(
        .CLK_HZ(27000000)
    ) u_shared_core (
        .`SPU_PIN_CLK(`SPU_PIN_CLK),
        .`SPU_PIN_RST_N(`SPU_PIN_RST_N),
        .`SPU_PIN_LED_R(`SPU_PIN_LED_R),
        .`SPU_PIN_LED_G(`SPU_PIN_LED_G),
        .`SPU_PIN_LED_B(`SPU_PIN_LED_B),
        .`SPU_PIN_UART_TX(`SPU_PIN_UART_TX),
        .oled_scl(oled_scl),
        .oled_sda(oled_sda)
    );

endmodule
