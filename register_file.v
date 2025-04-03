module register_file(
    input clock, 
    input write_enable,

    input [4:0] rd, 
    input [4:0] rs1,
    input [4:0] rs2,

    input [31:0] result,

    output reg [31:0] rd1, 
    output reg [31:0] rd2
);

reg [31:0] registers [31:0];
integer i;

initial begin
  for (i = 0; i < 32; i = i + 1) begin
    registers[i] = 32'd0;
  end
end

always @ (posedge clock) begin

    if (write_enable)
        registers[rd] = result;
end

always @ (*) begin
    rd1 = registers[rs1][31:0];
    rd2 = registers[rs2][31:0];
end

endmodule