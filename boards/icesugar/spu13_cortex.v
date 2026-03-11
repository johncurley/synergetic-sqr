// SPU-13 CORTEX (v1.4 Full Sensory Integration)
// Target: iCE40UP5K (iCeSugar UP5K)
// Objective: Global Fleet Integrator with OLED + E-Ink + Audio + Harmonic Strike.

`include "../../include/spu/spu13_pins.vh"

module top (
    input  wire `SPU_PIN_CLK,
    input  wire `SPU_PIN_RST_N,
    
    // Status Display (RGB LED)
    output wire `SPU_PIN_LED_R,
    output wire `SPU_PIN_LED_G,
    output wire `SPU_PIN_LED_B,
    
    // OLED Interface (PMOD C)
    output wire oled_scl,
    output wire oled_sda,
    
    // E-Ink Interface (PMOD A)
    output wire eink_cs,
    output wire eink_dc,
    output wire eink_rst,
    input  wire eink_busy_in,
    output wire eink_mosi,
    output wire eink_sck,
    
    // Audio PWM
    output wire audio_out,
    
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
        .clk_in(`SPU_PIN_CLK), .rst_n(`SPU_PIN_RST_N), .en(1'b1),
        .phi_heartbeat(phi_heartbeat), .clk_laminar(clk_steady)
    );

    // --- 2. Interaction Path (Harmonic Strike) ---
    wire [7:0] rx_data;
    wire rx_ready;
    wire [127:0] ripple_out;
    
    uart_rx_mini #(.CLK_HZ(12000000), .BAUD(115200)) u_ear (
        .clk(`SPU_PIN_CLK), .rx_pin(`SPU_PIN_UART_RX),
        .rx_data(rx_data), .rx_ready(rx_ready)
    );

    spu_harmonic_transducer u_hammer (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .ascii_in(rx_data), .data_valid(rx_ready),
        .ripple_out(ripple_out), .membrane_lock()
    );

    // --- 3. The Adaptive Core (ALU) ---
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
        .reg_curr(reg_curr + ripple_out),
        .opcode(3'b001), .prime_phase(2'b00), .sign_flip(1'b0),
        .dynamic_tau_q({32'b0, learned_tau_q}),
        .reg_out(reg_next), .fault_detected(local_fault)
    );

    reg [24:0] timer;
    always @(posedge `SPU_PIN_CLK or posedge reset) begin
        if (reset) begin
            manifold_reg <= {96'b0, 32'h00010000};
            timer <= 0;
        end else begin
            timer <= timer + 1;
            if (phi_heartbeat && timer[20:0] == 21'h1FFFFF) manifold_reg <= reg_next;
        end
    end

    // --- 4. Vision (OLED Visualizer) ---
    wire [7:0] pixel_data;
    wire [9:0] pixel_idx;
    spu_oled_visualizer u_oled_vis (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .manifold_a(reg_curr[31:0]),
        .microwatts(16'd12),
        .pixel_data(pixel_data), .pixel_idx(pixel_idx), .frame_sync()
    );

    spu_ssd1306_driver u_oled_drv (
        .clk(clk_steady), .reset(reset),
        .data_in(pixel_data), .data_req(),
        .scl(oled_scl), .sda(oled_sda), .ready()
    );

    // --- 5. Persistence (E-Ink Driver) ---
    // The E-Ink only refreshes on a slow cycle (every ~10 seconds)
    wire eink_start = (timer[24:0] == 25'h1FFFFFF);
    
    spu_eink_waveshare_driver #(
        .CLK_HZ(12000000)
    ) u_eink (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .data_in(reg_curr[7:0]),
        .start_refresh(eink_start),
        .busy(),
        .spi_cs(eink_cs), .spi_dc(eink_dc), .spi_rst(eink_rst),
        .spi_busy_in(eink_busy_in),
        .spi_mosi(eink_mosi), .spi_sck(eink_sck)
    );

    // --- 6. Voice (Audio PWM) ---
    spu_pwm_audio u_voice (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .sample_in(reg_curr[31:0]),
        .audio_out(audio_out)
    );

    // --- 7. Global Vitals (UART) ---
    surd_uart_tx #(.CLK_HZ(12000000), .BAUD(115200)) u_vitals (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .data_in({local_fault, 31'b0, reg_curr[31:0]}),
        .start(timer[21:0] == 22'h1),
        .tx(`SPU_PIN_UART_TX), .ready()
    );

    // --- 8. Global Aura Mapping ---
    assign `SPU_PIN_LED_R = local_fault | reset;
    assign `SPU_PIN_LED_G = !local_fault & !reset;
    assign `SPU_PIN_LED_B = phi_heartbeat; 

endmodule
