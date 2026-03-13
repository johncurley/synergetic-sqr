// SPU-13 Laminar Listener (v1.0)
// Target: Unified SPU-13 Fleet
// Objective: Tiny (<100 LUTs) remote bytecode listener for "Fused" IDE workflow.
// Vibe: The Remote Synapse.

module spu_laminar_listener (
    input  wire        clk,
    input  wire        reset,
    
    // Remote Input (from Artery or UART)
    input  wire        rx_valid,
    input  wire [7:0]  rx_data,
    
    // Instruction Memory Interface
    output reg  [7:0]  mem_addr,
    output reg  [15:0] mem_data,
    output reg         mem_we
);

    reg [1:0] state;
    localparam IDLE=0, BYTE_HIGH=1, BYTE_LOW=2, WRITE=3;
    
    reg [7:0] high_byte;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            mem_addr <= 0;
            mem_data <= 0;
            mem_we <= 0;
        end else begin
            case (state)
                IDLE: begin
                    mem_we <= 0;
                    if (rx_valid) begin
                        if (rx_data == 8'h53) begin // 'S' - Sync Start
                            mem_addr <= 0;
                            state <= BYTE_HIGH;
                        end
                    end
                end

                BYTE_HIGH: begin
                    if (rx_valid) begin
                        high_byte <= rx_data;
                        state <= BYTE_LOW;
                    end
                end

                BYTE_LOW: begin
                    if (rx_valid) begin
                        mem_data <= {high_byte, rx_data};
                        state <= WRITE;
                    end
                end

                WRITE: begin
                    mem_we <= 1;
                    mem_addr <= mem_addr + 1;
                    state <= BYTE_HIGH; // Continue reading word pairs
                    
                    // Stop if we see a sentinel or reach end of 256-word page
                    if (mem_data == 16'hFFFF || mem_addr == 8'hFF) state <= IDLE;
                end
            endcase
        end
    end

endmodule
