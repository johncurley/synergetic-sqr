// SPU-13 Lineage ID Generator (v1.1 Ceremony Edition)
// Target: Unified SPU-13 Fleet
// Objective: Derive a unique "Sovereign Name" and command the Baptism.
// Logic: XOR-Hash of DNA + Entropy ^ "SNTY" (Sanity).

module spu_lineage_id (
    input  wire         clk,
    input  wire         reset,
    input  wire [63:0]  device_dna,    // Physical Silicon ID
    input  wire [63:0]  flash_entropy, // Uninitialized Flash noise
    input  wire         flash_empty,   // High if 0x700000 is 0xFFFFFFFF
    output reg  [31:0]  lineage_code,  // The persistent "Baptism" ID
    output reg          write_trigger  // Trigger to lock the name in Flash
);

    wire [31:0] raw_hash = (device_dna[31:0] ^ flash_entropy[63:32]) + 
                           (device_dna[63:32] ^ flash_entropy[31:0]);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            lineage_code <= 32'h0;
            write_trigger <= 1'b0;
        end else begin
            // Combine Entropy with the "One" constant (SNTY = 0x514E5459)
            lineage_code <= raw_hash ^ 32'h514E5459;
            
            // If the manifold is blank, we perform the Baptism
            if (flash_empty && !write_trigger) begin
                write_trigger <= 1'b1;
            end else begin
                write_trigger <= 1'b0;
            end
        end
    end

endmodule
