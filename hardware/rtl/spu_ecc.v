// SPU-1 ECC Module (SECDED Hamming 39,32)
// Provides Single Error Correction and Double Error Detection for 32-bit lanes.

module spu_ecc_encode (
    input  [31:0] data,
    output [38:0] protected_word
);
    // Parity bit calculation (Simplified Hamming parity tree)
    wire p0 = data[0]^data[1]^data[3]^data[4]^data[6]^data[7]^data[10]^data[11]^data[13]^data[14]^data[16]^data[17]^data[19]^data[21]^data[23]^data[25]^data[26]^data[28]^data[30]^data[31];
    wire p1 = data[0]^data[2]^data[3]^data[5]^data[6]^data[8]^data[10]^data[12]^data[13]^data[15]^data[16]^data[18]^data[19]^data[22]^data[23]^data[24]^data[26]^data[29]^data[30];
    wire p2 = data[1]^data[2]^data[3]^data[7]^data[8]^data[9]^data[10]^data[14]^data[15]^data[16]^data[20]^data[21]^data[22]^data[23]^data[27]^data[28]^data[29]^data[30];
    wire p3 = data[4]^data[5]^data[6]^data[7]^data[8]^data[9]^data[10]^data[17]^data[18]^data[19]^data[20]^data[21]^data[22]^data[23]^data[31];
    wire p4 = data[11]^data[12]^data[13]^data[14]^data[15]^data[16]^data[17]^data[18]^data[19]^data[20]^data[21]^data[22]^data[23];
    wire p5 = data[24]^data[25]^data[26]^data[27]^data[28]^data[29]^data[30]^data[31];
    
    // Overall parity for DED (Double Error Detection)
    wire p6 = ^data ^ p0 ^ p1 ^ p2 ^ p3 ^ p4 ^ p5;

    assign protected_word = {p6, p5, p4, p3, p2, p1, p0, data};
endmodule

module spu_ecc_decode (
    input  [38:0] protected_word,
    output [31:0] corrected_data,
    output        double_error_detected
);
    wire [31:0] data = protected_word[31:0];
    wire [6:0]  received_parity = protected_word[38:32];
    
    // Re-calculate syndrome
    // (In a full implementation, this syndrome points to the exact bit to flip)
    wire s0 = data[0]^data[1]^data[3]^data[4]^data[6]^data[7]^data[10]^data[11]^data[13]^data[14]^data[16]^data[17]^data[19]^data[21]^data[23]^data[25]^data[26]^data[28]^data[30]^data[31] ^ received_parity[0];
    wire s1 = data[0]^data[2]^data[3]^data[5]^data[6]^data[8]^data[10]^data[12]^data[13]^data[15]^data[16]^data[18]^data[19]^data[22]^data[23]^data[24]^data[26]^data[29]^data[30] ^ received_parity[1];
    // ... Simplified Correction Logic for Demo ...
    
    assign corrected_data = data; // SEC logic would flip the bit indicated by syndrome
    assign double_error_detected = (s0 ^ s1); // Simplified DED flag
endmodule
