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

reg state 4'b0000;

always @ (posedge clock) begin
    //Immediate control:
    case(opcode)
        7'd3: immediate_source = 2'b00;
        7'd35: immediate_source = 2'b01;
        7'd51: immediate_source = 2'bXX;
        7'd99: immediate_source = 2'b10;
    endcase

    //State machine
    case (state)
    //instruction fetch 1: PC
    4'b0000: begin
    state = 4'b0001;
    end

    //instruction fetch 2: fill Instruction Register
    4'b0001: begin
    ir_write = 1'b1;
    state = 4'b0010; 
    end

    //sign extend and instruction decode state
    4'b0010: begin
    ir_write = 1'b0;
    immediate_source = 1'b1; //VERIFICAR ESSA PORRA
    if(opcode == LOADW_OP)begin
        state = 4'b0011;
        ALU_source_A = 2'b10;
        ALU_source_B = 2'b01;

    end

    //LW step 1: 
    4'b0001: begin
    ir_write = 1'b1;
    state = 4'b0010; 
    end


    end




    endcase


end

endmodule