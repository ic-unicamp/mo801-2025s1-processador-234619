module alu(
    input [2:0] operation_control,
    input [31:0] source_A,
    input [31:0] source_B,
    output reg [31:0] operation_output,
    output reg zero
);

always @ (*) begin

    case(operation_control)
        //ADD
        3'b000:
            operation_output = source_A + source_B;

        //SUB
        3'b001:
            operation_output = source_A - source_B;

        //AND
        3'b010:
            operation_output = source_A & source_B;
        
        //OR
        3'b110:
            operation_output = source_A | source_B;
    endcase;
end

        //3'b000:
            //operation_output = source_A & source_B;
       
        //3'b001:
            //operation_output = source_A | source_B;

        //3'b010:
            //operation_output = source_A + source_B;
        
        //3'b110:
            //operation_output = source_A - source_B;

        //3'b111:
            //operation_output = (source_A < source_B) ? 32'b1: 32'b0;

        //default:
            //operation_output = source_A + source_B;


endmodule