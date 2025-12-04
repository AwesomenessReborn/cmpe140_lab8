// muldivunit.v
module muldivunit (
        input wire clk,
        input wire rst,
        
        input wire [1:0] muldiv_ctrl,
        input wire we_muldiv,
        input wire [31:0] a,
        input wire [31:0] b,
        
        output wire [31:0] hi_q,
        output wire [31:0] lo_q        
    );
    
    
    reg [31:0] HI, LO;
    reg [31:0] next_HI, next_LO;
        
    initial begin
        HI = 32'h0;
        LO = 32'h0;
    end
    
    always @ (a, b, muldiv_ctrl) begin
        next_HI = HI;
        next_LO = LO;
        
        case (muldiv_ctrl)
            2'b00: {next_HI, next_LO} = a * b; // MULTU
//            2'b01: // MULT
//            2'b10: // DIVU
//            2'b11: //DIV
            default:  begin end
        endcase
    end
    
    always @ (posedge clk, posedge rst) begin
        if (rst) begin
            HI <= 32'h0;
            LO <= 32'h0;
        end
        else if (we_muldiv) begin
            HI <= next_HI;
            LO <= next_LO;
        end
    end
    
    assign hi_q = HI;
    assign lo_q = LO;
endmodule