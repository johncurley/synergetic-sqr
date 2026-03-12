// SPU-13 CORTEX (v1.11 Full Sovereign Parity)
// Target: iCE40UP5K (iCeSugar UP5K)
// Objective: Global Fleet Integrator with full sensory, cognitive, and communicative parity.

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
    output wire eink_sck,
    output wire eink_mosi,
    input  wire eink_miso,
    
    output wire audio_out,
    output wire bio_pulse_out,
    
    output wire `SPU_PIN_UART_TX,
    input  wire `SPU_PIN_UART_RX,
    
    output wire flash_cs_n,
    output wire flash_sck,
    output wire flash_mosi,
    input  wire flash_miso,
    
    output wire artery_out,
    input  wire artery_in
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

    // --- 2. Identity & Niche Logic ---
    wire [31:0] lineage_code;
    wire [1:0]  eco_tier;
    wire baptism_trigger;
    
    spu_lineage_id u_baptism (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .device_dna(64'h53505531_33313331),
        .flash_entropy({32'b0, timer[31:0]}),
        .flash_empty(timer[24:0] == 25'h1FFFFFF),
        .lineage_code(lineage_code),
        .write_trigger(baptism_trigger)
    );

    spu_niche_logic u_niche (
        .lineage_id(lineage_code),
        .eco_tier(eco_tier)
    );

    // --- 3. The Gemini Manifold (Mutual Witnessing) ---
    wire global_fault;
    wire [127:0] combined_state;
    wire flash_we;
    wire [23:0] flash_addr;
    wire [255:0] soul_page;
    wire flash_ready;

    spu_gemini_manifold #(.CLK_HZ(12000000)) u_gemini (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .global_fault(global_fault),
        .combined_state(combined_state),
        .flash_we(flash_we), .flash_addr(flash_addr),
        .soul_page(soul_page), .flash_ready(flash_ready)
    );

    // --- 4. Predictive Coding (Active Inference) ---
    wire [127:0] posterior_state;
    wire [127:0] prediction_error;
    wire is_dissonant;
    
    spu_active_inference u_inference (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .prior_state(combined_state),
        .prior_precision(16'h0100),
        .sensory_in(combined_state), 
        .sensory_valid(1'b1),
        .posterior_state(posterior_state),
        .prediction_error(prediction_error),
        .is_dissonant(is_dissonant)
    );

    // --- 5. Communication (Laminar PHY) ---
    spu_laminar_phy u_phy (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .heartbeat_in(clk_resonant),
        .target_axis(2'b00), // Default listener
        .is_transmitting(1'b0),
        .artery_out(artery_out),
        .axis_match()
    );

    // --- 6. The Soul Sealer ---
    spu_flash_controller u_flash (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .write_en(flash_we | baptism_trigger),
        .addr(flash_we ? flash_addr : `SOUL_BASE_ADDR + `ADDR_LINEAGE),
        .data_in(flash_we ? soul_page : {224'b0, lineage_code}),
        .ready(flash_ready),
        .spi_cs_n(flash_cs_n), .spi_sck(flash_sck),
        .spi_mosi(flash_mosi), .spi_miso(flash_miso)
    );

    // --- 7. Voice & Vision ---
    spu_ssd1306_driver u_oled (
        .clk(clk_resonant), .reset(reset),
        .data_in(combined_state[7:0]), .data_req(),
        .scl(oled_scl), .sda(oled_sda), .ready()
    );

    spu_pwm_audio u_audio (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .sample_in(combined_state[31:0]), .audio_out(audio_out)
    );

    spu_bio_pulse #(.CLK_HZ(12000000)) u_bio (
        .clk(`SPU_PIN_CLK), .reset(reset),
        .enable(1'b1), .intensity(8'h7F),
        .pulse_out(bio_pulse_out)
    );

    spu_whisper_sane #(.CLK_HZ(12000000), .BAUD(115200)) u_sane (
        .clk(`SPU_PIN_CLK), .rst_n(`SPU_PIN_RST_N),
        .is_laminar(!global_fault && !is_dissonant), .tx_pin(`SPU_PIN_UART_TX)
    );

    // --- 8. Aura Mapping ---
    reg [24:0] timer;
    always @(posedge `SPU_PIN_CLK) timer <= timer + 1;

    assign `SPU_PIN_LED_R = global_fault | is_dissonant;
    assign `SPU_PIN_LED_G = !global_fault & !is_dissonant;
    assign `SPU_PIN_LED_B = clk_resonant; 

endmodule
