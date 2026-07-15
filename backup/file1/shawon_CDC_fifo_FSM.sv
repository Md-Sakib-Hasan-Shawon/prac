//FSM


module shawon_CDC_fifo_FSM (
    input  wire clk,
    input  wire rst_n,

    input  wire empty,
    input  wire s_pready,

    output reg  s_psel,
    output reg  s_penable,
    output reg  rd_en,
    output reg  we_en
);

    // State Encoding
    typedef enum logic [1:0] {
        IDLE   = 2'b00,
        SETUP  = 2'b01,
        WAIT   = 2'b10,
        ACCESS = 2'b11
    } state_t;

    state_t state, next_state;

    
    // State Register
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    
    // Next State Logic
    
    always @(*) begin
        next_state <= state;

        case (state)

            IDLE: begin
                if (!empty)
                    next_state <= SETUP;
            end

            SETUP: begin
                if (s_pready)
                    next_state <= ACCESS;
                else
                    next_state <= WAIT;
            end

            WAIT: begin
                if (s_pready)
                    next_state <= ACCESS;
            end

            ACCESS: begin
                next_state <= IDLE;
            end

            default: next_state <= IDLE;
        endcase
    end

    
    // Output Logic
    
    always @(*) begin
        // Defaults
        s_psel    = 1'b0;
        s_penable = 1'b0;
        rd_en     = 1'b0;
        we_en     = 1'b0;

        case (state)

            IDLE: begin
                s_psel    = 1'b0;
                s_penable = 1'b0;
            end

            SETUP: begin
                s_psel    = 1'b1;
                s_penable = 1'b0;
            end

            WAIT: begin
                s_psel    = 1'b1;
                s_penable = 1'b1;
            end

            ACCESS: begin
                s_psel    = 1'b1;
                s_penable = 1'b1;
            end

        endcase
    end

endmodule