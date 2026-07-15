module gray_to_bin_tb;

  parameter WIDTH = 8;

  logic [WIDTH-1:0] gray;
  logic [WIDTH-1:0] bin;

  gray_to_bin #(
      .WIDTH(WIDTH)
  ) dut (
      .gray(gray),
      .bin (bin)
  );

  logic [WIDTH-1:0] expected_bin;
  initial begin
    for (int i = 0; i < (1 << WIDTH); i++) begin
      gray = i ^ (i >> 1);
      expected_bin = i;

      if (bin !== expected_bin) begin
        $error("FAIL: Gray = %b Expected = %b Got = %b", gray, expected_bin, bin);
      end

    end

    $display("All tests passed");
    $finish;

  end

endmodule
