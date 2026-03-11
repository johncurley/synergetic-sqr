// SPU-13: Blinky_Symmetry (The Laminar Hello World)
// Target: iCE40UP5K (iCeSugar)

module blinky_symmetry (
    input  wire clk,        // 12MHz Lattice Pulse (Pin 35)
    input  wire reset,      // Return to the Void (Pin 10)
    output wire [3:0] leds  // The ABCD Symmetry (Pins 4, 2, 48, 45)
);

    // 24-bit Counter for the "Laminar Sip"
    // Dividing 12MHz down to ~0.7 Hz
    reg [23:0] counter;
    
    // The ABCD State Machine (The Quadray Rotor)
    // Rotating the "1" through the Lattice
    reg [3:0] abcd_state;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            abcd_state <= 4'b0001; // Start at Axis A
        end else begin
            counter <= counter + 1;
            
            // At the peak of the counter, shift the "Liquid"
            if (counter == 24'hFFFFFF) begin
                // Circular Shift: A -> B -> C -> D -> A
                abcd_state <= {abcd_state[2:0], abcd_state[3]};
            end
        end
    end

    // Connect the State to the Physical LEDs
    assign leds = abcd_state;

endmodule
