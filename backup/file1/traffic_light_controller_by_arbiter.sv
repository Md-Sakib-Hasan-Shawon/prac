module traffic_light_controller_by_arbiter #(
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

    logic reset_state;

    //HELP

    always_comb begin
        next_green = current_green; 

        for (int i = 1; i <= N; i++) begin
            int idx = (current_green + i) % N;
        
            if (traffic[idx]) begin
                next_green = idx[IDX_W-1:0];
                break; 
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            current_green <= '0;
            reset_state <= 1'b1;
        end

        else if (ptr) begin
            reset_state <= 1'b0;
            if (traffic == '0) begin
                current_green <= next_green;
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