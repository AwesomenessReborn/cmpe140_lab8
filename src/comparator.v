`timescale 1ns / 1ps

// The comparator will take two inputs of size 32 bits and will see if A > B.
// If A > B, then gt = 1
// else, gt = 0
module comparator(
    input [31:0] A,
    input [31:0] B,
    output gt
    );
    
    assign gt = (A > B) ? 1'b1 : 1'b0;
endmodule