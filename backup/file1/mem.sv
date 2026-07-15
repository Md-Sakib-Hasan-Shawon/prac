module mem #(
    parameter int ADDR_WIDTH = 2,
    parameter int DATA_WIDTH = 4
)(

    input logic                     clk_i,
    input logic                     we_i,       // 1: write, 0: read

    input logic [ADDR_WIDTH-1:0]    waddr_i,    // write address
    input logic [DATA_WIDTH-1:0]    wdata_i,    // write data

    input logic [ADDR_WIDTH-1:0]    raddr_i,    // read address
    output logic[DATA_WIDTH-1:0]    rdata_o     // read data
);

    logic [DATA_WIDTH-1:0] memory [2**ADDR_WIDTH];

    always_ff @(posedge clk_i) begin
        if (we_i) begin
            memory[waddr_i] <= wdata_i;
        end
    end

    assign rdata_o = memory[raddr_i];

endmodule
