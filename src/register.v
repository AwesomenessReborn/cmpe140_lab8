`timescale 1ns / 1ps

// A register to store some value based on some signal 
// If load_reg is high, then we will store a new data value into out 
module register(
    input wire clk,
    input load_reg,
    input [31:0] data,
    output reg [31:0] out
    );
    
    always @ (posedge clk) begin
        if (load_reg) begin
            out <= data;
        end
    end
    
endmodule
