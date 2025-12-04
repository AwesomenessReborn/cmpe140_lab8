// controlunit.v
module controlunit (
        input  wire [5:0]  opcode,
        input  wire [5:0]  funct,
        output wire        branch,
        output wire        jump,
        output wire        we_reg,
        output wire        alu_src,
        output wire        we_dm,
        output wire        dm2reg,
        
        /* Control Signals that are dictated by the opcode */
        output wire        pc2reg,      // Selecting if we want the program counter to be feed into wd_rf and $ra into rf_wa
//        output wire        reg_dst,     
        output wire [1:0]  reg_dst,     // Originally 1-bit but changing to 2-bit

        
        /* Control Signals that are dictated by the funct */
//        output wire [2:0]  alu_ctrl,
        output wire [3:0]  alu_ctrl,    // Originally 3-bits but changing to 4-bits to accommodate new instructions
        output wire [1:0]  muldiv_ctrl, // For the muldiv unit
        output wire        we_muldiv,   // Write enable for the muldiv unit
        output wire        hilo_stream, // To select which HILO reg to stream into MUX
        output wire        hilo2reg,    // Selecting the HILO reg to be feed into wd_rf
        output wire        alu_shamt,   // For the SLL and SRL to take into account the shamt value to the ALU
        output wire        jump_reg     // Jumping based off the data from a register
        
    );
    
    wire [1:0] alu_op;

    maindec md (
        .opcode         (opcode),
        .branch         (branch),
        .jump           (jump),
        .reg_dst        (reg_dst),
        .we_reg         (we_reg),
        .alu_src        (alu_src),
        .we_dm          (we_dm),
        .dm2reg         (dm2reg),
        .alu_op         (alu_op),
        .pc2reg         (pc2reg)
    );

    auxdec ad (
        .alu_op         (alu_op),
        .funct          (funct),
        .alu_ctrl       (alu_ctrl),
        .muldiv_ctrl    (muldiv_ctrl),
        .we_muldiv      (we_muldiv),
        .hilo_stream    (hilo_stream),
        .hilo2reg       (hilo2reg),
        .alu_shamt      (alu_shamt),
        .jump_reg       (jump_reg)
    );

endmodule