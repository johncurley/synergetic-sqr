// SPU-13 I/O Bridge (v2.8.2)
// Manages the interface between the 832-bit Sovereign Core and Physical Pins.

module spu_io_bridge (
    input  wire         clk,
    input  wire         reset,
    input  wire [831:0] spu_reg_in,   // Data from Core
    input  wire         fault_detected,
    
    // Physical Board I/O (Arty A7 Mapping)
    output wire [3:0]   led_status,   // Visual state indicator
    output wire [7:0]   pmod_ja_out,  // High-speed parallel data out
    input  wire [3:0]   sw_control    // Switch-based opcode overrides
);

    // 1. Status Mapping
    // LED 0: Heartbeat
    // LED 1: Fault
    // LED 2-3: Prime Phase [0-1]
    assign led_status[0] = clk;
    assign led_status[1] = fault_detected;
    assign led_status[3:2] = spu_reg_in[1:0]; // Low bits of Q1 used for phase tracking

    // 2. PMOD JA (High-Speed Data Mirror)
    // Sends the most significant 8 bits of the current Quadray axis to the JA pins
    // for external Logic Analyzer verification.
    assign pmod_ja_out = spu_reg_in[31:24]; 

    // 3. Command Injection
    // sw_control can be used to force a RESET or Janus toggle from the board switches
    wire manual_reset = sw_control[0];
    wire manual_janus = sw_control[1];

endmodule
