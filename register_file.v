module register_file(
    input clk, write_enable,
    input [4:0] rd, [4:0] rs1, [4:0] rs2,
    input [31:0] result,
    output reg [31:0] rd1, [31:0] rd2
);

reg [4:0] registers [31:0]

always @ (posedge clock) begin

    if (write_enable)
        registers[rd] <= result;
    
    rd1 <= registers[rs1]
    rd2 <= registers[rs2]

end

endmodule