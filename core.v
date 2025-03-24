module core( // modulo de um core
  input clk, // clock
  input resetn, // reset que ativa em zero
  output reg [31:0] address, // endereço de saída
  output reg [31:0] data_out, // dado de saída
  input [31:0] data_in, // dado de entrada
  output reg we // write enable
);

always @(posedge clk) begin
  if (resetn == 1'b0) begin
    address <= 32'h00000000;
  end else begin
    address <= address + 4;
  end
  we = 0;
  data_out = 32'h00000000;
end 

//CONTROL UNIT WIRES
wire zero_signal;
wire [6:0] funct7, [2,0] funct3, [6:0] opcode;

//CONTROL UNIT OUTPUT WIRES
wire cu_PC_write, cu_address_source, cu_memory_write, cu_instreg_write, cu_regfile_write;
wire [1:0] cu_immediate_src, [1:0]cu_alusrc_A, [1:0]cu_alusrc_B, [2:0]cu_alu_control, [1:0]cu_result_source;

control_unit control0 (clk, zero_signal, funct7, funct3, opcode,
                       cu_PC_write, cu_address_source, cu_memory_write,
                       cu_instreg_write, cu_regfile_write, cu_result_source,
                       cu_alu_control, cu_alusrc_A, cu_alusrc_B,
                       cu_immediate_src);

//PC REGISTER CONTROL
wire [31:0] result;
wire [31:0] program_count;
clocked_register pc_register (clk, cu_PC_write, .inputA(result), .outputA(program_count));

//Instruction/data memory-related connections
wire [31:0] idm_address <= cu_address_source ? result : program_count;
wire [31:0] idm_data_in, [31:0] idm_data_out;
//remember: the clock here is just a stub
memory instdata_memory(.clock(clk), .we(cu_memory_write), .address(idm_address), .data_in(idm_data_in), .data_out(idm_data_out));

//instruction/data memory registers
wire[31:0] old_program_count;
wire[31:0] instruction;
clocked_register instruction_pc_register(.clock(clk), .enable(cu_instreg_write), 
                                        .inputA(program_count), .outputA(old_program_count),
                                        .inputB(idm_data_out), .outputB(instruction));

wire [31:0] idm_to_result;
clocked_register data_result_register(.clock(clk), .enable(1'b1), .inputA(idm_data_out), .outputA(idm_to_result));

//breaking the instrcutction into parts

wire[4:0] register_source1;
wire[4:0] register_source2;
wire[4:0] register_destination;

wire[31:0] output_destination1;
wire[31:0] output_destination2;

wire[24:0] immediate_value;
wire[31:0] immediate_output;

funct7 <= instruction[31:25];
funct3 <= instruction[14:12];
opcode <= instruction[6:0];

register_source1 <= instruction[19:15];
register_source2 <= instruction[24:20];
register_destination <= instruction[11:7];

immediate_value <= instruction[31:7];

opcode <= instruction[];
opcode <= instruction[];

register_file register_file0 (.clock(clk), .write_enable(cu_regfile_write),
                              .rd(register_destination), .rs1(register_source1),
                              .rs2(register_source2), .result(result),
                              .rd1(output_destination1), .rd2(output_destination2));

immediate_extend extender(.input(immediate_value).immediate_source(cu_immediate_src),
                          .output(immediate_output));

//register file register

wire[31:0] register_destination1;
//wire[31:0] register_destination2 <= idm_data_in;

clocked_register register_file_register (.clock(clk), .enable(1'b1),
                                         .inputA(output_destination1), .outputA(register_destination1),
                                         .inputB(output_destination2), .outputB(idm_data_in));

// mux before ALU logic
wire[31:0] alu_mux_A;
wire[31:0] alu_mux_B;

case (cu_alusrc_A)
    2'b00: alu_mux_A <= program_count;
    2'b01: alu_mux_A <= old_program_count;
    2'b10: alu_mux_A <= register_destination1;
    //CHECK THIS CASE
    2'b11: alu_mux_A <= program_count;
endcase;

case (cu_alusrc_B)
    2'b00: alu_mux_B <= idm_data_in;
    2'b01: alu_mux_B <= immediate_output;
    2'b10: alu_mux_B <= 32'd4;
    //CHECK THIS CASE
    2'b11: alu_mux_B <= program_count;
endcase;

//The ALU itself
wire[31:0] alu_result;
alu alu0 (.operation_control(cu_alu_control), .sourceA(alu_mux_A), .sourceB(alu_mux_B)
          .operation_output(alu_result), .zero(zero_signal));

//alu reg

wire[31:0] alu_register_output;
clocked_register alu_register(.clock(clk),.enable(1'b1),
                              .inputA(alu_result), .outputA(alu_register_output))


case (cu_result_source)
    2'b00: result <= alu_result;
    2'b01: result <= idm_to_result;
    2'b10: result <= alu_register_output;
    //CHECK THIS CASE
    2'b11: alu_mux_B <= ;
endcase;

endmodule
