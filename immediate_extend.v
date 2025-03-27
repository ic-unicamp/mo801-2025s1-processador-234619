module immediate_extend(
    input [31:0] full_instruction,
    input [1:0] immediate_source,
    output reg [31:0] immediate_extended = 32'd0
);

always @ (immediate_source)
begin
    case(immediate_source)
        2'b00: immediate_extended = full_instruction[31:20];
        2'b01: immediate_extended = {full_instruction[31:25],full_instruction[11:7]};
        2'b10: immediate_extended = full_instruction[31:12];
        2'b11: immediate_extended = 32'b1;
    endcase
end

endmodule