`timescale 1ns / 1ps

// This multiplexier will take two inputs of size 32 bits and a 1 bit sel line
// If sel == 1, then out == A
// If sel == 0, then out == B
module fact_mux(
    input [31:0] A, 
    input [31:0] B,
    input sel,
    output [31:0] out
    );
    
    assign out = sel ? A : B;
endmodule
