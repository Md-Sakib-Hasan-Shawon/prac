//Module Name: bin_to_gray_tb
//Module Description: This is a testbench for the bin_to_gray module. It generates random binary inputs and checks if the output gray code is correct.

module bin_to_gray_tb;

  parameter WIDTH = 8;

  logic [WIDTH-1:0] bin;
  logic [WIDTH-1:0] gray;

  bin_to_gray #(
      .WIDTH(WIDTH)
  ) dut (
      .bin (bin),
      .gray(gray)
  );

  initial begin

    $dumpfile("bin_to_gray_tb.vcd");
    $dumpvars(0, bin_to_gray_tb);

    $display("Starting Simulation for Khalid's testbench bin_to_gray...");

    repeat (10000) begin
      bin = $random;
      #10;
 
      if (gray === (bin ^ (bin >> 1))) $display("Check: PASS! | Expected Values: bin=%b, gray=%b | Got Values: bin=%b, gray=%b", bin, gray, bin, gray);
      else $display("Check: FAIL! | Expected Values: bin=%b, gray=%b | Got Values: bin=%b, gray=%b", bin, (bin ^ (bin >> 1)), bin, gray);
    end

    $display("Simulation Finished Successfully.");
    $finish;
  end

endmodule
