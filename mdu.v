module mdu (
    input clk,
    input rst,
    input [31:0] rs1,
    input [31:0] rs2,
    input [2:0] mdu_op,
    output reg [31:0] mdu_result
);
    parameter mul  = 3'b000;
    parameter mulh = 3'b001;
    parameter div  = 3'b010;
    parameter divu = 3'b011;
    parameter rem  = 3'b100;
    parameter remu = 3'b101;

    reg [31:0] quotient, remainder;
    reg [63:0] product;

    always @(*) begin
        case (mdu_op)
            mul: begin
                product = rs1 * rs2;
                mdu_result = product[31:0];
            end
            mulh: begin
                product = $signed(rs1) * $signed(rs2);
                mdu_result = product[63:32];
            end
            div: begin
                if (rs2 != 0) begin
                    quotient = $signed(rs1) / $signed(rs2);
                    mdu_result = quotient;
                end else begin
                    mdu_result = 32'b0; // X? lı chia cho 0
                end
            end
            divu: begin
                if (rs2 != 0) begin
                    quotient = rs1 / rs2;
                    mdu_result = quotient;
                end else begin
                    mdu_result = 32'b0; // X? lı chia cho 0
                end
            end
            rem: begin
                if (rs2 != 0) begin
                    remainder = $signed(rs1) % $signed(rs2);
                    mdu_result = remainder;
                end else begin
                    mdu_result = 32'b0; // X? lı chia cho 0
                end
            end
            remu: begin
                if (rs2 != 0) begin
                    remainder = rs1 % rs2;
                    mdu_result = remainder;
                end else begin
                    mdu_result = 32'b0; // X? lı chia cho 0
                end
            end
            default: begin
                mdu_result = 32'b0;
            end
        endcase
    end
endmodule

