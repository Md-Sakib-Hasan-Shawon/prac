module gray_to_bin #(
    parameter WIDTH = 8
) (
    input  logic [WIDTH-1:0] gray,
    output logic [WIDTH-1:0] bin
);


  always_comb begin
    bin[WIDTH-1] = gray[WIDTH-1];
    for (int i = WIDTH-2; i >= 0; i--) begin
      bin[i] = bin[i+1] ^ gray[i];
    end
  end

endmodule
