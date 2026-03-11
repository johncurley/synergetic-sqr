// SPU-13 CORTEX (v1.5 Geometric Finality)
// Target: iCE40UP5K (iCeSugar UP5K)
// Objective: Global Fleet Integrator with SQR Rotor + Sierpinski Nav.

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

    // --- 1. Temporal Axis (The Heartbeat) ---
    wire reset = !`SPU_PIN_RST_N;
    wire phi_heartbeat;
    wire clk_steady;
    
    spu_fractal_clk #(.CLK_IN_HZ(12000000)) u_heart (
        .clk_in(`SPU_PIN_CLK), .rst_n(`SPU_PIN_RST_N), .en(1'b1),
        .phi_heartbeat(phi_heartbeat), .clk_laminar(clk_steady)
    );

    // --- 2. SQR Rotor (The Dynamic Engine) ---
    wire [63:0] q_curr_a, q_curr_b, q_curr_c, q_curr_d;
    wire [63:0] q_next_a, q_next_b, q_next_c, q_next_d;
    reg  [63:0] reg_a, reg_b, reg_c, reg_d;
    
    assign {q_curr_d, q_curr_c, q_curr_b, q_curr_a} = {reg_d, reg_c, reg_b, reg_a};

    spu_sqr_rotor u_rotor (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .q_in_a(q_curr_a), .q_in_b(q_curr_b), .q_in_c(q_curr_c), .q_in_d(q_curr_d),
        .t_param(16'h2AAA), // 60-degree rational spread
        .q_out_a(q_next_a), .q_out_b(q_next_b), .q_out_c(q_next_c), .q_out_d(q_next_d)
    );

    reg [24:0] timer;
    always @(posedge `SPU_PIN_CLK or posedge reset) begin
        if (reset) begin
            {reg_d, reg_c, reg_b, reg_a} <= {192'b0, 64'h00000000_00010000};
            timer <= 0;
        end else begin
            timer <= timer + 1;
            if (phi_heartbeat && timer[20:0] == 21'h1FFFFF) begin
                {reg_d, reg_c, reg_b, reg_a} <= {q_next_d, q_next_c, q_next_b, q_next_a};
            end
        end
    end

    // --- 3. Sierpinski Navigation (The Map) ---
    wire [1:0] nav_level;
    wire is_in_void;
    spu_sierpinski_nav u_nav (
        .coord_x(reg_a[15:0]), .coord_y(reg_b[15:0]),
        .quadrant_level(nav_level), .is_in_void(is_in_void)
    );

    // --- 4. Vision (E-Ink & OLED) ---
    spu_eink_waveshare_driver #(.CLK_HZ(12000000)) u_eink (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .data_in({6'b0, nav_level}), // Map the navigation level to ink
        .start_refresh(timer[24:0] == 25'h1FFFFFF),
        .busy(), .spi_cs(eink_cs), .spi_dc(eink_dc), .spi_rst(eink_rst),
        .spi_busy_in(eink_busy_in), .spi_mosi(eink_mosi), .spi_sck(eink_sck)
    );

    spu_ssd1306_driver u_oled_drv (
        .clk(clk_steady), .reset(reset),
        .data_in(reg_a[7:0]), .data_req(),
        .scl(oled_scl), .sda(oled_sda), .ready()
    );

    // --- 5. Voice & Vitals ---
    spu_pwm_audio u_voice (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .sample_in(reg_a[31:0]), .audio_out(audio_out)
    );

    surd_uart_tx #(.CLK_HZ(12000000), .BAUD(115200)) u_vitals (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .data_in({is_in_void, 31'b0, reg_a[31:0]}),
        .start(timer[21:0] == 22'h1), .tx(`SPU_PIN_UART_TX), .ready()
    );

    // --- 6. Global Aura Mapping ---
    assign `SPU_PIN_LED_R = is_in_void | reset;
    assign `SPU_PIN_LED_G = !is_in_void & !reset;
    assign `SPU_PIN_LED_B = phi_heartbeat; 

endmodule
