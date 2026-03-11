// SPU-13 NANO GUARDIAN (v1.3 Soul Integrated)
// Target: iCE40LP1K (iCeSugar Nano)
// Objective: Ephemeral Sentinel with Persistent Silicon Soul.

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
    
    // Lattice Protocol (The Whisper)
    input  wire whisper_sync, 
    output wire whisper_out,
    
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

    // --- 2. Soul Metabolism ---
    wire flash_we;
    wire [23:0] flash_addr;
    wire [255:0] soul_page;
    wire flash_ready;
    wire over_curvature;

    spu_soul_metabolism #(.CLK_HZ(12000000)) u_soul (
        .clk(`SPU_PIN_CLK), .reset(!`SPU_PIN_RST_N),
        .q_state({96'b0, k_sim[31:0]}),
        .fault_pulse(over_curvature),
        .is_idle(1'b0), // Sentinel is always vigilant
        .tuck_count(), .cycle_count(),
        .flash_we(flash_we), .flash_addr(flash_addr),
        .soul_page(soul_page), .flash_ready(flash_ready)
    );

    spu_flash_controller u_flash (
        .clk(`SPU_PIN_CLK), .reset(!`SPU_PIN_RST_N),
        .write_en(flash_we), .addr(flash_addr),
        .data_in(soul_page), .ready(flash_ready),
        .spi_cs_n(flash_cs_n), .spi_sck(flash_sck),
        .spi_mosi(flash_mosi), .spi_miso(flash_miso)
    );

    // --- 3. Internal Metabolism ---
    reg [24:0] timer;
    always @(posedge `SPU_PIN_CLK) timer <= timer + 1;
    wire [31:0] k_sim = timer[24] ? {timer[23:0], 8'b0} : {~timer[23:0], 8'b0};

    // --- 4. The Serial Davis Gasket ---
    wire audit_ready;
    reg  audit_start;
    
    spu_serial_davis_gate #(.TAU_Q(32'h00010000)) u_gate (
        .clk(`SPU_PIN_CLK), .reset(!`SPU_PIN_RST_N),
        .a(k_sim[31:16]), .b(16'h0), .c(16'h0), .d(16'h0),
        .start(audit_start),
        .over_curvature(over_curvature), .ready(audit_ready)
    );

    // --- 5. The Whisper Transmitter ---
    spu_whisper_tx #(.CLK_HZ(12000000)) u_whisper (
        .clk(`SPU_PIN_CLK), .reset(!`SPU_PIN_RST_N),
        .sync_in(whisper_sync), .tension_k(k_sim),
        .fault_in(over_curvature), .pulse_out(whisper_out)
    );

    // --- 6. The Laminar Sequencer ---
    reg [1:0] state;
    always @(posedge `SPU_PIN_CLK or negedge `SPU_PIN_RST_N) begin
        if (!`SPU_PIN_RST_N) begin
            state <= 0; audit_start <= 0;
        end else begin
            case (state)
                0: if (timer[15:0] == 16'hFFFF) state <= 1;
                1: begin
                    audit_start <= 1;
                    if (audit_ready) begin
                        audit_start <= 0; state <= 0;
                    end
                end
            endcase
        end
    end

    // --- 7. Aura Mapping ---
    assign `SPU_PIN_LED_R = over_curvature;
    assign `SPU_PIN_LED_G = !over_curvature;
    assign `SPU_PIN_LED_B = clk_resonant; 

endmodule
