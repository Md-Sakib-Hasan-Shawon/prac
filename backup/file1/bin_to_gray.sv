module bin_to_gray #(
    parameter WIDTH = 8
) (
    input  logic [WIDTH-1:0] bin,
    output logic [WIDTH-1:0] gray
);

  // YOU CODE HERE
always_comb begin
gray = bin ^ (bin >> 1); 
end


endmodule
