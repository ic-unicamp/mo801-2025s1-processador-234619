module clocked_register(
        input clock, 
        input resetn,
        input enable,
        input [31:0] inputA, 
        output reg [31:0] outputA 
    );
    
    always @ (posedge clock) begin
        if (~resetn) 
            outputA = 0;
        else if (enable) begin
            outputA[31:0] = inputA[31:0];
        end
    end
    
    endmodule