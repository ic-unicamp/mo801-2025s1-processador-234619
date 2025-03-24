module alu(
    input [2:0] operation_control,
    input [31:0] source_A,
    input [31:0] source_B,
    output [31:0] operation_output,
    output zero
);

always @ (*) begin

    case(operation_control)
        3'b000:
            operation_output <= source_A + source_B;
        3'b001:
            operation_output <= source_A - source_B;
    endcase;
end

endmodule