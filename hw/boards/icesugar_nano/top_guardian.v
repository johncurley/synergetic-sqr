// SPU-13 NANO GUARDIAN (v1.2 Sovereign Parity)
// Target: iCE40LP1K (iCeSugar Nano)
// Objective: Ephemeral Sentinel with Resonant Heart + Voice of Coherency.

`include "../../include/spu/spu13_pins.vh"

module top_guardian (
    input  wire `SPU_PIN_CLK,
    input  wire `SPU_PIN_RST_N,
    output wire `SPU_PIN_LED_R,
    output wire `SPU_PIN_LED_G,
    output wire `SPU_PIN_LED_B,
    
    // Vocal Cord (UART TX)
    output wire `SPU_PIN_UART_TX,
    
    // Lattice Protocol (The Whisper)
    input  wire whisper_sync, 
    output wire whisper_out   
);

    // --- 1. Temporal Axis (The Resonant Heart) ---
    wire clk_resonant;
    spu_resonant_heart #(.CLK_IN_HZ(12000000)) u_sovereign_heart (
        .clk_in(`SPU_PIN_CLK), .rst_n(`SPU_PIN_RST_N),
        .clk_resonant(clk_resonant)
    );

    // --- 2. Voice of Coherency (SANE Pulse) ---
    spu_whisper_sane #(.CLK_HZ(12000000), .BAUD(115200)) u_sane_voice (
        .clk(`SPU_PIN_CLK), .rst_n(`SPU_PIN_RST_N),
        .is_laminar(!over_curvature),
        .tx_pin(`SPU_PIN_UART_TX)
    );

    // --- 3. Internal Metabolism ---
    reg [24:0] timer;
    always @(posedge `SPU_PIN_CLK) timer <= timer + 1;
    wire [31:0] k_sim = timer[24] ? {timer[23:0], 8'b0} : {~timer[23:0], 8'b0};

    // --- 4. The Serial Davis Gasket ---
    wire over_curvature;
    wire audit_ready;
    reg  audit_start;
    
    spu_serial_davis_gate #(.TAU_Q(32'h00010000)) u_gate (
        .clk(`SPU_PIN_CLK), .reset(!`SPU_PIN_RST_N),
        .a(k_sim[31:16]), .b(16'h0), .c(16'h0), .d(16'h0),
        .start(audit_start),
        .over_curvature(over_curvature), .ready(audit_ready)
    );

    // --- 5. The Whisper Transmitter ---
    spu_whisper_tx #(.CLK_HZ(12000000)) u_whisper (
        .clk(`SPU_PIN_CLK), .reset(!`SPU_PIN_RST_N),
        .sync_in(whisper_sync), .tension_k(k_sim),
        .fault_in(over_curvature), .pulse_out(whisper_out)
    );

    // --- 6. The Laminar Sequencer ---
    reg [1:0] state;
    always @(posedge `SPU_PIN_CLK or negedge `SPU_PIN_RST_N) begin
        if (!`SPU_PIN_RST_N) begin
            state <= 0; audit_start <= 0;
        end else begin
            case (state)
                0: if (timer[15:0] == 16'hFFFF) state <= 1;
                1: begin
                    audit_start <= 1;
                    if (audit_ready) begin
                        audit_start <= 0; state <= 0;
                    end
                end
            endcase
        end
    end

    // --- 7. Aura Mapping ---
    assign `SPU_PIN_LED_R = over_curvature;
    assign `SPU_PIN_LED_G = !over_curvature;
    assign `SPU_PIN_LED_B = clk_resonant; 

endmodule
