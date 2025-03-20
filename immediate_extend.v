module immediate_extend(
    input [24:0] immediate,
    input immediate_source,
    output reg [31:0] immediate_extended = 32'd0
);

always @ (immediate_source)
begin
    immediate_extended <= immediate;
end

endmodule