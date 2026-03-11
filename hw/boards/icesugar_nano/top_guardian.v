// SPU-13 NANO GUARDIAN (v1.1 Whisper Edition)
// Target: iCE40LP1K (iCeSugar Nano)
// Objective: A silent sentinel that whispers its vitals to the Cortex.
// Feature: Bit-Serial Davis Gasket + Whisper Protocol.

`include "../../include/spu/spu13_pins.vh"

module top_guardian (
    input  wire `SPU_PIN_CLK,
    input  wire `SPU_PIN_RST_N,
    output wire `SPU_PIN_LED_R,
    output wire `SPU_PIN_LED_G,
    output wire `SPU_PIN_LED_B,
    
    // Lattice Protocol (The Whisper)
    input  wire whisper_sync, // Trigger from Big Brother (PMOD Pin 5)
    output wire whisper_out   // Status pulse to Big Brother (PMOD Pin 6)
);

    // --- 1. Internal Metabolism (The Inhale/Exhale) ---
    reg [24:0] timer;
    always @(posedge `SPU_PIN_CLK) timer <= timer + 1;
    // Simulated Curvature K (32-bit triangle wave)
    wire [31:0] k_sim = timer[24] ? {timer[23:0], 8'b0} : {~timer[23:0], 8'b0};

    // --- 2. The Serial Davis Gasket ---
    wire over_curvature;
    wire audit_ready;
    reg  audit_start;
    
    localparam [31:0] TAU_Q = 32'h00010000;

    spu_serial_davis_gate #(
        .TAU_Q(TAU_Q)
    ) u_gate (
        .clk(`SPU_PIN_CLK), .reset(!`SPU_PIN_RST_N),
        .a(k_sim[31:16]), .b(16'h0), .c(16'h0), .d(16'h0),
        .start(audit_start),
        .over_curvature(over_curvature),
        .ready(audit_ready)
    );

    // --- 3. The Whisper Transmitter ---
    spu_whisper_tx #(
        .CLK_HZ(12000000)
    ) u_whisper (
        .clk(`SPU_PIN_CLK), .reset(!`SPU_PIN_RST_N),
        .sync_in(whisper_sync),
        .tension_k(k_sim),
        .fault_in(over_curvature),
        .pulse_out(whisper_out)
    );

    // --- 4. The Laminar Sequencer ---
    reg [1:0] state;
    localparam IDLE=0, AUDIT=1;

    always @(posedge `SPU_PIN_CLK or negedge `SPU_PIN_RST_N) begin
        if (!`SPU_PIN_RST_N) begin
            state <= IDLE;
            audit_start <= 0;
        end else begin
            case (state)
                IDLE: if (timer[15:0] == 16'hFFFF) state <= AUDIT;
                AUDIT: begin
                    audit_start <= 1;
                    if (audit_ready) begin
                        audit_start <= 0;
                        state <= IDLE;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end

    // --- 5. Aura Mapping (Piranha PWM) ---
    reg [7:0] pwm_cnt;
    always @(posedge `SPU_PIN_CLK) pwm_cnt <= pwm_cnt + 1;

    assign `SPU_PIN_LED_R = (pwm_cnt < 8'hFF) && over_curvature;
    assign `SPU_PIN_LED_G = (pwm_cnt < 8'h7F) && !over_curvature;
    assign `SPU_PIN_LED_B = (pwm_cnt < 8'h3F) && whisper_out; // Flash Blue during Whisper

endmodule
