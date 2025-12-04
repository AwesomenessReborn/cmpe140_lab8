// gpio_unit.v
module gpio_unit (
    input wire clk,
    input wire rst,
    input wire we,
    input wire [31:0] wdata,
    input wire [7:0] switches,
    output reg [31:0] rdata,
    output reg [7:0] leds
);
    // Write Logic: CPU writes to LEDs
    always @(posedge clk or posedge rst) begin
        if (rst) leds <= 8'b0;
        else if (we) leds <= wdata[7:0];
    end

    // Read Logic: CPU reads Switches
    always @(*) begin
        rdata = {24'b0, switches};
    end
endmodule