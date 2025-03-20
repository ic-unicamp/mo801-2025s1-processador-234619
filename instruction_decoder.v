// input: 
// output:

module instruction_decoder(
    input [31:0]    instruction,
    input           clk,
    output something
    );





always @ (posedge clock and instruction)

opcode <= instruction[6:0]
begin

    case (opcode)
    6'b000: begin // Type R: ALU register-register
        funct7 <= instruction[31:25];
        funct3 <= instruction[14:12];
        rs1 <= instruction[19:15];
        rs2 <= instruction[24:20];
        rd <= instruction[11:7];

    end

    6b000: begin // Type I: ALU immediate
        funct3 <= instruction[14:12];
        rs1 <= instruction[19:15];
        rd <= instruction[11:7];
        imm <= instruction[31:20];

        
    end


    6'b000: begin // Type S/B: store, compare and branch
        
    end 

    6'b000 begin // Type U/J: jump, jump and link
        
    end

    default:begin
        
    end//nop

    endcase;


end

endmodule