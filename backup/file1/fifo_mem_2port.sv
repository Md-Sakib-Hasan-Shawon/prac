module fifo_mem_2port #(
    parameter int ADDR_WIDTH = 4,
    parameter int DATA_WIDTH = 32
) (
    input  logic                     wr_clk,
    input  logic                     wr_en,
    input  logic [ADDR_WIDTH-1:0]    wr_addr,
    input  logic [DATA_WIDTH-1:0]    wr_data,
    input  logic [ADDR_WIDTH-1:0]    rd_addr,
    output logic [DATA_WIDTH-1:0]    rd_data
);

    logic [DATA_WIDTH-1:0] memory [0:(1<<ADDR_WIDTH)-1];

    always_ff @(posedge wr_clk) begin
        if (wr_en) begin
            memory[wr_addr] <= wr_data;
        end
    end

    assign rd_data = memory[rd_addr];

endmodule
