// SPU-13 CORTEX (v1.1 Biological Heartbeat)
// Target: iCE40UP5K (iCeSugar UP5K)
// Objective: Global Fleet Integrator with Phi-Gated Timing.

`include "../../include/spu/spu13_pins.vh"

module top (
    input  wire `SPU_PIN_CLK,
    input  wire `SPU_PIN_RST_N,
    
    // Status Display (RGB LED)
    output wire `SPU_PIN_LED_R,
    output wire `SPU_PIN_LED_G,
    output wire `SPU_PIN_LED_B,
    
    // OLED Interface
    output wire oled_scl,
    output wire oled_sda,
    
    // Interaction
    output wire `SPU_PIN_UART_TX,
    input  wire `SPU_PIN_UART_RX,
    
    // Lattice Protocol
    input  wire whisper_in   
);

    // --- 1. Temporal Axis (The Heartbeat) ---
    wire reset = !`SPU_PIN_RST_N;
    wire phi_heartbeat;
    wire clk_steady;
    
    spu_fractal_clk #(
        .CLK_IN_HZ(12000000)
    ) u_heart (
        .clk_in(`SPU_PIN_CLK),
        .rst_n(`SPU_PIN_RST_N),
        .en(1'b1),
        .phi_heartbeat(phi_heartbeat),
        .clk_laminar(clk_steady)
    );

    // --- 2. Manifold Signals ---
    wire [127:0] reg_curr;
    wire [127:0] reg_next;
    wire local_fault;
    wire [31:0] learned_tau_q;
    
    // --- 3. The Adaptive Core (ALU) ---
    reg [127:0] manifold_reg;
    assign reg_curr = manifold_reg;
    
    spu_nano_core #(
        .DEFAULT_TAU_Q(64'h00000000_04000000)
    ) u_core (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .reg_curr(reg_curr),
        .opcode(3'b001), 
        .prime_phase(2'b00), .sign_flip(1'b0),
        .dynamic_tau_q({32'b0, learned_tau_q}),
        .reg_out(reg_next),
        .fault_detected(local_fault)
    );

    // --- 4. The Laminar Sequencer (Phi-Driven) ---
    reg [24:0] step_timer;
    always @(posedge `SPU_PIN_CLK or posedge reset) begin
        if (reset) begin
            manifold_reg <= {96'b0, 32'h00010000};
            step_timer <= 0;
        end else if (phi_heartbeat) begin
            // Evolution occurs only on the recursive pulses
            if (step_timer[23:0] == 24'hFFFFFF) begin
                manifold_reg <= reg_next;
                step_timer <= 0;
            end else begin
                step_timer <= step_timer + 1;
            end
        end
    end

    // --- 5. The Dream Log (Memory History) ---
    wire [15:0] aggregate_k = reg_curr[31:16];
    
    spu_dream_log u_log (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .current_tension(aggregate_k),
        .is_idle(aggregate_k < 16'h0100),
        .learned_tau_q(learned_tau_q),
        .history_data(),
        .playback_addr(16'h0)
    );

    // --- 6. High-Fi Outputs ---
    spu_ssd1306_driver u_oled (
        .clk(clk_steady), .reset(reset),
        .data_in(aggregate_k[15:8]),
        .data_req(), .scl(oled_scl), .sda(oled_sda), .ready()
    );

    surd_uart_tx #(.CLK_HZ(12000000), .BAUD(115200)) u_vitals (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .data_in({local_fault, 31'b0, reg_curr[31:0]}),
        .start(step_timer[21:0] == 22'h1),
        .tx(`SPU_PIN_UART_TX), .ready()
    );

    // --- 7. Global Aura Mapping ---
    assign `SPU_PIN_LED_R = local_fault;
    assign `SPU_PIN_LED_G = !local_fault;
    assign `SPU_PIN_LED_B = phi_heartbeat; // Blue flicker follows the Phi pulse

endmodule
