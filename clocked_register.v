module clocked_register(
        input clock, enable,
        input [31:0] inputA, [31:0] inputB,
        output [31:0] outputA, [31:0] outputB
    );
    
    always @ (posedge clock) begin
        if (enable) begin
            outputA <= inputA
            outputB <= inputB
        end
    
    end
    
    endmodule