`timescale 1ns / 1ps

module controller(
    input [31:0] instr,
    input BrEq, BrLt,
    output reg RegWEn, imm_sel, Bsel, Asel, BrUn, PCsel,
    output reg MemRW,
    output reg [1:0] WBsel,
    output reg [3:0] alu_control,
    output reg [2:0] mdu_op
    );
    
    //opcode
    parameter R_type        = 7'b0110011;
    parameter I_R_type      = 7'b0010011;
    parameter Load_type     = 7'b0000011;
    parameter Store_type    = 7'b0100011;
    parameter B_type        = 7'b1100011;
    parameter JAL_type      = 7'b1101111;
    parameter JALR_type     = 7'b1100111;
    parameter LUI           = 7'b0110111;
    parameter AUIPC         = 7'b0010111;
    
    //alu control
    parameter add   = 4'b0000;
    parameter sub   = 4'b0001;
    parameter orr   = 4'b0010;
    parameter andd  = 4'b0011;
    parameter xorr  = 4'b0100;
    parameter slt   = 4'b0101;
    parameter sll   = 4'b0110;
    parameter srl   = 4'b0111;
    parameter sra   = 4'b1000;
    parameter sltu  = 4'b1001;
    parameter lui   = 4'b1111;
    
    //funct3
    parameter ADD  = 3'b000;
    parameter SUB  = 3'b000;
    parameter ORR  = 3'b110;
    parameter ANDD = 3'b111;
    parameter XORR = 3'b100;
    parameter SLT  = 3'b010;
    parameter SLL  = 3'b001;
    parameter SRL  = 3'b101;
    parameter SRA  = 3'b101;
    parameter SLTU = 3'b011;

    //funct7 MDU
    parameter MDU_OP = 7'b0000001;
    //funct3 MDU
    parameter MUL  = 3'b000;
    parameter MULH = 3'b001;
    parameter DIV  = 3'b010;
    parameter DIVU = 3'b011;
    parameter REM  = 3'b100;
    parameter REMU = 3'b101;
    
    //describe each element of instruction
    wire [6:0] opcode;
    wire [6:0] funct7;
    wire [2:0] funct3;
    assign opcode = instr[6:0];
    assign funct7 = instr[31:25];
    assign funct3 = instr[14:12];
    
    always @(*) begin
        // Default control signal values
        PCsel = 0;
        imm_sel = 0;
        RegWEn = 0;
        BrUn = 0;
        Bsel = 0;
        Asel = 0;
        WBsel = 2'b00;
        MemRW = 0;
        alu_control = 4'b0000;
        mdu_op = 3'b000;

case (opcode)
            R_type: begin
                if (funct7 == MDU_OP) begin
                    case (funct3)
                        MUL:  mdu_op = MUL;
                        MULH: mdu_op = MULH;
                        DIV:  mdu_op = DIV;
                        DIVU: mdu_op = DIVU;
                        REM:  mdu_op = REM;
                        REMU: mdu_op = REMU;
                    endcase
                    RegWEn = 1;
                    WBsel = 3;
                end else begin
                    case (funct3)
                        ADD: alu_control = add;
                        ORR: alu_control = orr;
                        ANDD: alu_control = andd;
                        XORR: alu_control = xorr;
                        SLT: alu_control = slt;
                        SLTU: alu_control = sltu;
                        SLL: alu_control = sll;
                        SRL: alu_control = srl;
                        SRA: alu_control = sra;
                    endcase
                    RegWEn = 1;
                    WBsel = 2'b10;
                end
            end
            I_R_type: begin
                case (funct3)
                    ADD : alu_control = add;
                    ORR : alu_control = orr;
                    ANDD: alu_control = andd;
                    XORR: alu_control = xorr;
                    SLT : alu_control = slt;
                    SLTU: alu_control = sltu;
                    SLL : alu_control = sll;
                    SRL : alu_control = srl;
                    SRA : alu_control = sra;
                default : alu_control = add;
                endcase
                PCsel = 0;
                imm_sel = 1;
                RegWEn = 1;
                Bsel = 1;
                Asel = 0;
                WBsel = 2'b01;
                MemRW = 0;
            end
            Load_type: begin
                imm_sel = 1;
                RegWEn = 1;
                Bsel = 1;
                WBsel = 2'b00;
                MemRW = 0;
                alu_control = add;
            end
            Store_type: begin
                imm_sel = 1;
                RegWEn = 0;
                Bsel = 1;
                MemRW = 1;
                alu_control = add;
            end
            B_type: begin
                imm_sel = 1;
                RegWEn = 0;
                Bsel = 1;
                Asel = 1;
                alu_control = add;
                MemRW = 0;
                case (funct3)
                    3'b000: begin // BEQ
                        BrUn = 0;
                        PCsel = BrEq;
                    end
                    3'b001: begin // BNE
                        BrUn = 0;
                        PCsel = ~BrEq;
                    end
                    3'b100: begin // BLT
                        BrUn = 0;
                        PCsel = BrLt;
                    end
                    3'b101: begin // BGE
                        BrUn = 0;
                        PCsel = ~BrLt;
                    end
                    3'b110: begin // BLTU
                        BrUn = 1;
                        PCsel = BrLt;
                    end
                    3'b111: begin // BGEU
                        BrUn = 1;
                        PCsel = ~BrLt;
                    end
                endcase
            end
            JAL_type: begin
                PCsel = 1;
                imm_sel = 1;
                RegWEn = 1;
                Bsel = 1;
                Asel = 1;
                alu_control = add;
                MemRW = 0;
                WBsel = 2'b10;
            end
            JALR_type: begin
                PCsel = 1;
                imm_sel = 1;
                RegWEn = 1;
                Bsel = 1;
                Asel = 0;
                alu_control = add;
                MemRW = 0;
                WBsel = 2'b10;
            end
            LUI: begin
                PCsel = 0;
                imm_sel = 1;
                RegWEn = 1;
                Bsel = 1;
                alu_control = lui;
                MemRW = 0;
                WBsel = 2'b01;
            end
            AUIPC: begin
                PCsel = 0;
                imm_sel = 1;
                RegWEn = 1;
                Bsel = 1;
                Asel = 1;
                alu_control = add;
                MemRW = 0;
                WBsel = 2'b01;
            end
            default: begin
                PCsel = 0;
                imm_sel = 0;
                RegWEn = 0;
                BrUn = 0;
                Bsel = 0;
                Asel = 0;
                WBsel = 2'b00;
                MemRW = 0;
                alu_control = 4'b0000;
            end
        endcase
    end
endmodule

