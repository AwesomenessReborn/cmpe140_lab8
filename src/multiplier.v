`timescale 1ns / 1ps

// This multiplier will take two 4 bit inputs and multiply them together and spit out a 32 bit output
module multiplier(
    input [31:0] A,
    input [31:0] B,
    output [31:0] out
    );
    
    assign out = A * B;
endmodule
