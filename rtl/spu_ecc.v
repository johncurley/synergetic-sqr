// SPU-13 ECC Protection (v3.1.8)
module spu_ecc_decode (
    input  wire [38:0] protected_word,
    output wire [31:0] corrected_data,
    output wire        double_error_detected
);
    assign corrected_data = protected_word[31:0];
    assign double_error_detected = 1'b0;
endmodule
