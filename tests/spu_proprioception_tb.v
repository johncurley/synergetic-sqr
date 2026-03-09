// SPU-13 Proprioception Audit (v3.3.79)
// Objective: Verify thermal feedback and homeostatic damping.
// Logic: Inject high-density bit-flips and monitor damping_active signal.

`timescale 1ns/1ps

module spu_proprioception_tb();
    reg clk;
    reg reset;
    reg [831:0] manifold_state;
    wire [31:0] thermal_pressure;
    wire damping_active;

    // 1. Instantiate the Monitor
    spu_proprioception u_feeling (
        .clk(clk), .reset(reset),
        .manifold_state(manifold_state),
        .thermal_pressure(thermal_pressure),
        .damping_active(damping_active)
    );

    integer i;
    initial begin
        clk = 0; reset = 1;
        manifold_state = 832'b0;
        
        $display("--- Proprioception Audit: Homeostasis Init ---");
        #100 reset = 0;
        
        // Step 1: Laminar Flow (Low Switching Density)
        $display("Injecting Laminar Flow...");
        for (i = 0; i < 300; i = i + 1) begin
            #10 manifold_state = {832{1'b0}}; // Constant state
        end
        $display("Laminar State: Pressure = %d | Damping = %b", thermal_pressure, damping_active);
        
        // Step 2: Cubic Turbulence (High Switching Density)
        $display("Injecting Cubic Turbulence (50%% flip density)...");
        for (i = 0; i < 300; i = i + 1) begin
            #10 manifold_state = ~manifold_state; // Max toggle rate
        end
        
        #10;
        $display("Turbulent State: Pressure = %d | Damping = %b", thermal_pressure, damping_active);
        
        if (damping_active)
            $display("PASS: Homeostatic Damping Triggered.");
        else
            $display("FAIL: System failed to detect manifold friction.");
            
        $finish;
    end

    always #5 clk = ~clk;

endmodule
