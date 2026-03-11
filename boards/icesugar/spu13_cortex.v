// SPU-13 CORTEX (v1.2 Lithic Artery)
// Target: iCE40UP5K (iCeSugar UP5K)
// Objective: Global Fleet Integrator with Quartz-Inspired Artery Flow.

`include "../../include/spu/spu13_pins.vh"

module top (
    input  wire `SPU_PIN_CLK,
    input  wire `SPU_PIN_RST_N,
    
    // Status Display (RGB LED)
    output wire `SPU_PIN_LED_R,
    output wire `SPU_PIN_LED_G,
    output wire `SPU_PIN_LED_B,
    
    // Interaction
    output wire `SPU_PIN_UART_TX,
    input  wire `SPU_PIN_UART_RX,
    
    // Lithic Artery Interface
    output wire main_flow_out,
    output wire sub_flow_l,
    output wire sub_flow_r,
    input  wire manual_tuck   // Active Low Button
);

    // --- 1. The Physical Aorta (GBUF Distribution) ---
    wire reset = !`SPU_PIN_RST_N || !manual_tuck;
    wire phi_heartbeat_raw;
    wire clk_steady;
    wire phi_heartbeat; // Phase-locked global heartbeat
    
    spu_fractal_clk #(
        .CLK_IN_HZ(12000000)
    ) u_heart_gen (
        .clk_in(`SPU_PIN_CLK), .rst_n(`SPU_PIN_RST_N), .en(1'b1),
        .phi_heartbeat(phi_heartbeat_raw), .clk_laminar(clk_steady)
    );

    // Force the Heartbeat onto the Global Buffer network
    spu_artery_phy u_aorta (
        .raw_heartbeat(phi_heartbeat_raw),
        .global_heartbeat(phi_heartbeat)
    );

    // --- 2. Manifold & Core ---
    wire [127:0] reg_curr;
    wire [127:0] reg_next;
    wire local_fault;
    wire [31:0] learned_tau_q;
    
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

    reg [24:0] step_timer;
    always @(posedge `SPU_PIN_CLK or posedge reset) begin
        if (reset) begin
            manifold_reg <= {96'b0, 32'h00010000};
            step_timer <= 0;
        end else if (phi_heartbeat) begin
            if (step_timer[23:0] == 24'hFFFFFF) begin
                manifold_reg <= reg_next;
                step_timer <= 0;
            end else begin
                step_timer <= step_timer + 1;
            end
        end
    end

    // --- 3. The Lithic Artery (Energy Distribution) ---
    wire [15:0] aggregate_k = reg_curr[31:16];
    wire [15:0] main_flow, s_flow_l, s_flow_r;
    
    spu_artery u_artery (
        .energy_in(aggregate_k),
        .main_flow(main_flow),
        .sub_flow_l(s_flow_l),
        .sub_flow_r(s_flow_r)
    );
    
    // PWM output for physical observation of branching
    reg [7:0] artery_pwm;
    always @(posedge `SPU_PIN_CLK) artery_pwm <= artery_pwm + 1;
    
    assign main_flow_out = (artery_pwm < main_flow[15:8]);
    assign sub_flow_l    = (artery_pwm < s_flow_l[15:8]);
    assign sub_flow_r    = (artery_pwm < s_flow_r[15:8]);

    // --- 4. The Dream Log ---
    spu_dream_log u_log (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .current_tension(aggregate_k),
        .is_idle(aggregate_k < 16'h0100),
        .learned_tau_q(learned_tau_q),
        .history_data(), .playback_addr(16'h0)
    );

    // --- 5. Global Vitals (UART) ---
    surd_uart_tx #(.CLK_HZ(12000000), .BAUD(115200)) u_vitals (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .data_in({local_fault, 31'b0, reg_curr[31:0]}),
        .start(step_timer[21:0] == 22'h1),
        .tx(`SPU_PIN_UART_TX), .ready()
    );

    // --- 6. Global Aura Mapping ---
    assign `SPU_PIN_LED_R = local_fault | !`SPU_PIN_RST_N;
    assign `SPU_PIN_LED_G = !local_fault & `SPU_PIN_RST_N;
    assign `SPU_PIN_LED_B = phi_heartbeat; 

endmodule
