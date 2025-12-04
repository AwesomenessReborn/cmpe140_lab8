// mips.v
module mips (
        input  wire        clk,
        input  wire        rst,
        input  wire [4:0]  ra3,
        input  wire [31:0] instr,
        input  wire [31:0] rd_dm,
        output wire        we_dm,
        output wire [31:0] pc_current,
        output wire [31:0] alu_out,
        output wire [31:0] wd_dm,
        output wire [31:0] rd3
    );
    
    wire       branch;
    wire       jump;
    wire       we_reg;
    wire       alu_src;
    wire       dm2reg;
    
    /* Lab 7 Implementation */
//    wire       reg_dst;
//    wire [2:0] alu_ctrl;
    wire [1:0] reg_dst;
    wire [3:0] alu_ctrl;
    wire       pc2reg;
    wire [1:0] muldiv_ctrl;
    wire       we_muldiv;
    wire       hilo_stream;
    wire       hilo2reg;
    wire       alu_shamt;
    wire       jump_reg;


    datapath dp (
            .clk            (clk),
            .rst            (rst),
            .branch         (branch),
            .jump           (jump),
//            .reg_dst        (reg_dst),
            .we_reg         (we_reg),
            .alu_src        (alu_src),
            .dm2reg         (dm2reg),
//            .alu_ctrl       (alu_ctrl),
            .ra3            (ra3),
            .instr          (instr),
            .rd_dm          (rd_dm),
            
            /* Lab 7 Implementation */
            .reg_dst        (reg_dst),
            .alu_ctrl       (alu_ctrl),
            .muldiv_ctrl    (muldiv_ctrl),
            .pc2reg         (pc2reg),
            .we_muldiv      (we_muldiv),
            .hilo_stream    (hilo_stream),
            .hilo2reg       (hilo2reg),
            .alu_shamt      (alu_shamt),
            .jump_reg       (jump_reg),
            
            .pc_current     (pc_current),
            .alu_out        (alu_out),
            .wd_dm          (wd_dm),
            .rd3            (rd3)
        );

    controlunit cu (
            .opcode         (instr[31:26]),
            .funct          (instr[5:0]),
            .branch         (branch),
            .jump           (jump),
//            .reg_dst        (reg_dst),
            .we_reg         (we_reg),
            .alu_src        (alu_src),
            .we_dm          (we_dm),
            .dm2reg         (dm2reg),
//            .alu_ctrl       (alu_ctrl)
            
            /* Lab 7 Implementation */
            .reg_dst        (reg_dst),
            .alu_ctrl       (alu_ctrl),
            .muldiv_ctrl    (muldiv_ctrl),
            .pc2reg         (pc2reg),
            .we_muldiv      (we_muldiv),
            .hilo_stream    (hilo_stream),
            .hilo2reg       (hilo2reg),
            .alu_shamt      (alu_shamt),
            .jump_reg       (jump_reg)
        );

endmodule