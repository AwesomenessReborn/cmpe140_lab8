`timescale 1ns / 1ps

module control_unit(
    input wire clk,
    input wire go, // User input 
    input data_error, // From the datapath
    input data_gt, // From the datapath 
    input wire reset,
    output reg done, // Control output to know state of factorial 
    output reg error, // Control output to know state of factorial  
    
    output reg load_cnt, // To the datapath
    output reg load_reg, // To the datapath
    output reg en, // To the datapath
    output reg sel1, // To the datapath
    output reg sel2, // To the datapath
    
    output reg [2:0] current_state
    );
    
    reg [2:0] next_state;
    
    parameter s0 = 3'b000;
    parameter s1 = 3'b001;
    parameter s2 = 3'b010;
    parameter s3 = 3'b011;
    parameter s4 = 3'b100;
    parameter s5 = 3'b101;
    
    always @ (posedge clk, posedge reset) begin
        if (reset) begin
           current_state <= s0;
        end
        else begin
            current_state <= next_state;
        end
    end
    
    // Insert Datapath logic to run here
    
    always @ (*) begin
        done = 1'b0;
        error = 1'b0;
        load_cnt = 1'b0;
        load_reg = 1'b0;
        en = 1'b0;
        sel1 = 1'b0;
        sel2 = 1'b0;
    
        case(current_state)
            s0: begin // Idle State
                if(go) next_state = s1;
                else next_state = s0;
            end
            s1: begin // GO State; checking if input n is valid or not
                if (data_error) begin
                    next_state = s3;
                    load_cnt = 1'b1;
                    load_reg = 1'b1;
                end
                else begin 
                    next_state = s2;
                    error = 1'b1;
                end
            end
            s2: begin
                next_state = s0;
                error = 1'b1;
            end
            s3: begin
                if (data_gt) begin 
                    next_state = s4;
//                    load_reg = 1'b1;
//                    en = 1'b1;
                    sel1 = 1'b1;
                end
                else begin 
                    next_state = s5;
                    done = 1'b1;
                    sel2 = 1'b1;
                end
            end
            s4: begin
                next_state = s3;
                load_reg = 1'b1;
                en = 1'b1;
                sel1 = 1'b1;
            end
            s5: begin
                next_state = s0;   
                done = 1'b1;
                sel1 = 1'b1; //
                sel2 = 1'b1;
            end
            default: begin
                next_state = s0;
            end
        endcase
    end
endmodule
