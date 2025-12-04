// auxdec.v
module auxdec (
        input  wire [1:0] alu_op,
        input  wire [5:0] funct,
        
        /* Lab 7 Modifications */
//        output wire [2:0] alu_ctrl,
        output wire [3:0]  alu_ctrl,    // Originally 3-bits but changing to 4-bits to accommodate new instructions
        output wire [1:0]  muldiv_ctrl,   // For the muldiv unit
        output wire        we_muldiv,   // Write enable for the muldiv unit
        output wire        hilo_stream, // To select which HILO reg to stream into MUX
        output wire        hilo2reg,    // Selecting the HILO reg to be feed into wd_rf
        output wire        alu_shamt,   // For the SLL and SRL to take into account the shamt value to the ALU
        output wire        jump_reg     // Jumping based off the data from a register
        
    );

//    reg [2:0] ctrl;
//    assign {alu_ctrl} = ctrl;

    reg [10:0] ctrl;
    assign {alu_ctrl, muldiv_ctrl, we_muldiv, hilo_stream, hilo2reg, alu_shamt, jump_reg} = ctrl;

    always @ (alu_op, funct) begin
        case (alu_op)
            2'b00: ctrl = 11'b0010_00_0_0_0_0_0;          // ADD
            2'b01: ctrl = 11'b0110_00_0_0_0_0_0;          // SUB
            default: case (funct)
                /* Lab 7 Additions */
                6'b00_1000: ctrl = 11'b0000_00_0_0_0_0_1; // JR
                6'b00_0000: ctrl = 11'b1000_00_0_0_0_1_0; // SLL
                6'b00_0010: ctrl = 11'b1001_00_0_0_0_1_0; // SRL
                6'b01_1001: ctrl = 11'b0000_00_1_0_0_0_0; // MULTU
                6'b01_0000: ctrl = 11'b0000_00_0_1_1_0_0; // MFHI
                6'b01_0010: ctrl = 11'b0000_00_0_0_1_0_0; // MFLO
           
                /* Original Implementation */
                6'b10_0100: ctrl = 11'b0000_00_0_0_0_0_0; // AND
                6'b10_0101: ctrl = 11'b0001_00_0_0_0_0_0; // OR
                6'b10_0000: ctrl = 11'b0010_00_0_0_0_0_0; // ADD
                6'b10_0010: ctrl = 11'b0110_00_0_0_0_0_0; // SUB
                6'b10_1010: ctrl = 11'b0111_00_0_0_0_0_0; // SLT
                default:    ctrl = 11'bxxxx_xx_x_x_x_x_x;
            endcase
        endcase
    end

endmodule