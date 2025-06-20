module core( // modulo de um core
  input clk, // clock
  input resetn, // reset que ativa em zero

  input [31:0] memory_data_in, // dado de entrada
  output wire [31:0] memory_address, // endereço de saída
  output wire  [31:0] memory_data_out, // dado de saída
  output wire memory_write_enable // write enable
);

//CONTROL UNIT WIRES
wire zero_signal;
wire [6:0] funct7; 
wire [2:0] funct3;
wire [6:0] opcode;

//CONTROL UNIT OUTPUT WIRES
wire cu_PC_write;
wire cu_address_source;
wire cu_instreg_write; 
wire cu_regfile_write;
wire [1:0] cu_immediate_src;
wire [1:0] cu_alu_mux_src_A;
wire [1:0] cu_alu_mux_src_B;
wire [2:0] cu_alu_control;
wire [1:0] cu_result_source;

//PC REGISTER CONTROL
reg [31:0] result;
wire [31:0] program_count;

//instruction/data memory registers
wire [31:0] old_program_count;
wire [31:0] instruction;

//breaking the instruction into parts
wire [4:0] register_source1;
wire [4:0] register_source2;
wire [4:0] register_destination;

wire [31:0] output_destination1;
wire [31:0] output_destination2;

wire [31:0] immediate_output;

assign funct7 = instruction[31:25];
assign funct3 = instruction[14:12];
assign opcode = instruction[6:0];

assign register_source1 = instruction[19:15];
assign register_source2 = instruction[24:20];


assign register_destination = (opcode == 7'd111) ? 5'd31 : instruction[11:7];

reg [31:0] alu_mux_output_A;
reg [31:0] alu_mux_output_B;

//register file register
wire [31:0] idm_to_result;
wire[31:0] register_destination1;

// ALU related signals
wire[31:0] alu_register_output;
wire [31:0] alu_result;

// Instantiating the blocks 
control_unit control0 (.clock(clk),
                       .resetn(resetn),
                       .zero(zero_signal), 
                       .funct7(funct7), 
                       .funct3(funct3), 
                       .opcode(opcode),
                       .pc_write(cu_PC_write), 
                       .address_source(cu_address_source), 
                       .memory_write(memory_write_enable),
                       .ir_write(cu_instreg_write), 
                       .register_write(cu_regfile_write), 
                       .result_source(cu_result_source),
                       .ALU_control(cu_alu_control), 
                       .ALU_source_A(cu_alu_mux_src_A), 
                       .ALU_source_B(cu_alu_mux_src_B),
                       .immediate_source(cu_immediate_src));


clocked_register program_counter (.clock(clk), 
                                  .resetn(resetn),
                                  .enable(cu_PC_write), 
                                  .inputA(result), 
                                  .outputA(program_count));


clocked_register old_pc_register(.clock(clk),
                                         .resetn(resetn),
                                         .enable(cu_instreg_write), 
                                         .inputA(program_count), 
                                         .outputA(old_program_count));

clocked_register instruction_register(.clock(clk),
                                      .resetn(resetn),
                                      .enable(cu_instreg_write),
                                      .inputA(memory_data_in),
                                      .outputA(instruction));


clocked_register data_result_register(.clock(clk), 
                                      .enable(1'b1), 
                                      .inputA(memory_data_out), 
                                      .outputA(idm_to_result));


register_file register_file0 (.clock(clk), 
                              .write_enable(cu_regfile_write),
                              .rd(register_destination), 
                              .rs1(register_source1),
                              .rs2(register_source2), 
                              .result(result),
                              .rd1(output_destination1), 
                              .rd2(output_destination2));

immediate_extend extender(.full_instruction(instruction), 
                          .immediate_source(cu_immediate_src),
                          .immediate_extended(immediate_output));

// separar em dois
clocked_register register_file_registerA (.clock(clk), 
                                          .enable(1'b1),
                                          .inputA(output_destination1), 
                                          .outputA(register_destination1));

clocked_register register_file_registerB (.clock(clk), 
                                          .enable(1'b1),
                                          .inputA(output_destination2), 
                                          .outputA(memory_data_out)); 


clocked_register alu_register(.clock(clk),
                            .enable(1'b1),
                            .inputA(alu_result), 
                            .outputA(alu_register_output));

alu alu0 (.operation_control(cu_alu_control), 
          .source_A(alu_mux_output_A), 
          .source_B(alu_mux_output_B),
          .operation_output(alu_result), 
          .zero(zero_signal)
          );

assign memory_address = cu_address_source ? result : program_count;

always @ (*) begin
    case (cu_alu_mux_src_A)
        2'b00: alu_mux_output_A = program_count;
        2'b01: alu_mux_output_A = old_program_count;
        2'b10: alu_mux_output_A = register_destination1;
        default: alu_mux_output_A = program_count;
    endcase

    case (cu_alu_mux_src_B)
        2'b00: alu_mux_output_B = memory_data_out;
        2'b01: alu_mux_output_B = immediate_output;
        2'b10: alu_mux_output_B = 32'd4;
        default: alu_mux_output_B = program_count;
    endcase
end

always @(cu_result_source) begin
    case (cu_result_source)
        2'b00: result = alu_result;
        2'b01: result = idm_to_result;
        2'b10: result = alu_register_output;
        default: result = alu_result;
    endcase
end


endmodule
