module mem_tb;


  localparam int ADDR_WIDTH = 8;
  localparam int DATA_WIDTH = 32;

  logic                  clk_i = 0;
  logic                  we_i = 0;

  logic [ADDR_WIDTH-1:0] waddr_i = 0;
  logic [DATA_WIDTH-1:0] wdata_i = 0;

  logic [ADDR_WIDTH-1:0] raddr_i = 0;
  logic [DATA_WIDTH-1:0] rdata_o;

  int                    NUM_TESTS = 10000;
  int                    DEBUG = 0;

  bit                    edge_aligned;

  logic [DATA_WIDTH-1:0] mem_array         [2**ADDR_WIDTH];

  int                    pass_count;
  int                    fail_count;

  int                    used_addresses    [            $];

  mem #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
  ) u_dut (
      .clk_i(clk_i),
      .we_i(we_i),
      .waddr_i(waddr_i),
      .wdata_i(wdata_i),
      .raddr_i(raddr_i),
      .rdata_o(rdata_o)
  );

  always #5ns clk_i <= ~clk_i;

  always @(posedge clk_i) begin
    edge_aligned = '1;
    #1fs;
    edge_aligned = '0;
  end

  task automatic write(input logic [ADDR_WIDTH-1:0] addr, input logic [DATA_WIDTH-1:0] data);
    wait (edge_aligned);
    we_i    <= '1;
    waddr_i <= addr;
    wdata_i <= data;
    @(posedge clk_i);
    mem_array[addr] = data;
    we_i <= 0;
  endtask

  task automatic read(input logic [ADDR_WIDTH-1:0] addr, output logic [DATA_WIDTH-1:0] data);
    wait (edge_aligned);
    raddr_i <= addr;
    @(posedge clk_i);
    if (rdata_o !== mem_array[addr]) begin
      $display("[%0t] ERROR: Read data mismatch at address %h. Expected: %h, Got: %h", $realtime,
               addr, mem_array[addr], rdata_o);
      fail_count++;
    end else begin
      if (DEBUG)
        $display("[%0t] Read from address %h successful. Data: %h", $realtime, addr, rdata_o);
      pass_count++;
    end
    data = rdata_o;
  endtask

  initial begin
    $timeformat(-9, 0, "ns");
    $dumpfile("mem_tb.vcd");
    $dumpvars(0, mem_tb);

    repeat (NUM_TESTS) begin
      int addr;
      addr = $urandom;
      used_addresses.push_back(addr);
      write(addr, $urandom);
    end

    repeat (NUM_TESTS) begin
      int output_var;
      int addr;
      randcase
        1: addr = $urandom;
        9: addr = used_addresses[$urandom_range(0, used_addresses.size()-1)];
      endcase
      read(addr, output_var);
    end

    if (fail_count == 0) begin
      $display("\033[1;32mAll %0d tests passed!\033[0m", pass_count);
    end else begin
      $display("\033[1;31m%0d tests failed out of %0d\033[0m", fail_count, pass_count + fail_count);
    end

    #1us;
    $finish;
  end

endmodule
