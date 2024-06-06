`timescale 1ns / 1ps

module tb_mdu;

    // Inputs
    reg clk;
    reg rst;
    reg [31:0] rs1;
    reg [31:0] rs2;
    reg [2:0] mdu_op;
    
    // Outputs
    wire [31:0] mdu_result;

    // Instantiate the MDU
    mdu uut (
        .clk(clk),
        .rst(rst),
        .rs1(rs1),
        .rs2(rs2),
        .mdu_op(mdu_op),
        .mdu_result(mdu_result)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        // Initialize inputs
        clk = 0;
        rst = 1;
        rs1 = 0;
        rs2 = 0;
        mdu_op = 0;

        // Reset the system
        #10 rst = 0;

        // Wait for some time after reset
        #10;

        // Test case 1: mul (3 * 4)
        rs1 = 32'd3;
        rs2 = 32'd4;
        mdu_op = 3'b000; // mul
        #10; // Wait for a clock cycle
        $display("Test case 1: %d * %d = %d", rs1, rs2, mdu_result);
        if (mdu_result !== 12) $display("Test case 1 failed");

        // Test case 2: mul (7 * 5)
        rs1 = 32'd7;
        rs2 = 32'd5;
        mdu_op = 3'b000; // mul
        #10; // Wait for a clock cycle
        $display("Test case 2: %d * %d = %d", rs1, rs2, mdu_result);
        if (mdu_result !== 35) $display("Test case 2 failed");

        // Test case 3: mul (10 * 20)
        rs1 = 32'd10;
        rs2 = 32'd20;
        mdu_op = 3'b000; // mul
        #10; // Wait for a clock cycle
        $display("Test case 3: %d * %d = %d", rs1, rs2, mdu_result);
        if (mdu_result !== 200) $display("Test case 3 failed");

        // End of simulation
        $finish;
    end
    
endmodule

