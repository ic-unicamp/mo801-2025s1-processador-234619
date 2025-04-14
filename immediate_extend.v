module immediate_extend(
    input [31:0] full_instruction,
    input [2:0] immediate_source,
    output reg [31:0] immediate_extended
);

initial begin
    immediate_extended = 32'd0;
end

always @ (*)
begin
    case(immediate_source)
        3'b000: immediate_extended = {{20{full_instruction[31]}}, full_instruction[31:20]};
        3'b001: immediate_extended = {{20{full_instruction[31]}}, full_instruction[31:25], full_instruction[11:7]};
        3'b010: immediate_extended = {{19{full_instruction[31]}}, full_instruction[31], full_instruction[7],full_instruction[30:25], full_instruction[11:8], 1'b0};
        3'b011: immediate_extended = {{12{full_instruction[31]}},full_instruction[31], full_instruction[19:12], full_instruction[20], full_instruction[30:21],1'b0};
    endcase
end

endmodule