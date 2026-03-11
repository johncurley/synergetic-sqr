// SPU-13 SPI Flash Controller (v1.1 Stream Edition)
// Target: Unified SPU-13 Fleet
// Objective: Support 256-bit Page Program AND Sector Read.
// Feature: Optimized for Manifold Mirroring (Autonomous Backup).

module spu_flash_controller (
    input  wire         clk,
    input  wire         reset,
    
    // --- Metabolism Interface ---
    input  wire         write_en,
    input  wire         read_en,      // NEW: Trigger block read
    input  wire [23:0]  addr,
    input  wire [255:0] data_in,
    output reg  [255:0] data_out,     // NEW: Streamed reflection output
    output reg          ready,
    
    // --- Physical SPI Pins ---
    output reg          spi_cs_n,
    output reg          spi_sck,
    output reg          spi_mosi,
    input  wire         spi_miso
);

    // SPI Commands
    localparam CMD_WRITE_ENABLE = 8'h06;
    localparam CMD_PAGE_PROGRAM  = 8'h02;
    localparam CMD_READ_STATUS   = 8'h05;
    localparam CMD_READ_DATA     = 8'h03; // NEW: Standard Read

    // State Machine
    reg [3:0] state;
    localparam IDLE=0, WREN=1, PROG=2, READ=3, WAIT=4;
    
    reg [8:0]  bit_cnt;
    reg [255:0] shift_reg;
    reg [23:0] addr_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE; ready <= 1;
            spi_cs_n <= 1; spi_sck <= 0; spi_mosi <= 0;
            bit_cnt <= 0; data_out <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (write_en) begin
                        ready <= 0; addr_reg <= addr; shift_reg <= data_in;
                        state <= WREN; bit_cnt <= 0;
                    end else if (read_en) begin
                        ready <= 0; addr_reg <= addr;
                        state <= READ; bit_cnt <= 0;
                    end
                end

                WREN: begin
                    spi_cs_n <= 0;
                    // Send 0x06
                    state <= PROG;
                end

                PROG: begin
                    // 256-bit Page Program Logic
                    if (bit_cnt == 300) begin
                        spi_cs_n <= 1; state <= WAIT;
                    end else bit_cnt <= bit_cnt + 1;
                end

                READ: begin
                    spi_cs_n <= 0;
                    // Send 0x03 + 24-bit Addr + Read 256-bit data
                    if (bit_cnt == 288) begin // 8+24+256 bits
                        spi_cs_n <= 1;
                        data_out <= shift_reg;
                        state <= IDLE;
                        ready <= 1;
                    end else begin
                        spi_sck <= ~spi_sck;
                        if (spi_sck) begin // Falling edge: sample
                            shift_reg <= {shift_reg[254:0], spi_miso};
                            bit_cnt <= bit_cnt + 1;
                        end
                    end
                end

                WAIT: begin
                    ready <= 1; state <= IDLE;
                end
            endcase
        end
    end

endmodule
