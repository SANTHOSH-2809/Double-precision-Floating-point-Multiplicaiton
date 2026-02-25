module floatingpointmultiplication(
    input  [63:0] A, B,
    output [63:0] final_product
);

    // Sign
    wire SF = A[63] ^ B[63];

    // Exponent
    wire [10:0] EA = A[62:52];
    wire [10:0] EB = B[62:52];

    // Mantissa with hidden bit
    wire [52:0] MA = (EA == 0) ? {1'b0, A[51:0]} : {1'b1, A[51:0]};
    wire [52:0] MB = (EB == 0) ? {1'b0, B[51:0]} : {1'b1, B[51:0]};

    // Signed exponent computation
    wire signed [12:0] expA = (EA == 0) ? -1022 : EA - 1023;
    wire signed [12:0] expB = (EB == 0) ? -1022 : EB - 1023;

    wire signed [12:0] exp_sum = expA + expB;

    // Mantissa multiply
    wire [105:0] Mproduct = MA * MB;

    // Normalization
    wire [51:0] MF;
    wire signed [12:0] exp_norm;

    normalizer N1 (
        .Mproduct(Mproduct),
        .exp_in(exp_sum),
        .exp_out(exp_norm),
        .MF(MF)
    );

    // Special case detection
    wire [2:0] Case;
    case_indicator C1 (A, B, Case);

    // Final pack
    packer P1 (
        .Case(Case),
        .SF(SF),
        .exp_norm(exp_norm),
        .MF(MF),
        .final_product(final_product)
    );

endmodule

module normalizer (
    input  [105:0] Mproduct,
    input  signed [12:0] exp_in,
    output signed [12:0] exp_out,
    output [51:0] MF
);
   
  assign exp_out = Mproduct[105] ? exp_in + 1 : exp_in;
  assign MF = Mproduct[105] ? Mproduct[104:52] : Mproduct[103:52];

endmodule

module case_indicator(
    input [63:0] A, B,
    output reg [2:0] indicator
);

    wire A_nan  = (A[62:52]==11'h7FF) && (A[51:0]!=0);
    wire A_inf  = (A[62:52]==11'h7FF) && (A[51:0]==0);
    wire A_zero = (A[62:0]==0);

    wire B_nan  = (B[62:52]==11'h7FF) && (B[51:0]!=0);
    wire B_inf  = (B[62:52]==11'h7FF) && (B[51:0]==0);
    wire B_zero = (B[62:0]==0);

    always @(*) begin

        if (A_nan || B_nan)
            indicator = 3'd2;  // NaN

        else if ((A_inf && B_zero) || (A_zero && B_inf))
            indicator = 3'd2;  // NaN

        else if (A_inf || B_inf)
            indicator = 3'd3;  // Infinity

        else if (A_zero || B_zero)
            indicator = 3'd1;  // Zero

        else
            indicator = 3'd0;  // Normal

    end

endmodule

module packer(
    input  [2:0] Case,
    input        SF,
    input  signed [12:0] exp_norm,
    input  [51:0] MF,
    output reg [63:0] final_product
);

    wire overflow  = (exp_norm > 1023);
    wire underflow = (exp_norm < -1022);

    wire [10:0] exp_final = exp_norm + 1023;

    always @(*) begin

        case (Case)
            3'd2:  final_product = 64'h7FF8000000000000; // NaN
            3'd3:  final_product = {SF, 11'h7FF, 52'd0}; // INF
            3'd1:  final_product = {SF, 63'd0};          // Zero
            default: begin

                if (overflow)
                    final_product = {SF, 11'h7FF, 52'd0};

                else if (underflow)
                    final_product = {SF, 63'd0};
                else
                    final_product = {SF, exp_final, MF};
            end
        endcase
    end
endmodule
