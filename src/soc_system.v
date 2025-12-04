// soc_system.v
module soc_system (
    input  wire       clk,
    input  wire       rst,
    input  wire [7:0] switches,
    output wire [7:0] leds,
    // Debug ports for FPGA display
    output wire [31:0] pc_current,
    output wire [31:0] instr,
    output wire [31:0] alu_out,
    output wire [31:0] wd_dm,
    output wire [31:0] rdata_cpu // This replaces rd_dm for debug
);

    // Internal Wires
    wire        we_cpu;
    wire [31:0] addr_cpu, wdata_cpu;
    wire        we_dmem, we_gpio, we_fact;
    wire [31:0] rdata_dmem, rdata_gpio;
    wire [31:0] fact_result;
    wire        fact_done, fact_err;
    
    // Factorial Interface Signals
    reg [31:0] fact_n_reg;
    reg        fact_go_pulse;

    // 1. MIPS CPU
    mips cpu (
        .clk(clk),
        .rst(rst),
        .ra3(5'b0),          // Not used in SoC mode
        .instr(instr),
        .rd_dm(rdata_cpu),   // Data coming from Decoder
        .we_dm(we_cpu),
        .pc_current(pc_current),
        .alu_out(addr_cpu),  // Address
        .wd_dm(wdata_cpu),   // Write Data
        .rd3()               // Not used
    );

    // 2. Instruction Memory
    imem imem (
        .a(pc_current[7:2]),
        .y(instr)
    );

    // 3. Address Decoder
    address_decoder decoder (
        .we(we_cpu),
        .addr(addr_cpu),
        .rdata_dmem(rdata_dmem),
        .rdata_gpio(rdata_gpio),
        .fact_result(fact_result),
        .fact_done(fact_done),
        .we_dmem(we_dmem),
        .we_gpio(we_gpio),
        .we_fact(we_fact),
        .rdata_cpu(rdata_cpu)
    );

    // 4. Data Memory
    dmem ram (
        .clk(clk),
        .we(we_dmem),
        .a(addr_cpu[7:2]),
        .d(wdata_cpu),
        .q(rdata_dmem),
        .rst(rst)
    );

    // 5. GPIO Unit
    gpio_unit gpio (
        .clk(clk),
        .rst(rst),
        .we(we_gpio),
        .wdata(wdata_cpu),
        .switches(switches),
        .rdata(rdata_gpio),
        .leds(leds)
    );

    // 6. Factorial Latching Logic
    // We need to capture the CPU writing to 0x900 (N) and 0x904 (GO)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            fact_n_reg <= 0;
            fact_go_pulse <= 0;
        end else begin
            fact_go_pulse <= 0; // Auto clear
            if (we_fact) begin
                if (addr_cpu[3:0] == 4'h0) fact_n_reg <= wdata_cpu;
                if (addr_cpu[3:0] == 4'h4) fact_go_pulse <= wdata_cpu[0];
            end
        end
    end

    // 7. Factorial Accelerator
    factorial fact_unit (
        .clk(clk),
        .reset(rst),
        .go(fact_go_pulse),
        .n(fact_n_reg),
        .done(fact_done),
        .error(fact_err),
        .product(fact_result)
    );

endmodule