// metabolism_top.v - SPU-13 Sovereign Heartbeat (v1.0)
// Target: iCE40UP5K (iCeSugar UP5K)
// Objective: Internalized Metabolism with Interactive Sanity Calibration.
// Vitals: H (Happy), S (Stressed), R (Recovery)

`include "../../include/spu/spu13_pins.vh"

module top (
    input  wire `SPU_PIN_CLK,
    input  wire `SPU_PIN_RST_N,
    output wire `SPU_PIN_UART_TX,
    input  wire `SPU_PIN_UART_RX,
    output wire `SPU_PIN_LED_R,
    output wire `SPU_PIN_LED_G,
    output wire `SPU_PIN_LED_B
);

    // --- 1. The Mutable Gasket (Calibration) ---
    reg [63:0] tau_q_mutable;
    wire [7:0] rx_byte;
    wire rx_ready;

    uart_rx_mini #(.CLK_HZ(12000000), .BAUD(115200)) ears (
        .clk(`SPU_PIN_CLK), .rx_pin(`SPU_PIN_UART_RX),
        .rx_data(rx_byte), .rx_ready(rx_ready)
    );

    always @(posedge `SPU_PIN_CLK or negedge `SPU_PIN_RST_N) begin
        if (!`SPU_PIN_RST_N) begin
            tau_q_mutable <= 64'h00000000_00010000; // Initial tau^2 (1.0)
        end else if (rx_ready) begin
            if (rx_byte == 8'h2B) // '+' key
                tau_q_mutable <= tau_q_mutable + 64'h00000000_00001000;
            else if (rx_byte == 8'h2D) // '-' key
                tau_q_mutable <= tau_q_mutable - 64'h00000000_00001000;
        end
    end

    // --- 2. Internal Metabolism (The Inhale/Exhale) ---
    reg [24:0] timer;
    always @(posedge `SPU_PIN_CLK) timer <= timer + 1;
    // Simulated Curvature K (Triangle wave)
    wire [15:0] k_sim = timer[24] ? ~timer[23:8] : timer[23:8];

    // --- 3. Davis Gate & Henosis ---
    wire over_curvature;
    spu_davis_gate #(
        .WIDTH(16),
        .TAU_Q(64'h00000000_00010000) // Baseline for the gate
    ) u_gate (
        .a(k_sim), .b(16'h0), .c(16'h0), .d(16'h0),
        .over_curvature(over_curvature)
    );
    
    // Manual over_curvature check against the mutable threshold
    wire [31:0] q_sim = k_sim * k_sim;
    wire over_curved_dynamic = (q_sim > tau_q_mutable[31:0]);

    // --- 4. The Vocal Cords (Telemetry) ---
    reg [7:0] tx_data;
    wire tx_start = (timer[21:0] == 22'h1);
    
    always @(*) begin
        if (over_curved_dynamic) tx_data = 8'h52; // 'R'
        else if (q_sim > (tau_q_mutable[31:0] >> 1)) tx_data = 8'h53; // 'S'
        else tx_data = 8'h48; // 'H'
    end

    uart_tx_mini #(.CLK_HZ(12000000), .BAUD(115200)) vocal_cords (
        .clk(`SPU_PIN_CLK), .tx_start(tx_start), .tx_data(tx_data),
        .tx_pin(`SPU_PIN_UART_TX), .busy()
    );

    // --- 5. Aura Mapping (Piranha PWM) ---
    reg [7:0] pwm_cnt;
    always @(posedge `SPU_PIN_CLK) pwm_cnt <= pwm_cnt + 1;
    
    // Map Mood to Color
    // Happy = Green, Stressed = Blue, Recovery = Red
    assign `SPU_PIN_LED_R = (pwm_cnt < 8'hFF) && over_curved_dynamic;
    assign `SPU_PIN_LED_G = (pwm_cnt < 8'h7F) && (tx_data == 8'h48);
    assign `SPU_PIN_LED_B = (pwm_cnt < 8'h7F) && (tx_data == 8'h53);

endmodule
