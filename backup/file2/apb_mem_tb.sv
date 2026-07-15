module apb_mem_tb;


  localparam int ADDR_WIDTH = 8;
  localparam int DATA_WIDTH = 32;
  localparam int STRB_WIDTH = DATA_WIDTH / 8;

  logic                  arst_n;
  logic                  clk = 0;

  bit                    edge_aligned;
  logic [DATA_WIDTH-1:0] read_back_data;

  int                    NUM_TESTS = 10;
  int                    DEBUG = 0;
  int                    pass_count;
  int                    fail_count;
  logic [ADDR_WIDTH-1:0] used_addresses [            $];

  logic [DATA_WIDTH-1:0] mem_array      [2**ADDR_WIDTH];

  apb_if #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
  ) u_apb_intf (
      .arst_ni(arst_n),
      .clk_i  (clk)
  );

  apb_mem #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
  ) u_dut (
      .arst_ni  (arst_n),
      .clk_i    (clk),
      .psel_i   (u_apb_intf.psel),
      .penable_i(u_apb_intf.penable),
      .paddr_i  (u_apb_intf.paddr),
      .pwrite_i (u_apb_intf.pwrite),
      .pwdata_i (u_apb_intf.pwdata),
      .pstrb_i  (u_apb_intf.pstrb),
      .pready_o (u_apb_intf.pready),
      .prdata_o (u_apb_intf.prdata),
      .pslverr_o(u_apb_intf.pslverr)
  );


  always #5ns clk <= ~clk;

  always @(posedge clk) begin
    edge_aligned = '1;
    #1ps;
    edge_aligned = '0;
  end

  // APB Write Task
  task automatic apb_write(input logic [ADDR_WIDTH-1:0] addr, input logic [DATA_WIDTH-1:0] data,
                           input logic [STRB_WIDTH-1:0] strb = '1);

    int slverr;
    u_apb_intf.master_write(addr, data, strb, slverr);
    if (slverr == 0) mem_array[addr] = data;
  endtask

  //APB Read Task
  task automatic apb_read(input logic [ADDR_WIDTH-1:0] addr, output logic [DATA_WIDTH-1:0] data);

    int slverr;
    u_apb_intf.master_read(addr, data, slverr);

    if (slverr == 0) begin
      if (data !== mem_array[addr]) begin
        $display("[%0t] ERROR: Read data mismatch at address %h. Expected: %h, Got: %h", $realtime,
                 addr, mem_array[addr], data);
        fail_count++;
      end else begin
        if (DEBUG) begin
          $display("[%0t] PASS: Read from address %h successful. Data: %h", $realtime, addr, data);
        end
        pass_count++;
      end
    end

  endtask

  initial begin
    #15ns;
    forever begin
      logic [ADDR_WIDTH-1:0] addr;
      logic                  write;
      logic [DATA_WIDTH-1:0] wdata;
      logic [STRB_WIDTH-1:0] strb;
      logic [DATA_WIDTH-1:0] rdata;
      logic                  slverr;

      u_apb_intf.monitor_tx(addr, write, wdata, strb, rdata, slverr);
      $display(
          "[%0t] APB Transaction - Addr: %h, Write: %b, WData: %h, Strb: %b, RData: %h, SlvErr: %b",
          $realtime, addr, write, wdata, strb, rdata, slverr);
    end
  end

  initial begin

    $timeformat(-9, 0, "ns");
    $dumpfile("apb_mem_tb.vcd");
    $dumpvars(0, apb_mem_tb);

    arst_n <= '0;
    clk    <= '0;
    u_apb_intf.master_reset();

    #5ns;

    arst_n <= '1;
    #10ns;

    $display("--- Starting APB Memory Tests ---");

    $display("\nLaunching %0d Random Writes...", NUM_TESTS);


    begin
      int output_var;
      fork
        apb_read('h5678, output_var);
        apb_write('h1234, 'hABCDEF00);
      join
    end

    // repeat (NUM_TESTS) begin
    //   logic [ADDR_WIDTH-1:0] rand_addr;
    //   rand_addr = $urandom_range(0, 63) * 4;

    //   used_addresses.push_back(rand_addr);
    //   apb_write(rand_addr, $urandom);
    // end

    // repeat (NUM_TESTS) begin
    //   int output_var;
    //   int addr;
    //   randcase
    //     1: addr = $urandom;
    //     9: addr = used_addresses[$urandom_range(0, used_addresses.size()-1)];
    //   endcase
    //   apb_read(addr, output_var);
    // end

    #1us;
    $display("--- APB Memory Simulation Complete ---");
    $finish;

  end

endmodule
