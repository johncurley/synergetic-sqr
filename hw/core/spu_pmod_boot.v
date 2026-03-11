// SPU-13 PMOD Boot (v1.0)
// Target: Unified SPU-13 Fleet
// Objective: Identify the "Niche" of the attached PMOD cartridge.
// Logic: Asynchronous Signature Scan (Soul vs Ally vs Compiler).

module spu_pmod_boot (
    input  wire         clk,
    input  wire         reset,
    
    // SPI Interface to PMOD
    output reg          spi_cs_n,
    output reg          spi_sck,
    output reg          spi_mosi,
    input  wire         spi_miso,
    
    // Status Signals
    output reg  [1:0]   pmod_niche, // 0:None, 1:Soul, 2:Ally, 3:Compiler
    output reg          boot_ready
);

    // Signatures
    localparam SIG_SOUL = 32'h534F554C; // "SOUL"
    localparam SIG_ALLY = 32'h414C4C59; // "ALLY"
    localparam SIG_CMPL = 32'h434D504C; // "CMPL"

    // State Machine
    reg [3:0] state;
    localparam IDLE=0, READ_SIG=1, ANALYZE=2, DONE=3;
    
    reg [31:0] sig_buf;
    reg [5:0]  bit_cnt;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= READ_SIG;
            pmod_niche <= 0;
            boot_ready <= 0;
            spi_cs_n <= 1; spi_sck <= 0; spi_mosi <= 0;
            bit_cnt <= 0; sig_buf <= 0;
        end else begin
            case (state)
                READ_SIG: begin
                    spi_cs_n <= 0;
                    // Simplified SPI bit-banger to read first 32 bits
                    if (bit_cnt < 32) begin
                        spi_sck <= ~spi_sck;
                        if (spi_sck) begin // Falling edge: sample
                            sig_buf <= {sig_buf[30:0], spi_miso};
                            bit_cnt <= bit_cnt + 1;
                        end
                    end else begin
                        spi_cs_n <= 1;
                        state <= ANALYZE;
                    end
                end

                ANALYZE: begin
                    if (sig_buf == SIG_SOUL) pmod_niche <= 2'b01;
                    else if (sig_buf == SIG_ALLY) pmod_niche <= 2'b10;
                    else if (sig_buf == SIG_CMPL) pmod_niche <= 2'b11;
                    else pmod_niche <= 2'b00;
                    state <= DONE;
                end

                DONE: begin
                    boot_ready <= 1;
                end
            endcase
        end
    end

endmodule
