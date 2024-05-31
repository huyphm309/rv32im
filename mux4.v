module mux4 (
    input [31:0] dmem, alu, pc_4, mdu,
    input [1:0] WBsel,
    input reg reg_write_en, // Tín hi?u ?i?u khi?n ghi vào thanh ghi
    output reg [31:0] wb
);

always @(*) begin
 if (WBsel == 0) wb = dmem;
       else if (WBsel == 1) wb = alu;
       else if (WBsel == 2) wb = pc_4;
       else wb = mdu;
end
endmodule

