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

reg state = 4'b0000;
reg pc_update = 1'b0;
reg branch = 1'b0;
reg ALU_operation = 2'b00;


always @ (posedge clock) begin

    //ALU Decoder
    case(ALU_operation)
        2'b00: ALU_control = 2'b000;
        2'b01: ALU_control = 2'b001;
        2'b10: begin
            case(funct3)
                3'b010: ALU_control = 3'b101;
                3'b110: ALU_control = 3'b110;
                3'b111: ALU_control = 3'b011;
                3'b000: begin
                    case({opcode[5],funct7[5]})
                        2'b00, 2'b01, 2'b10: ALU_control = 3'b000;
                        2'b11: ALU_control = 3'b001;
                    endcase
                end
            endcase
        end
    endcase

    //pc write control signal
    pc_write = (zero && branch) || pc_update;

    //Immediate control:
    case(opcode)
        7'd3: immediate_source = 2'b00;
        7'd35: immediate_source = 2'b01;
        7'd51: immediate_source = 2'bXX;
        7'd99: immediate_source = 2'b10;
    endcase

    //State machine
    case (state)
    4'd0: begin // S0: Fetch
        address_source = 1'b0;
        ir_write = 1'b1;
        ALU_source_A = 2'b00;
        ALU_source_B = 2'b10;
        ALU_operation = 2'b00;
        result_source = 2'b10;
        
        state = 4'd1;
    end

    4'd1: begin // S1: Decode
        ALU_source_A = 2'b01;
        ALU_source_B = 2'b01;
        ALU_operation = 2'b00;

        case (opcode)
            7'b0000011, 7'b0100011: state = 4'd2; // lw or sw 
            7'b0110011: state = 4'd6; // R-type
            7'b0010011: state = 4'd8; // I-type ALU
            7'b1101011: state = 4'd9; // JAL
            7'b1100011: state = 4'd10; // BEQ
        endcase
    end

    4'd2: begin // S2: MemAdr
        ALU_source_A = 2'b00;
        ALU_source_B = 2'b10;
        ALU_operation = 2'b00;

        case (opcode)
            7'b0000011: state = 4'd3; // lw 
            7'b0100011: state = 4'd5; // sw
        endcase
    end

    4'd3: begin //S3: MemRead
        result_source = 2'b00;
        address_source = 1'b1;

        state = 4'd4;
    end

    4'd4: begin //S4: MemWriteBack
        result_source = 2'b01;
        register_write = 1'b1;

        state = 4'd0;
    end

    4'd5: begin //S5: MemWrite
        result_source = 2'b00;
        address_source = 1'b1;
        memory_write = 1'b1;

        state = 4'd0;
        
    end

    4'd6: begin //S6: ExecuteR
        ALU_source_A = 2'b10;
        ALU_source_B = 2'b00;
        ALU_operation = 2'b10;
        
        state = 4'd7; 
    end

    4'd7: begin //S7: ALU WriteBack
        result_source = 2'b00;
        register_write = 1'b1

        state = 4'd0;
    end

    4'd8: begin //S8: ExecuteI
        ALU_source_A = 2'b10;
        ALU_source_B = 2'b01;
        ALU_operation = 2'b10;
        
        state = 4'd7; 
    end

    4'd9: begin //S9: JAL
        ALU_source_A = 2'b01;
        ALU_source_B = 2'b10;
        ALU_operation = 2'b00;
        result_source = 2'b00;
        pc_update = 1'b1;
        
        state = 4'd7; 
    end

    4'd10: begin //s10: BEQ
        ALU_source_A = 2'b10;
        ALU_source_B = 2'b00;
        ALU_operation = 2'b01;
        result_source = 2'b00;

        state = 4'd0; 
    end

    default: state = 4'd0;

    endcase

end

endmodule