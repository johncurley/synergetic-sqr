// SPU-13 PMOD Boot (v1.1 Inception Edition)
// Target: Unified SPU-13 Fleet
// Objective: Select between External PMOD Soul and Onboard Safe Soul.
// Logic: If PMOD SPI responds with 0x534F554C ("SOUL"), Guest overrules Host.

module spu_pmod_boot (
    input  wire         clk,
    input  wire         reset,
    
    // --- External PMOD SPI ---
    output reg          ext_spi_cs_n,
    output reg          ext_spi_sck,
    input  wire         ext_spi_miso,
    
    // --- Internal Flash SPI (Mapped to Host Pins) ---
    input  wire         int_flash_ready,
    
    // --- Boot Status ---
    output reg  [23:0]  soul_start_addr, // Resulting start address for Inhale
    output reg          use_external,    // 1: PMOD, 0: Onboard
    output reg          boot_ready
);

    // Sovereign Soul Signature
    localparam SIG_SOUL = 32'h534F554C; 

    // Internal Memory Offsets
    localparam ADDR_INTERNAL_SAFE = 24'h040000; // 256KB Offset for Safe Mode
    localparam ADDR_EXTERNAL_BASE = 24'h000000; // External Souls start at 0

    reg [3:0] state;
    localparam PROBE_EXT=0, ANALYZE=1, FALLBACK=2, DONE=3;
    
    reg [31:0] sig_buf;
    reg [5:0]  bit_cnt;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= PROBE_EXT;
            boot_ready <= 0;
            use_external <= 0;
            soul_start_addr <= ADDR_INTERNAL_SAFE;
            ext_spi_cs_n <= 1; ext_spi_sck <= 0;
            bit_cnt <= 0; sig_buf <= 0;
        end else begin
            case (state)
                PROBE_EXT: begin
                    ext_spi_cs_n <= 0;
                    if (bit_cnt < 32) begin
                        ext_spi_sck <= ~ext_spi_sck;
                        if (ext_spi_sck) begin // Falling edge
                            sig_buf <= {sig_buf[30:0], ext_spi_miso};
                            bit_cnt <= bit_cnt + 1;
                        end
                    end else begin
                        ext_spi_cs_n <= 1;
                        state <= ANALYZE;
                    end
                end

                ANALYZE: begin
                    if (sig_buf == SIG_SOUL) begin
                        use_external <= 1;
                        soul_start_addr <= ADDR_EXTERNAL_BASE;
                        state <= DONE;
                    end else begin
                        // No valid PMOD Soul found, initiate Fallback
                        state <= FALLBACK;
                    end
                end

                FALLBACK: begin
                    use_external <= 0;
                    soul_start_addr <= ADDR_INTERNAL_SAFE;
                    state <= DONE;
                end

                DONE: begin
                    boot_ready <= 1;
                end
            endcase
        end
    end

endmodule
