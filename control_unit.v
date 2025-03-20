module control_unit(
    input clock, zero,
    input [6:0] funct7, 
    input [2:0] funct3, 
    input [6:0] opcode,
    
    output pc_write, address_source, memory_write, ir_write, register_write,
    output result_source[1:0],
    output ALU_control[2:0], 
    output ALU_source_A[1:0],
    output ALU_source_B[1:0], 
    output immediate_source[1:0]
);

always @ (posedge clock) begin

end

endmodule