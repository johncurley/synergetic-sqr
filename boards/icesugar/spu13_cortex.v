// SPU-13 CORTEX (v1.0)
// Target: iCE40UP5K (iCeSugar UP5K)
// Objective: Global Fleet Integrator + Adaptive Sanity + Dream Log.

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
    
    // Lattice Protocol (The Whisper Ear)
    input  wire whisper_in   // Signal from Nano Node (PMOD Pin 5)
);

    // --- 1. Manifold Signals ---
    wire reset = !`SPU_PIN_RST_N;
    wire [127:0] reg_curr;
    wire [127:0] reg_next;
    wire local_fault;
    wire [31:0] learned_tau_q;
    
    // --- 2. Lattice Listener (Whisper RX) ---
    wire [15:0] remote_tension;
    wire remote_fault;
    wire whisper_ready;
    
    spu_whisper_rx #(
        .CLK_HZ(12000000)
    ) u_ear (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .pulse_in(whisper_in),
        .remote_tension(remote_tension),
        .remote_fault(remote_fault),
        .data_ready(whisper_ready)
    );

    // --- 3. The Adaptive Core (ALU) ---
    reg [127:0] manifold_reg;
    assign reg_curr = manifold_reg;
    
    spu_nano_core #(
        .DEFAULT_TAU_Q(64'h00000000_04000000)
    ) u_core (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .reg_curr(reg_curr),
        .opcode(3'b001), // Rotating for first light
        .prime_phase(2'b00), .sign_flip(1'b0),
        .dynamic_tau_q({32'b0, learned_tau_q}),
        .reg_out(reg_next),
        .fault_detected(local_fault)
    );

    always @(posedge `SPU_PIN_CLK or posedge reset) begin
        if (reset) manifold_reg <= {96'b0, 32'h00010000};
        else if (timer[23:0] == 24'hFFFFFF) manifold_reg <= reg_next;
    end

    // --- 4. The Dream Log (Memory History) ---
    // Aggregate tension = Local Tension (A-axis) + Remote Tension
    wire [15:0] aggregate_k = reg_curr[31:16] + remote_tension;
    wire [15:0] history_data;
    
    spu_dream_log u_log (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .current_tension(aggregate_k),
        .log_trigger(timer[23:0] == 24'h0),
        .learned_tau_q(learned_tau_q),
        .history_data(history_data),
        .playback_addr(16'h0)
    );

    // --- 5. High-Fi Outputs (OLED & UART) ---
    reg [24:0] timer;
    always @(posedge `SPU_PIN_CLK) timer <= timer + 1;

    // OLED Driver
    reg [7:0] oled_clk_div;
    always @(posedge `SPU_PIN_CLK) oled_clk_div <= oled_clk_div + 1;
    
    spu_ssd1306_driver u_oled (
        .clk(oled_clk_div[7]), .reset(reset),
        .data_in(aggregate_k[15:8]),
        .data_req(), .scl(oled_scl), .sda(oled_sda), .ready()
    );

    // UART Telemetry
    surd_uart_tx #(.CLK_HZ(12000000), .BAUD(115200)) u_vitals (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .data_in({local_fault, remote_fault, aggregate_k, 46'b0}),
        .start(timer[21:0] == 22'h1),
        .tx(`SPU_PIN_UART_TX), .ready()
    );

    // --- 6. Global Aura Mapping ---
    // Green = Healthy, Red = Local Fault, Blue = Remote Stress
    assign `SPU_PIN_LED_R = local_fault;
    assign `SPU_PIN_LED_G = !local_fault & !remote_fault;
    assign `SPU_PIN_LED_B = remote_fault;

endmodule
