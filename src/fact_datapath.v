`timescale 1ns / 1ps

// Based on the inputs provided by the control unit, it will execute the following combination and sequential logic blocks
module datapath(
    input wire clk, 
    input wire [31:0] n, // User input
    input load_cnt, // Control Unit input
    input load_reg, // Control Unit input
    input en, // Control Unit input
    input sel1, // Control Unit input
    input sel2, // Control Unit input
    
    output data_error, // Will feed into the Control Unit
    output data_gt, // Will feed into the Control Unit
    
    output wire [31:0] product // Final output that the user will read
    );
    
    wire [31:0] current_count;
    wire [31:0] current_reg_value;
    wire [31:0] mul_output;
    wire [31:0] mux1_output;
    wire [31:0] mux2_output;
    
    reg [31:0] one = 32'd1;
    reg [31:0] zero = 32'd0;
    
    reg [31:0] error_check = 32'd13;
    reg [31:0] gt_check = 32'd1;
    
    comparator comp_error(
        .A(error_check), 
        .B(n), 
        .gt(data_error)
    );
    comparator comp_gt(
        .A(current_count), 
        .B(gt_check), 
        .gt(data_gt)
    );
    
    fact_mux mux1(
        .A(mul_output), 
        .B(one), 
        .sel(sel1), 
        .out(mux1_output)
    );
    fact_mux mux2(
        .A(current_reg_value), 
        .B(zero), 
        .sel(sel2), 
        .out(product)
    );
    
    down_counter counter(
        .clk(clk), 
        .enable(en), 
        .load_cnt(load_cnt), 
        .data(n), 
        .count(current_count)
    );
    
    multiplier mul(
        .A(current_count), 
        .B(current_reg_value), 
        .out(mul_output)
    );
    
    register register(
        .clk(clk), 
        .load_reg(load_reg), 
        .data(mux1_output), 
        .out(current_reg_value)
    );
endmodule
