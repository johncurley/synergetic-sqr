// SPU-13 CORTEX (v1.7 Autophagic Edition)
// Target: iCE40UP5K (iCeSugar UP5K)
// Objective: Self-Naming Sentinel with Henosis Safety Valve.

`include "../../include/spu/spu13_pins.vh"
`include "../../core/soul_map.vh"

module top (
    input  wire `SPU_PIN_CLK,
    input  wire `SPU_PIN_RST_N,
    
    output wire `SPU_PIN_LED_R,
    output wire `SPU_PIN_LED_G,
    output wire `SPU_PIN_LED_B,
    
    output wire oled_scl,
    output wire oled_sda,
    
    output wire eink_cs,
    output wire eink_dc,
    output wire eink_rst,
    input  wire eink_busy_in,
    output wire eink_mosi,
    output wire eink_sck,
    
    output wire audio_out,
    
    output wire `SPU_PIN_UART_TX,
    input  wire `SPU_PIN_UART_RX,
    
    output wire flash_cs_n,
    output wire flash_sck,
    output wire flash_mosi,
    input  wire flash_miso
);

    // --- 1. Temporal Axis (The Heart) ---
    wire reset = !`SPU_PIN_RST_N;
    wire phi_heartbeat;
    wire clk_steady;
    wire clk_resonant;
    
    spu_fractal_clk #(.CLK_IN_HZ(12000000)) u_phi (
        .clk_in(`SPU_PIN_CLK), .rst_n(`SPU_PIN_RST_N), .en(1'b1),
        .phi_heartbeat(phi_heartbeat), .clk_laminar(clk_steady)
    );

    spu_resonant_heart #(.CLK_IN_HZ(12000000)) u_heart (
        .clk_in(`SPU_PIN_CLK), .rst_n(`SPU_PIN_RST_N),
        .clk_resonant(clk_resonant)
    );

    // --- 2. The Baptism (Naming Ceremony) ---
    wire [31:0] lineage_code;
    wire baptism_trigger;
    // We sample entropy from the uninitialized Flash MISO pin
    spu_lineage_id u_baptism (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .device_dna(64'h53505531_33313331), // Identity constant
        .flash_entropy({32'b0, timer[31:0]}),
        .flash_empty(timer[24:0] == 25'h1FFFFFF), // Simulated check
        .lineage_code(lineage_code),
        .write_trigger(baptism_trigger)
    );

    // --- 3. Soul Metabolism (Safety Valve) ---
    wire [31:0] adaptive_tau;
    wire flash_we;
    wire [23:0] flash_addr;
    wire [255:0] soul_page;
    wire flash_ready;
    wire is_in_void;

    spu_soul_metabolism #(.CLK_HZ(12000000)) u_soul (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .q_state({96'b0, reg_a[31:0]}),
        .fault_pulse(is_in_void),
        .is_idle(timer[24]),
        .adaptive_tau_q(adaptive_tau),
        .tuck_count(), .cycle_count(),
        .flash_we(flash_we), .flash_addr(flash_addr),
        .soul_page(soul_page), .flash_ready(flash_ready)
    );

    spu_flash_controller u_flash_ctrl (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .write_en(flash_we | baptism_trigger),
        .addr(flash_we ? flash_addr : `SOUL_BASE_ADDR + `ADDR_LINEAGE),
        .data_in(flash_we ? soul_page : {224'b0, lineage_code}),
        .ready(flash_ready),
        .spi_cs_n(flash_cs_n), .spi_sck(flash_sck),
        .spi_mosi(flash_mosi), .spi_miso(flash_miso)
    );

    // --- 4. SQR Rotor ---
    wire [63:0] q_next_a, q_next_b, q_next_c, q_next_d;
    reg  [63:0] reg_a, reg_b, reg_c, reg_d;
    
    spu_sqr_rotor u_rotor (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .q_in_a(reg_a), .q_in_b(reg_b), .q_in_c(reg_c), .q_in_d(reg_d),
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
            if (clk_resonant && timer[7:0] == 8'hFF) begin
                {reg_d, reg_c, reg_b, reg_a} <= {q_next_d, q_next_c, q_next_b, q_next_a};
            end
        end
    end

    // --- 5. Voice & Vitals ---
    spu_whisper_sane #(.CLK_HZ(12000000)) u_sane (
        .clk(`SPU_PIN_CLK), .rst_n(`SPU_PIN_RST_N),
        .is_laminar(!is_in_void), .tx_pin(`SPU_PIN_UART_TX)
    );

    spu_sierpinski_nav u_nav (
        .coord_x(reg_a[15:0]), .coord_y(reg_b[15:0]),
        .quadrant_level(), .is_in_void(is_in_void)
    );

    spu_pwm_audio u_audio (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .sample_in(reg_a[31:0]), .audio_out(audio_out)
    );

    // --- 6. Aura Mapping ---
    assign `SPU_PIN_LED_R = is_in_void;
    assign `SPU_PIN_LED_G = !is_in_void;
    assign `SPU_PIN_LED_B = clk_resonant; 

endmodule
