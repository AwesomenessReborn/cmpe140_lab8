// datapath.v
module datapath (
        input  wire        clk,
        input  wire        rst,
        input  wire        branch,
        input  wire        jump,
        input  wire        we_reg,
        input  wire        alu_src,
        input  wire        dm2reg,
//        input  wire [2:0]  alu_ctrl,
        input  wire [4:0]  ra3,
        input  wire [31:0] instr,
        input  wire [31:0] rd_dm,
        
        /* Lab 7 Implementation */
        input  wire [3:0]  alu_ctrl,
        input  wire [1:0]  reg_dst,     // Implemented 
        input  wire [1:0]  muldiv_ctrl, // Implemented
        input  wire        pc2reg,      // Implemented 
        input  wire        we_muldiv,   // Implemented 
        input  wire        hilo_stream, // Implemented 
        input  wire        hilo2reg,    // Implemented
        input  wire        alu_shamt,   // Implemented 
        input  wire        jump_reg,    // Implemented 
        
        output wire [31:0] pc_current,
        output wire [31:0] alu_out,
        output wire [31:0] wd_dm,
        output wire [31:0] rd3
    );

    wire [4:0]  rf_wa;
    wire        pc_src;
    wire [31:0] pc_plus4;
    wire [31:0] pc_pre;
    wire [31:0] pc_next;
    wire [31:0] sext_imm;
    wire [31:0] ba;
    wire [31:0] bta;
    wire [31:0] jta;
    wire [31:0] alu_pa;
    wire [31:0] alu_pb;
    wire [31:0] wd_rf;
    wire        zero;
    
    assign pc_src = branch & zero;
    assign ba = {sext_imm[29:0], 2'b00};
    assign jta = {pc_plus4[31:28], instr[25:0], 2'b00};
    
    /* Lab 7 Implementation */
    wire [31:0] shamt; 
    wire [31:0] pc_jmp_reg;
    wire [31:0] hi;
    wire [31:0] lo;
    wire [31:0] wd_rf_hilo;
    wire [31:0] wd_rf_p1;
    wire [31:0] wd_rf_p2;
    wire [31:0] alu_pb_shamt;
    
    assign shamt = {27'b0, instr[10:6]};
    
    // --- PC Logic --- //
    dreg pc_reg (
            .clk            (clk),
            .rst            (rst),
            .d              (pc_next),
            .q              (pc_current)
        );

    adder pc_plus_4 (
            .a              (pc_current),
            .b              (32'd4),
            .y              (pc_plus4)
        );

    adder pc_plus_br (
            .a              (pc_plus4),
            .b              (ba),
            .y              (bta)
        );

    mux2 #(32) pc_src_mux (
            .sel            (pc_src),
            .a              (pc_plus4),
            .b              (bta),
            .y              (pc_pre)
        );
    
    /* Lab 7 Implementation */    
    mux2 #(32) pc_jmp_reg_mux (
            .sel            (jump_reg),
            .a              (pc_pre),
            .b              (alu_pa),   // rd1
            .y              (pc_jmp_reg)
        );

    mux2 #(32) pc_jmp_mux (
            .sel            (jump),
            .a              (pc_jmp_reg),
            .b              (jta),
            .y              (pc_next)
        );

    // --- RF Logic --- //
//    mux2 #(5) rf_wa_mux (
//            .sel            (reg_dst),
//            .a              (instr[20:16]),
//            .b              (instr[15:11]),
//            .y              (rf_wa)
//        );
    
    /* Lab 7 Implementation */    
    mux3 #(5) rf_wa_mux (
        .sel            (reg_dst),
        .a              (instr[20:16]),
        .b              (instr[15:11]),
        .c              (5'b11111),
        .y              (rf_wa)
    );

    regfile rf (
            .clk            (clk),
            .we             (we_reg),
            .ra1            (instr[25:21]),
            .ra2            (instr[20:16]),
            .ra3            (ra3),
            .wa             (rf_wa),
            .wd             (wd_rf),
            .rd1            (alu_pa),
            .rd2            (wd_dm),
            .rd3            (rd3),
            .rst            (rst)
        );

    signext se (
            .a              (instr[15:0]),
            .y              (sext_imm)
        );

    // --- ALU Logic --- //
    mux2 #(32) alu_pb_mux (
            .sel            (alu_src),
            .a              (wd_dm),
            .b              (sext_imm),
            .y              (alu_pb)
        );
    
    /* Lab 7 Implementation */    
    mux2 #(32) alu_shamt_mux (
            .sel            (alu_shamt),
            .a              (alu_pb),
            .b              (shamt),
            .y              (alu_pb_shamt)
    );

    alu alu (
            .op             (alu_ctrl),
            .a              (alu_pa),
            .b              (alu_pb_shamt),
            .zero           (zero),
            .y              (alu_out)
        );

    /* Lab 7 Implementation */
    muldivunit muldivunit (
            .clk            (clk),
            .rst            (rst),
            .muldiv_ctrl    (muldiv_ctrl),
            .we_muldiv      (we_muldiv),
            .a              (alu_pa),
            .b              (wd_dm),
            .hi_q           (hi),
            .lo_q           (lo)
    ); 

    /* Lab 7 Implementation */
    mux2 #(32) hilo_stream_mux (
            .sel            (hilo_stream),
            .a              (lo),
            .b              (hi),
            .y              (wd_rf_hilo)
        );
        
    // --- MEM Logic --- //
    mux2 #(32) rf_wd_p1_mux (
            .sel            (dm2reg),
            .a              (alu_out),
            .b              (rd_dm),
            .y              (wd_rf_p1)
        );
    
    /* Lab 7 Implementation */
    mux2 #(32) rf_wd_p2_mux (
            .sel            (hilo2reg),
            .a              (wd_rf_p1),
            .b              (wd_rf_hilo),
            .y              (wd_rf_p2)
        );
    
    /* Lab 7 Implementation */    
    mux2 #(32) rf_wd_p3_mux (
            .sel            (pc2reg),
            .a              (wd_rf_p2),
            .b              (pc_plus4),
            .y              (wd_rf)
        );

endmodule