module sync_2FF #(
    parameter int WIDTH = 5
) (
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic [WIDTH-1:0]      in,
    output logic [WIDTH-1:0]      out
);

    logic [WIDTH-1:0] stage1;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            stage1         <= '0;
            out <= '0;
        end else begin
            stage1         <= in;
            out <= stage1;
        end
    end

endmodule
