module apb_cdc #(
    parameter AW = 32,  // Address width
    parameter DW = 32   // Data width
) (
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // APB3 Master Interface
    ////////////////////////////////////////////////////////////////////////////////////////////////

    // Global signals
    input logic m_presetn,
    input logic m_pclk,

    // APB3 Control signals
    input logic m_psel,
    input logic m_penable,

    // APB3 Request signals
    input logic [  AW-1:0] m_paddr,
    input logic [     2:0] m_pprot,
    input logic            m_pwrite,
    input logic [  DW-1:0] m_pwdata,
    input logic [DW/8-1:0] m_pstrb,

    // APB3 Response signals
    output logic          m_pready,
    output logic [DW-1:0] m_prdata,
    output logic [DW-1:0] m_pslverr,

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // APB3 Slave Interface
    ////////////////////////////////////////////////////////////////////////////////////////////////

    // Global signals
    input logic s_presetn,
    input logic s_pclk,

    // APB3 Control signals
    output logic s_psel,
    output logic s_penable,

    // APB3 Request signals
    output logic [  AW-1:0] s_paddr,
    output logic [     2:0] s_pprot,
    output logic            s_pwrite,
    output logic [  DW-1:0] s_pwdata,
    output logic [DW/8-1:0] s_pstrb,

    // APB3 Response signals
    input logic          s_pready,
    input logic [DW-1:0] s_prdata,
    input logic [DW-1:0] s_pslverr

);

  logic comb_arst_n;

  logic m_penable_q;

  logic req_rd_en;
  logic resp_wr_en;

  logic req_empty;
  logic resp_empty;

  always_comb comb_arst_n = m_presetn & s_presetn;

  always_comb m_pready = m_penable & ~resp_empty;

  always_ff @(posedge m_pclk or negedge comb_arst_n) begin
    if (~comb_arst_n) begin
      m_penable_q <= 1'b0;
    end else begin
      m_penable_q <= m_penable;
    end
  end

  async_fifo #(
      .ADDR_WIDTH(1),
      .DATA_WIDTH(AW + 4 + DW + DW / 8)
  ) req_fifo (
      .wr_clk  (m_pclk),
      .wr_rst_n(comb_arst_n),
      .wr_en   (m_psel & m_penable & ~m_penable_q),
      .wr_data ({m_paddr, m_pprot, m_pwrite, m_pwdata, m_pstrb}),
      .full    (),
      .rd_clk  (s_pclk),
      .rd_rst_n(comb_arst_n),
      .rd_en   (req_rd_en),
      .rd_data ({s_paddr, s_pprot, s_pwrite, s_pwdata, s_pstrb}),
      .empty   (req_empty)
  );

  async_fifo #(
      .ADDR_WIDTH(1),
      .DATA_WIDTH(DW + 1)
  ) resp_fifo (
      .wr_clk  (s_pclk),
      .wr_rst_n(comb_arst_n),
      .wr_en   (resp_wr_en),
      .wr_data ({s_prdata, s_pslverr}),
      .full    (),
      .rd_clk  (m_pclk),
      .rd_rst_n(comb_arst_n),
      .rd_en   (~m_penable),
      .rd_data ({m_prdata, m_pslverr}),
      .empty   (resp_empty)
  );

  apb_cdc_fsm u_fsm (
      .arst_ni    (comb_arst_n),
      .clk_i      (m_pclk),
      .empty_i    (req_empty),
      .rd_en_o    (req_rd_en),
      .wr_en_o    (resp_wr_en),
      .s_psel_o   (s_psel),
      .s_penable_o(s_penable),
      .s_pready_i (s_pready)
  );

endmodule
