module tb_mdu;
    reg clk;
    reg rst;
    reg [31:0] rs1;
    reg [31:0] rs2;
    reg [2:0] mdu_op;
    reg mdu_valid;
    wire [31:0] mdu_result;
    wire mdu_ready;

    // Instantiate the MDU module
    mdu uut (
        .clk(clk),
        .rst(rst),
        .rs1(rs1),
        .rs2(rs2),
        .mdu_op(mdu_op),
        .mdu_valid(mdu_valid),
        .mdu_result(mdu_result),
        .mdu_ready(mdu_ready)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        rs1 = 0;
        rs2 = 0;
        mdu_op = 0;
        mdu_valid = 0;

        // Release reset
        #10 rst = 0;

        // Test multiplication
        #10 rs1 = 32'd2; rs2 = 32'd10; mdu_op = 3'b000; mdu_valid = 1; // MUL
        #10 mdu_valid = 0;
        #20;

        // Test division
        #10 rs1 = 32'd20; rs2 = 32'd4; mdu_op = 3'b010; mdu_valid = 1; // DIV
        #10 mdu_valid = 0;
        #20;

        // End simulation
        #100 $stop;
    end
endmodule

