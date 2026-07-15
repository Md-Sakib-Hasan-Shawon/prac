module shawon_cdc_fifo #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 4
) (
    input  logic                     wr_clk,
    input  logic                     wr_rst_n,
    input  logic                     wr_en,
    input  logic [DATA_WIDTH-1:0]    wr_data,
    output logic                     full,
    input  logic                     rd_clk,
    input  logic                     rd_rst_n,
    output logic                     rd_en,
    output logic [DATA_WIDTH-1:0]    rd_data,
    output logic                     empty
);

    localparam int PTR_WIDTH = ADDR_WIDTH + 1;

    logic [PTR_WIDTH-1:0] wbin;
    logic [PTR_WIDTH-1:0] rbin;
    logic [PTR_WIDTH-1:0] wgray;
    logic [PTR_WIDTH-1:0] rgray;
    logic [PTR_WIDTH-1:0] wptr_gray_sync;
    logic [PTR_WIDTH-1:0] rptr_gray_sync;
    logic [ADDR_WIDTH-1:0] wr_addr;
    logic [ADDR_WIDTH-1:0] rd_addr;
    logic comb_rst;
    logic m_penable_q;

    assign wr_addr = wbin[ADDR_WIDTH-1:0];
    assign rd_addr = rbin[ADDR_WIDTH-1:0];
    assign comb_rst = wr_rst_n && rd_rst_n;

    assign
 
    fifo_mem_2port #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) mem (
        .wr_clk  (wr_clk),
        .wr_en   (q),
        .wr_addr (wr_addr),
        .wr_data (wr_data),
        .rd_addr (rd_addr),
        .rd_data (rd_data)
    );

    wptr_bin2gray #(.WIDTH(PTR_WIDTH)) wbin2gray (.bin(wbin), .gray(wgray));
    rptr_bin2gray #(.WIDTH(PTR_WIDTH)) rbin2gray (.bin(rbin), .gray(rgray));

    sync_2FF #(.WIDTH(PTR_WIDTH)) sync_wptr (
        .clk(rd_clk),
        .rst_n(comb_rst),
        .in(wgray),
        .out(wptr_gray_sync)
    );

    sync_2FF #(.WIDTH(PTR_WIDTH)) sync_rptr (
        .clk(wr_clk),
        .rst_n(comb_rst),
        .in(rgray),
        .out(rptr_gray_sync)
    );

    always_ff @(posedge wr_clk or negedge comb_rst) begin
        if (!comb_rst) begin
            wbin <= '0;
        end else if (wr_en && !full) begin
            wbin <= wbin + 1'b1;
        end
    end

    always_ff @(posedge rd_clk or negedge comb_rst) begin
        if (!comb_rst) begin
            rbin <= '0;
        end else if (rd_en && !empty) begin
            rbin <= rbin + 1'b1;
        end
    end

    assign full  = (wgray == {~rptr_gray_sync[PTR_WIDTH-1], rptr_gray_sync[PTR_WIDTH-2:0]});
    assign empty = (wptr_gray_sync == rgray);

endmodule