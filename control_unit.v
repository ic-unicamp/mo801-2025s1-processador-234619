module control_unit(
    input clock, 
    input zero,
    input resetn,
    input [6:0] funct7, 
    input [2:0] funct3, 
    input [6:0] opcode,
    
    output reg pc_write, 
    output reg address_source, 
    output reg memory_write, 
    output reg ir_write, 
    output reg register_write,
    output reg [1:0] result_source,
    output reg [2:0] ALU_control, 
    output reg [1:0] ALU_source_A,
    output reg [1:0] ALU_source_B, 
    output reg [1:0] immediate_source
);

reg [3:0] state;
reg [3:0] next_state;
reg pc_update;
reg branch;
reg ALU_operation;

//initial begin
    //state = 4'd0;
    //pc_update = 1'b0;
    //branch = 1'b0;
    //ALU_operation = 2'b00;
//end

always @ (*) begin
    //ALU Decoder
    case(ALU_operation)
        2'b00: ALU_control = 3'b000;
        2'b01: ALU_control = 3'b001;
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
end

//Immediate source selection
always @ (*) begin
    case(opcode)
            7'd3: immediate_source = 3'b000;
            7'd35: immediate_source = 3'b001;
            7'd51: immediate_source = 3'bXXX;
            7'd99: immediate_source = 3'b010;
            7'd19: immediate_source = 3'b000;
            7'd111: immediate_source = 3'b011;
            default: immediate_source = 3'b0;
    endcase
end

//pc write control signal 

always @ (*) begin
    pc_write = (zero && branch) || pc_update; 
end 

always @ (posedge clock) begin

    if (~resetn)
        state = 0;
    else
        state = next_state;
end

always @ (*) begin

    if (~resetn) begin
        next_state = 4'd0;
        pc_update = 1'b0;
        ALU_source_A = 2'b00;
        ALU_source_B = 2'b10;
        branch = 1'b0;
        ALU_operation = 2'b00;
        ir_write = 0;
        $display("RESETTING");
    end

    else begin
        address_source = 0;
        memory_write = 0;
        ir_write = 0;
        register_write = 0;
        result_source = 2'b00;
        ALU_source_A = 2'b00;
        ALU_source_B = 2'b10;
        pc_update = 1'b0;
        branch = 1'b0;
        next_state = 4'd0;
        pc_update = 1'b0;
        ALU_operation = 2'b00;


        //State machine
        case (state)
        4'd0: begin // S0: Fetch
        $display("S0: Fetch");
            address_source = 1'b0;
            ir_write = 1'b1;
            ALU_source_A = 2'b00;
            ALU_source_B = 2'b10;
            ALU_operation = 2'b00;
            result_source = 2'b00;
            pc_update = 1'b1;
            next_state = 4'd1;
        end

        4'd1: begin // S1: Decode
        $display("S1: Decode");
            ALU_source_A = 2'b01;
            ALU_source_B = 2'b01;
            ALU_operation = 2'b00;

        //$display("opcode %d, expected %d, state %d ", opcode, 7'b0010011, state);
            case (opcode)
                7'b0000011, 7'b0100011: next_state = 4'd2; // lw or sw 
                7'b0110011: next_state = 4'd6; // R-type
                7'b0010011: next_state = 4'd8; // I-type ALU
                7'b1101111: next_state = 4'd9; // JAL
                7'b1100011: next_state = 4'd10; // BEQ
                default: next_state = 4'd0; //Back to fetch in case of a strange opcode
            endcase
            $display("opcode %b, state %d", opcode, next_state);

        end

        4'd2: begin // S2: MemAdr
        $display("S2: Memory Address");
            ALU_source_A = 2'b10;
            ALU_source_B = 2'b01;
            ALU_operation = 2'b00;

            case (opcode)
                7'b0000011: next_state = 4'd3; // lw 
                7'b0100011: next_state = 4'd5; // sw
            endcase
        end

        4'd3: begin //S3: MemRead
            $display("S3: MemRead");
            result_source = 2'b10;
            address_source = 1'b1;

            next_state = 4'd4;
        end

        4'd4: begin //S4: MemWriteBack
            $display("S4: mem writeback");
            result_source = 2'b01;
            register_write = 1'b1;

            next_state = 4'd0;
        end

        4'd5: begin //S5: MemWrite
            $display("S5: Mem Write");
            result_source = 2'b10;
            address_source = 1'b1;
            memory_write = 1'b1;

            next_state = 4'd0;
            
        end

        4'd6: begin //S6: ExecuteR
            $display("S6: Execute R");
            ALU_source_A = 2'b10;
            ALU_source_B = 2'b00;
            ALU_operation = 2'b10;
            
            next_state = 4'd7; 
        end

        4'd7: begin //S7: ALU WriteBack
            $display("S7: ALU Writeback");
            result_source = 2'b10;
            register_write = 1'b1;

            next_state = 4'd0;
        end

        4'd8: begin //S8: ExecuteI
            $display("S8: ExecuteI");
            ALU_source_A = 2'b10;
            ALU_source_B = 2'b01;
            ALU_operation = 2'b10;
            //immediate_source = 2'b00;
            
            next_state = 4'd7; 
        end

        4'd9: begin //S9: JAL
            $display("S9: JAL");
            ALU_source_A = 2'b01;
            ALU_source_B = 2'b01;
            ALU_operation = 2'b10;
            result_source = 2'b00;
            pc_update = 1'b1;
            
            next_state = 4'd7; 
        end

        4'd10: begin //s10: BEQ
            ALU_source_A = 2'b10;
            ALU_source_B = 2'b00;
            ALU_operation = 2'b01;
            result_source = 2'b00;

            next_state = 4'd0; 
        end

        default: next_state = 4'd0;

        endcase
    end

end

endmodule