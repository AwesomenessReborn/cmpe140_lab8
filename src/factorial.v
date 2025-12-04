`timescale 1ns / 1ps

// The top level module combining both the Control Unit and the Datapath, where they will be able 
// to talk to each other 
module factorial(
    input wire clk,
    input wire reset,
    input wire go,
    input wire [31:0] n,
    output done,
    output error,
    output wire [31:0] product
    );
    
    wire data_error;
    wire data_gt;
    wire load_cnt;
    wire load_reg;
    wire en;
    wire sel1; 
    wire sel2;
    wire [2:0] current_state;
    
    fact_control cu(
        .clk(clk),
        .go(go), 
        .data_error(data_error), 
        .data_gt(data_gt), 
        .reset(reset), 
        .done(done), 
        .error(error), 
        .load_cnt(load_cnt), 
        .load_reg(load_reg), 
        .en(en), 
        .sel1(sel1), 
        .sel2(sel2),
        .current_state(current_state)
    );
    
    fact_datapath dp(
        .clk(clk),
        .n(n),
        .load_cnt(load_cnt),
        .load_reg(load_reg),
        .en(en),
        .sel1(sel1),
        .sel2(sel2),
        .data_error(data_error),
        .data_gt(data_gt),
        .product(product)
    );
endmodule
