module clocked_register(
        input clock, 
        input enable,
        input [31:0] inputA, 
        input [31:0] inputB,
        output reg [31:0] outputA, 
        output reg [31:0] outputB
    );
    
    always @ (posedge clock) begin
        if (enable) begin
            outputA[31:0] = inputA[31:0];
            outputB[31:0] = inputB[31:0];
        end
    
    end
    
    endmodule