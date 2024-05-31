`timescale 1ns / 1ps

module top(
    input clk,
    input rst,
    output [31:0] instruction,
    output [31:0] result
    );
    
    wire [31:0] pc, pc_add4, pc_next, instr, wb, rs1, rs2, imm, A_alu, B_alu, alu_result,mdu_result, mem;
    wire brEq, brLt;
    //control signal
    wire imm_sel, Asel, Bsel, MemRW, brUn, PCSel, reg_write_en, mdu_valid, mdu_ready;
    wire [3:0] alu_control;
    wire [2:0] mdu_op;
    wire [1:0] WBsel;

    
    //debug
    assign instruction = instr;
    assign result = wb;
    
    mux pc_sel (
        .s(PCSel),
        .a(pc_add4),
        .b(alu_result),
        .c(pc_next)
    );
    pc pc_instance (
        .pc_next(pc_next),
        .clk(clk),
        .rst(rst),
        .pc(pc)
    );
    pc_adder pc_add_4 (
        .pc_in(pc),
        .pc_out(pc_add4)
    );
    imem instr_mem (
        .address(pc),
        .RD(instr)
    );
    REG register_file (
        .clk(clk),
        .rst(rst),
        .A1(instr[19:15]),
        .A2(instr[24:20]),
        .A3(instr[11:7]),
        .WD3(wb),
        .WE3(reg_write_en),
        .RD1(rs1),
        .RD2(rs2)
    );
    branch_comp bc (
        .A(rs1),
        .B(rs2),
        .eq(brEq),
        .lt(brLt),
        .brUn(brUn)
    );
    imm_gen bit_exten (
        .instr(instr),
        .imm_out(imm),
        .imm_sel(imm_sel)
    );
    mux muxA (
        .s(Asel),
        .a(rs1),
        .b(pc),
        .c(A_alu)
    );
    mux muxB (
        .s(Bsel),
        .a(rs2),
        .b(imm),
        .c(B_alu)
    );
    alu ALU (
        .A(rs1),
        .B(B_alu),
        .alu_control(alu_control),
        .alu_result(alu_result) //alu_result
    );
    // Instantiate the MDU
    mdu mdu_inst (
        .clk(clk),
        .rst(rst),
        .rs1(rs1),
        .rs2(rs2),
        .mdu_op(mdu_op),
        .mdu_valid(mdu_valid),
        .mdu_result(mdu_result),
        .mdu_ready(mdu_ready)
    );
    data_mem dmem (
        .clk(clk),
        .rst(rst),
        .address(alu_result),
        .MemRW(MemRW),
        .DataR(mem),
        .DataW(rs2)
    );
    mux4 muxWB (
    .dmem(mem),
    .alu(alu_result),
    .pc_4(pc_add4),
    .mdu(mdu_result),
    .WBsel(WBsel),
    .wb(wb),
    .reg_write_en(reg_write_en) // K?t n?i tín hi?u reg_write_en v?i m?ch ?i?u khi?n ghi vào thanh ghi
    );
    controller controller (
        .PCsel(PCSel),
        .instr(instr),
        .RegWEn(reg_write_en),
        .alu_control(alu_control),
        .imm_sel(imm_sel),
        .BrUn(brUn),
        .BrLt(brLt),
        .BrEq(brEq),
        .Bsel(Bsel),
        .Asel(Asel),
        .WBsel(WBsel),
        .MemRW(MemRW),
        .mdu_op(mdu_op),
        .mdu_valid(mdu_valid)
    );
endmodule
