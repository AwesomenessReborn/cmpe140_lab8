`timescale 1ns / 1ps

// If load_cnt is high, then it will load the data input into count
// If enable is high, then the current value of count stored will decrement by one based on every posedge of the clk signal
// Otherwise, nothing else will happen
module down_counter(
    input wire clk,
    input enable,
    input load_cnt,
    input [31:0] data,
    
    output reg [31:0] count
    );
    
    always @(posedge clk) begin
        if (load_cnt) begin
            count <= data;
        end
        if (enable) begin
            count <= count - 1;
        end
    end
endmodule
