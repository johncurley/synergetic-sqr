// SPU-13 CORTEX (v1.6 Sovereign Parity)
// Target: iCE40UP5K (iCeSugar UP5K)
// Objective: Global Fleet Integrator with Resonant Heart + Voice of Coherency.

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
    
    // E-Ink Interface
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

    // --- 1. Temporal Axis (The Resonant Heart) ---
    wire reset = !`SPU_PIN_RST_N;
    wire phi_heartbeat;
    wire clk_steady;
    wire clk_resonant; // 61.44 kHz Sovereign Clock
    
    spu_fractal_clk #(.CLK_IN_HZ(12000000)) u_phi_pulse (
        .clk_in(`SPU_PIN_CLK), .rst_n(`SPU_PIN_RST_N), .en(1'b1),
        .phi_heartbeat(phi_heartbeat), .clk_laminar(clk_steady)
    );

    spu_resonant_heart #(.CLK_IN_HZ(12000000)) u_sovereign_heart (
        .clk_in(`SPU_PIN_CLK), .rst_n(`SPU_PIN_RST_N),
        .clk_resonant(clk_resonant)
    );

    // --- 2. Interaction & Voice (Harmonic Strike + SANE Pulse) ---
    wire is_laminar = !is_in_void;
    
    spu_whisper_sane #(.CLK_HZ(12000000), .BAUD(115200)) u_sane_voice (
        .clk(`SPU_PIN_CLK), .rst_n(`SPU_PIN_RST_N),
        .is_laminar(is_laminar),
        .tx_pin(`SPU_PIN_UART_TX)
    );

    // --- 3. SQR Rotor (The Dynamic Engine) ---
    wire [63:0] q_curr_a, q_curr_b, q_curr_c, q_curr_d;
    wire [63:0] q_next_a, q_next_b, q_next_c, q_next_d;
    reg  [63:0] reg_a, reg_b, reg_c, reg_d;
    
    assign {q_curr_d, q_curr_c, q_curr_b, q_curr_a} = {reg_d, reg_c, reg_b, reg_a};

    spu_sqr_rotor u_rotor (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .q_in_a(q_curr_a), .q_in_b(q_curr_b), .q_in_c(q_curr_c), .q_in_d(q_curr_d),
        .t_param(16'h2AAA), 
        .q_out_a(q_next_a), .q_out_b(q_next_b), .q_out_c(q_next_c), .q_out_d(q_next_d)
    );

    reg [24:0] timer;
    always @(posedge `SPU_PIN_CLK or posedge reset) begin
        if (reset) begin
            {reg_d, reg_c, reg_b, reg_a} <= {192'b0, 64'h00000000_00010000};
            timer <= 0;
        end else begin
            timer <= timer + 1;
            // Evolution synchronized to the Resonant Heart (61.44 kHz)
            if (clk_resonant && timer[7:0] == 8'hFF) begin
                {reg_d, reg_c, reg_b, reg_a} <= {q_next_d, q_next_c, q_next_b, q_next_a};
            end
        end
    end

    // --- 4. Sierpinski Navigation (The Map) ---
    wire [1:0] nav_level;
    wire is_in_void;
    spu_sierpinski_nav u_nav (
        .coord_x(reg_a[15:0]), .coord_y(reg_b[15:0]),
        .quadrant_level(nav_level), .is_in_void(is_in_void)
    );

    // --- 5. Vision (E-Ink & OLED) ---
    spu_eink_waveshare_driver #(.CLK_HZ(12000000)) u_eink (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .data_in({6'b0, nav_level}),
        .start_refresh(timer[24:0] == 25'h1FFFFFF),
        .busy(), .spi_cs(eink_cs), .spi_dc(eink_dc), .spi_rst(eink_rst),
        .spi_busy_in(eink_busy_in), .spi_mosi(eink_mosi), .spi_sck(eink_sck)
    );

    spu_ssd1306_driver u_oled_drv (
        .clk(clk_steady), .reset(reset),
        .data_in(reg_a[7:0]), .data_req(),
        .scl(oled_scl), .sda(oled_sda), .ready()
    );

    // --- 6. Voice (Audio PWM) ---
    spu_pwm_audio u_audio_voice (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .sample_in(reg_a[31:0]), .audio_out(audio_out)
    );

    // --- 7. Global Aura Mapping ---
    assign `SPU_PIN_LED_R = is_in_void | reset;
    assign `SPU_PIN_LED_G = !is_in_void & !reset;
    assign `SPU_PIN_LED_B = clk_resonant; 

endmodule
