
// instanciar entradas de next e de endereço

//se 

module program_counter(clk, counter_skip, instruction);

input clk;
input [8:0] counter_skip;
output [31:0] instruction;



always @ (posedge clk) begin

    if (counter_skip == 0) begin
        counter <= counter + 1;
    end 
    else begin
        counter <= counter + counter_skip;
    end

    instruction <= instruction_memory[]

end

endmodule