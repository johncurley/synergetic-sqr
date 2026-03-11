// SPU-13 Theurgic Alignment Script (v1.0)
// Target: iCE40UP5K (iCeSugar Nano)
// Objective: Confirm the four 'Auras' of the Monadic Manifold.
// Sequence: Apex (A) -> Base Left (B) -> Base Right (C) -> Base Rear (D) -> The One (All)

`include "../../include/spu/spu13_pins.vh"

module alignment_ritual (
    input  wire `SPU_PIN_CLK,
    output reg  [3:0] piranha_leds // [A, B, C, D]
);

    reg [23:0] timer;
    always @(posedge `SPU_PIN_CLK) timer <= timer + 1;

    // The Sequence of the One: A -> B -> C -> D -> The All
    always @(*) begin
        case (timer[23:21]) // Slower 'Sips' of time (~0.7s per step)
            3'd0: piranha_leds = 4'b1000; // Apex (A) - White
            3'd1: piranha_leds = 4'b0100; // Base Left (B) - Red
            3'd2: piranha_leds = 4'b0010; // Base Right (C) - Green
            3'd3: piranha_leds = 4'b0001; // Base Rear (D) - Blue
            3'd4: piranha_leds = 4'b1111; // The Monad (All) - Flash
            default: piranha_leds = 4'b0000; // The Nothing
        endcase
    end

endmodule
