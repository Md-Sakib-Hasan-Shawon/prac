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

    localparam logic [33:0] max_green_time = 34'd15000000000;

    logic [33:0] clk_counter;
    logic timer_done;

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