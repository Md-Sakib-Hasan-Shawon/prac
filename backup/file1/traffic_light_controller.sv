module traffic_light_controller #(
    parameter int N = 8
)(
    input logic          clk,
    input logic          rst_n,
    input logic          ptr,
    input logic  [N-1:0] traffic,

    output logic [N-1:0] green,
    output logic [N-1:0] yellow,
    output logic [N-1:0] red
);

    localparam int IDX_W = $clog2(N);

    logic [IDX_W-1:0] current_green;
    logic [IDX_W-1:0] next_green;

    logic [IDX_W-1:0] next_after_current;
    logic [IDX_W-1:0] next_after_next;

    logic found1;
    logic found2;

    logic reset_state;

    // Find immediate next road has traffic or not

    always_comb begin
        found1 = 0;
        next_after_current = current_green;

        for (int i = 1; i <= N; i++) begin
            int idx;

            idx = (current_green + i) % N;

            if (~found1 && traffic[idx]) begin
                next_after_current = idx[IDX_W-1:0];
                found1 = 1;
            end
        end
    end

    // If immediate next road has no traffic, then search for next traffic road further

    always_comb begin
        found2 = 0;
        next_after_next = next_after_current;

        for (int i = 1; i <= N; i++) begin
            int idx;

            idx = (next_after_current + i) % N;

            if (~found2 && traffic[idx]) begin
                next_after_next = idx[IDX_W-1:0];
                found2 = 1;
            end
        end
    end


    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            current_green <= '0;
            next_green <= '0;
            reset_state <= 1'b1;
        end
        else if (ptr) begin

            reset_state <= 1'b0;

            if (traffic == '0) begin
                current_green <= '0;
                next_green <= '0;
            end

            else begin
                current_green <= next_after_current;
                next_green <= next_after_next;
            end
        end
    end


    always_comb begin
        green  = '0;
        yellow = '0;
    
        if (traffic != '0) begin
        
            green[current_green] = 1'b1;
    
            if (next_green != current_green)
                yellow[next_green] = 1'b1;
        end
    
        red = ~(green | yellow);
    
    end

endmodule
