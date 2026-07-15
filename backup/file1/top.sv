module top #(
    parameter int ADDR_W = 32,
    parameter int DATA_W = 32
)(

    // Master APB Domain

    input  logic                 m_pclk,
    input  logic                 m_presetn,

    input  logic                 m_psel,
    input  logic                 m_penable,
    input  logic [ADDR_W-1:0]    m_paddr,
    input  logic [2:0]           m_pprot,
    input  logic                 m_pwrite,
    input  logic [DATA_W-1:0]    m_pwdata,
    input  logic [(DATA_W/8)-1:0]m_pstrb,

    output logic                 m_pready,
    output logic [DATA_W-1:0]    m_prdata,
    output logic                 m_pslverr,


    // Slave APB Domain

    input  logic                 s_pclk,
    input  logic                 s_presetn,

    output logic                 s_psel,
    output logic                 s_penable,
    output logic [ADDR_W-1:0]    s_paddr,
    output logic [2:0]           s_pprot,
    output logic                 s_pwrite,
    output logic [DATA_W-1:0]    s_pwdata,
    output logic [(DATA_W/8)-1:0]s_pstrb,

    input  logic                 s_pready,
    input  logic [DATA_W-1:0]    s_prdata,
    input  logic                 s_pslverr
);


    // Request FIFO Signals (Master → Slave)

    localparam int REQ_W =
        ADDR_W + 3 + 1 + DATA_W + (DATA_W/8);

    logic                   req_wr_en;
    logic                   req_rd_en;

    logic [REQ_W-1:0]       req_wr_data;
    logic [REQ_W-1:0]       req_rd_data;

    logic                   req_full;
    logic                   req_empty;


    // Response FIFO Signals (Slave → Master)

    localparam int RESP_W =
        DATA_W + 1;

    logic                   rsp_wr_en;
    logic                   rsp_rd_en;

    logic [RESP_W-1:0]      rsp_wr_data;
    logic [RESP_W-1:0]      rsp_rd_data;

    logic                   rsp_full;
    logic                   rsp_empty;


    // Request Capture (Master Side)

    assign req_wr_en = m_psel && m_penable && !req_full;

    assign req_wr_data = {
        m_paddr,
        m_pprot,
        m_pwrite,
        m_pwdata,
        m_pstrb
    };


    // Request FIFO

    async_fifo #(
        .DATA_WIDTH(REQ_W),
        .DEPTH(16)
    ) u_req_fifo (
        .wclk     (m_pclk),
        .wrst_n   (m_presetn),
        .w_en     (req_wr_en),
        .w_data   (req_wr_data),
        .full     (req_full),

        .rclk     (s_pclk),
        .rrst_n   (s_presetn),
        .r_en     (req_rd_en),
        .r_data   (req_rd_data),
        .empty    (req_empty)
    );


    // Slave FSM

    apb_slave_fsm #(
        .ADDR_W(ADDR_W),
        .DATA_W(DATA_W)
    ) u_slave_fsm (
        .clk           (s_pclk),
        .rst_n         (s_presetn),

        .fifo_empty    (req_empty),
        .fifo_rdata    (req_rd_data),
        .fifo_rd_en    (req_rd_en),

        .s_psel        (s_psel),
        .s_penable     (s_penable),
        .s_paddr       (s_paddr),
        .s_pprot       (s_pprot),
        .s_pwrite      (s_pwrite),
        .s_pwdata      (s_pwdata),
        .s_pstrb       (s_pstrb),

        .s_pready      (s_pready),
        .s_prdata      (s_prdata),
        .s_pslverr     (s_pslverr),

        .rsp_wr_en     (rsp_wr_en),
        .rsp_wr_data   (rsp_wr_data),
        .rsp_full      (rsp_full)
    );


    // Response FIFO

    async_fifo #(
        .DATA_WIDTH(RESP_W),
        .DEPTH(16)
    ) u_rsp_fifo (
        .wclk     (s_pclk),
        .wrst_n   (s_presetn),
        .w_en     (rsp_wr_en),
        .w_data   (rsp_wr_data),
        .full     (rsp_full),

        .rclk     (m_pclk),
        .rrst_n   (m_presetn),
        .r_en     (rsp_rd_en),
        .r_data   (rsp_rd_data),
        .empty    (rsp_empty)
    );


    // Master Response Logic

    assign rsp_rd_en = !rsp_empty;

    assign m_pready  = !rsp_empty;

    assign m_prdata  = rsp_rd_data[RESP_W-1:1];

    assign m_pslverr = rsp_rd_data[0];

endmodule