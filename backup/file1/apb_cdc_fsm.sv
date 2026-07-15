module apb_cdc_fsm (
    input logic arst_ni,
    input logic clk_i,

    input  logic empty_i,
    output logic rd_en_o,

    output logic wr_en_o,

    output logic s_psel_o,
    output logic s_penable_o,
    input  logic s_pready_i
);

  typedef enum logic [1:0] {
    IDLE,
    SETUP,
    WAIT,
    ACCESS
  } state_t;

  state_t state;
  state_t next_state;

  always_comb begin
    next_state  = IDLE;
    rd_en_o     = '0;
    wr_en_o     = '0;
    s_psel_o    = '0;
    s_penable_o = '0;

    case (state)

      IDLE: begin
        if (~empty_i) next_state = SETUP;
      end

      SETUP: begin
        s_psel_o = '1;
        if (s_pready_i) next_state = ACCESS;
        else next_state = WAIT;
      end

      WAIT: begin
        s_psel_o    = '1;
        s_penable_o = '1;
        if (s_pready_i) next_state = ACCESS;
      end

      ACCESS: begin
        s_psel_o    = '1;
        s_penable_o = '1;
        rd_en_o     = '1;
        wr_en_o     = '1;
        next_state  = IDLE;
      end

      default: begin
        next_state = IDLE;
      end

    endcase
  end

  always_ff @(posedge clk_i or negedge arst_ni) begin
    if (~arst_ni) begin
      state <= IDLE;
    end else begin
      state <= next_state;
    end
  end

endmodule
