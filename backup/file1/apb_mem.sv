module apb_mem #(
    // Parameters for address and data widths
    parameter int ADDR_WIDTH = 8,
    parameter int DATA_WIDTH = 32
) (
    // Global signals
    input logic arst_ni,  // Asynchronous reset, active low
    input logic clk_i,    // Clock input

    // APB Slave Interface Inputs
    input logic                        psel_i,     // Peripheral select
    input logic                        penable_i,  // Peripheral enable
    input logic [      ADDR_WIDTH-1:0] paddr_i,    // Peripheral address
    input logic                        pwrite_i,   // Peripheral write enable
    input logic [      DATA_WIDTH-1:0] pwdata_i,   // Peripheral write data
    input logic [(DATA_WIDTH / 8)-1:0] pstrb_i,    // Peripheral byte strobe

    // APB Slave Interface Outputs
    output logic                  pready_o,  // Peripheral ready
    output logic [DATA_WIDTH-1:0] prdata_o,  // Peripheral read data
    output logic                  pslverr_o  // Peripheral slave error
);

  logic                         mreq;
  logic [  ADDR_WIDTH-1:0]      maddr;
  logic                         mwe;
  logic [DATA_WIDTH/8-1:0][7:0] mwdata;
  logic [DATA_WIDTH/8-1:0]      mstrb;
  logic                         mack;
  logic [DATA_WIDTH/8-1:0][7:0] mrdata;
  logic                         mresp;

  logic [DATA_WIDTH/8-1:0][7:0] actual_wdata;

  always_comb begin
    foreach (mstrb[i]) actual_wdata[i] = mstrb[i] ? mwdata[i] : mrdata[i];
  end

  always_comb mresp = '0;
  always_comb mack = mreq;

  apb_memif #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
  ) u_translator (
      .arst_ni  (arst_ni),
      .clk_i    (clk_i),
      .psel_i   (psel_i),
      .penable_i(penable_i),
      .paddr_i  (paddr_i),
      .pwrite_i (pwrite_i),
      .pwdata_i (pwdata_i),
      .pstrb_i  (pstrb_i),
      .pready_o (pready_o),
      .prdata_o (prdata_o),
      .pslverr_o(pslverr_o),
      .mreq_o   (mreq),
      .maddr_o  (maddr),
      .mwe_o    (mwe),
      .mwdata_o (mwdata),
      .mstrb_o  (mstrb),
      .mack_i   (mack),
      .mrdata_i (mrdata),
      .mresp_i  (mresp)
  );

  mem #(
      .ADDR_WIDTH(ADDR_WIDTH - $clog2(DATA_WIDTH / 8)),
      .DATA_WIDTH(DATA_WIDTH)
  ) u_chinese_ching_chung_chua (

      .clk_i  (clk_i),
      .we_i   (mwe),
      .waddr_i(maddr[ADDR_WIDTH-1:$clog2(DATA_WIDTH / 8)]),
      .wdata_i(actual_wdata),
      .raddr_i(maddr[ADDR_WIDTH-1:$clog2(DATA_WIDTH / 8)]),
      .rdata_o(mrdata)
  );

endmodule
