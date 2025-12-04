// address_decoder.v
module address_decoder (
    input  wire        we,           // Write Enable from CPU
    input  wire [31:0] addr,         // Address from CPU
    input  wire [31:0] rdata_dmem,   // Data from RAM
    input  wire [31:0] rdata_gpio,   // Data from GPIO
    input  wire [31:0] fact_result,  // Data from Factorial
    input  wire        fact_done,    // Status from Factorial

    output reg         we_dmem,      // Enable RAM Write
    output reg         we_gpio,      // Enable GPIO Write
    output reg         we_fact,      // Enable Factorial Write
    output reg  [31:0] rdata_cpu     // Data to CPU
);

    always @(*) begin
        // Defaults
        we_dmem = 0;
        we_gpio = 0;
        we_fact = 0;
        rdata_cpu = 32'b0;

        // RAM: 0x000 - 0x0FC (0 - 252)
        if (addr[11:8] == 4'h0) begin
            we_dmem = we;
            rdata_cpu = rdata_dmem;
        end
        // GPIO: 0x800 (2048)
        else if (addr[11:8] == 4'h8) begin
            we_gpio = we;
            rdata_cpu = rdata_gpio;
        end
        // Factorial: 0x900 - 0x904 (2304)
        else if (addr[11:8] == 4'h9) begin
            we_fact = we;
            if (addr[3:0] == 4'h0)      rdata_cpu = fact_result;
            else if (addr[3:0] == 4'h4) rdata_cpu = {31'b0, fact_done};
        end
    end
endmodule