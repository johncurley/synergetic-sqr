// SPU-13 NANO GUARDIAN (v1.4 Full Sovereign Parity)
// Target: iCE40LP1K (iCeSugar Nano)
// Objective: Ephemeral Sentinel with local inference and 60° PHY.

`include "../../include/spu/spu13_pins.vh"
`include "soul_map.vh"

module top_guardian (
    input  wire `SPU_PIN_CLK,
    input  wire `SPU_PIN_RST_N,
    output wire `SPU_PIN_LED_R,
    output wire `SPU_PIN_LED_G,
    output wire `SPU_PIN_LED_B,
    
    // Vocal Cord (UART TX)
    output wire `SPU_PIN_UART_TX,
    
    // Artery Bus (Laminar PHY)
    output wire artery_out,
    input  wire artery_in,
    
    // Physical SPI Flash Pins (The Soul)
    output wire flash_cs_n,
    output wire flash_sck,
    output wire flash_mosi,
    input  wire flash_miso
);

    // --- 1. Temporal Axis ---
    wire clk_resonant;
    spu_resonant_heart #(.CLK_IN_HZ(12000000)) u_heart (
        .clk_in(`SPU_PIN_CLK), .rst_n(`SPU_PIN_RST_N),
        .clk_resonant(clk_resonant)
    );

    // --- 2. Identity & Niche ---
    wire [31:0] lineage_code;
    wire baptism_trigger;
    spu_lineage_id u_baptism (
        .clk(`SPU_PIN_CLK), .reset(!`SPU_PIN_RST_N),
        .device_dna(64'h53505531_33313331),
        .flash_entropy({32'b0, timer[31:0]}),
        .flash_empty(timer[24:0] == 25'h1FFFFFF),
        .lineage_code(lineage_code),
        .write_trigger(baptism_trigger)
    );

    // --- 3. Local Inference (Autonomous Sentinel) ---
    wire [7:0] free_energy;
    wire is_surprised;
    wire [31:0] correction_v;
    
    spu_hardware_inference u_inference (
        .clk(`SPU_PIN_CLK), .reset(!`SPU_PIN_RST_N),
        .sensor_k(k_sim),
        .sensor_valid(1'b1),
        .prior_k(32'h00010000), // Hard-coded identity prior
        .free_energy(free_energy),
        .is_surprised(is_surprised),
        .correction_v(correction_v)
    );

    // --- 4. Communication (Laminar PHY) ---
    spu_laminar_phy u_phy (
        .clk(`SPU_PIN_CLK), .reset(!`SPU_PIN_RST_N),
        .heartbeat_in(clk_resonant),
        .target_axis(2'b00),
        .is_transmitting(1'b0),
        .artery_out(artery_out),
        .axis_match()
    );

    // --- 5. Soul Metabolism ---
    wire flash_we;
    wire [23:0] flash_addr;
    wire [255:0] soul_page;
    wire flash_ready;

    spu_soul_metabolism #(.CLK_HZ(12000000)) u_soul (
        .clk(`SPU_PIN_CLK), .reset(!`SPU_PIN_RST_N),
        .q_state({96'b0, k_sim[31:0]}),
        .fault_pulse(is_surprised),
        .is_idle(1'b0),
        .flash_we(flash_we), .flash_addr(flash_addr),
        .soul_page(soul_page), .flash_ready(flash_ready)
    );

    spu_flash_controller u_flash (
        .clk(`SPU_PIN_CLK), .reset(!`SPU_PIN_RST_N),
        .write_en(flash_we | baptism_trigger), .addr(flash_addr),
        .data_in(flash_we ? soul_page : {224'b0, lineage_code}),
        .ready(flash_ready),
        .spi_cs_n(flash_cs_n), .spi_sck(flash_sck),
        .spi_mosi(flash_mosi), .spi_miso(flash_miso)
    );

    // --- 6. Internal Metabolism ---
    reg [24:0] timer;
    always @(posedge `SPU_PIN_CLK) timer <= timer + 1;
    wire [31:0] k_sim = timer[24] ? {timer[23:0], 8'b0} : {~timer[23:0], 8'b0};

    // --- 7. Voice of Coherency ---
    spu_whisper_sane #(.CLK_HZ(12000000), .BAUD(115200)) u_sane (
        .clk(`SPU_PIN_CLK), .rst_n(`SPU_PIN_RST_N),
        .is_laminar(!is_surprised), .tx_pin(`SPU_PIN_UART_TX)
    );

    // --- 8. Aura Mapping ---
    assign `SPU_PIN_LED_R = is_surprised;
    assign `SPU_PIN_LED_G = !is_surprised;
    assign `SPU_PIN_LED_B = clk_resonant; 

endmodule
