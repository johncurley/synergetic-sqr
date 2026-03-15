// SPU-13 Instruction Decoder (v1.0)
// Objective: Unpack 64-bit Sovereign Words and dispatch to the HAL.
// Bridges the SDL3 Command Buffer to the physical Parabolic Projector.

module spu13_decoder (
    input  wire        clk,
    input  wire        reset,
    input  wire [63:0] inst_word,   // 64-bit Sovereign Word
    input  wire        inst_valid,  // Instruction strobe
    
    // Unpacked Outputs
    output reg [7:0]   opcode,
    output reg [11:0]  q_a,
    output reg [11:0]  q_b,
    output reg [11:0]  q_c,
    output reg [11:0]  q_d,
    output reg [7:0]   energy,
    output reg         trigger_draw
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            opcode <= 8'h0;
            q_a <= 12'h0; q_b <= 12'h0; q_c <= 12'h0; q_d <= 12'h0;
            energy <= 8'h0;
            trigger_draw <= 1'b0;
        end else if (inst_valid) begin
            // PACKING FORMAT (64-bit):
            // [63:56] Opcode
            // [55:44] Q_A (12-bit)
            // [43:32] Q_B (12-bit)
            // [31:24] Energy
            // [23:12] Q_C (12-bit)
            // [11:0]  Q_D (12-bit)
            
            opcode <= inst_word[63:56];
            q_a    <= inst_word[55:44];
            q_b    <= inst_word[43:32];
            energy <= inst_word[31:24];
            q_c    <= inst_word[23:12];
            q_d    <= inst_word[11:0];
            
            // Trigger drawing if Opcode is SDRAW_V (0x40) or SPROJ_P (0x41)
            trigger_draw <= (inst_word[63:56] == 8'h40 || inst_word[63:56] == 8'h41);
        end else begin
            trigger_draw <= 1'b0;
        end
    end

endmodule
