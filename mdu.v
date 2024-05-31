module mdu (
    input clk,
    input rst,
    input [31:0] rs1,
    input [31:0] rs2,
    input [2:0] mdu_op,
    input mdu_valid,
    output reg [31:0] mdu_result,
    output reg mdu_ready
);
    // MDU operation codes
    parameter MUL = 3'b000;
    parameter MULH = 3'b001;
    parameter DIV = 3'b010;
    parameter DIVU = 3'b011;
    parameter REM = 3'b100;
    parameter REMU = 3'b101;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mdu_result <= 32'b0;
            mdu_ready <= 0;
        end else if (mdu_valid) begin
            case (mdu_op)
                MUL: begin
                    mdu_result <= rs1 * rs2;
                end
                MULH: begin
                    mdu_result <= ($signed(rs1) * $signed(rs2)) >>> 32;
                end
                DIV: begin
                    mdu_result <= $signed(rs1) / $signed(rs2);
                end
                DIVU: begin
                    mdu_result <= rs1 / rs2;
                end
                REM: begin
                    mdu_result <= $signed(rs1) % $signed(rs2);
                end
                REMU: begin
                    mdu_result <= rs1 % rs2;
                end
                default: begin
                    mdu_result <= 32'b0;
                end
            endcase
            mdu_ready <= 1; // Set ready high whenever a valid operation is performed
        end else begin
            mdu_ready <= 1; // Keep ready high
        end
    end
endmodule

