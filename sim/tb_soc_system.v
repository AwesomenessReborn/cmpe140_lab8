`timescale 1ns / 1ps

module tb_soc_system;

    // Inputs
    reg clk;
    reg rst;
    reg [7:0] switches;

    // Outputs
    wire [7:0] leds;
    
    // Debug Outputs (To see what the CPU is doing)
    wire [31:0] pc_current;
    wire [31:0] instr;
    wire [31:0] alu_out;
    wire [31:0] wd_dm;
    wire [31:0] rdata_cpu;

    // Instantiate the Unit Under Test (UUT)
    soc_system uut (
        .clk(clk), 
        .rst(rst), 
        .switches(switches), 
        .leds(leds),
        
        // Debug ports
        .pc_current(pc_current),
        .instr(instr),
        .alu_out(alu_out),
        .wd_dm(wd_dm),
        .rdata_cpu(rdata_cpu)
    );

    // Clock Generation (100MHz)
    always #5 clk = ~clk;

    initial begin
        // 1. Initialize Inputs
        clk = 0;
        rst = 1;
        switches = 0;

        // 2. Hold Reset for 100 ns
        #100;
        rst = 0;
        
        // 3. Apply Stimulus
        // Calculate Factorial of 3
        // Expect Result: 6 (binary 00000110)
        switches = 8'd3; 
        
        // Wait for result to appear
        #2000;
        
        // Change input to Factorial of 4
        // Expect Result: 24 (binary 00011000)
        switches = 8'd4;
        
        #2000;

        // Change input to Factorial of 5
        // Expect Result: 120 (binary 01111000)
        switches = 8'd5;
        
        #2000;
        
        $finish;
    end
      
endmodule