module tb_traffic_light_controller;
    parameter int N = 8;

    // Inputs
    logic          clk;
    logic          rst_n;
    logic          ptr;
    logic  [N-1:0] traffic;

    logic [N-1:0] green;
    logic [N-1:0] yellow;
    logic [N-1:0] red;

    traffic_light_controller #(
        .N(N)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .ptr(ptr),
        .traffic(traffic),
        .green(green),
        .yellow(yellow),
        .red(red)
    );

    // Clock Generation
    always #10 clk = ~clk;

    task automatic trigger_ptr();
        @(posedge clk);
        ptr = 1'b1;
        @(posedge clk);
        ptr = 1'b0;
    endtask

    task automatic check_safety(string test);
        if ((green & yellow) != '0) $error("[%s] CRITICAL: Traffic light overlap error! Green and Yellow active on same road.", test);
        if (red != ~(green | yellow)) $error("[%s] CRITICAL: Red light logic mismatch.", test);
    endtask

    initial begin
        clk = 0;
        rst_n = 0;
        ptr = 0;
        traffic = 0;


        // Scenario 1: Reset Behavior
        #40;
        $display("TC1");
        if (red != {N{1'b1}}) begin
            $error("TC1 Failed");
        end else begin
            $display("TC1 IS OK");
        end
        
        $display("TC7");
        rst_n = 1; // Release Reset
        traffic = 8'b00001000;
        #1;
        if (green[3] != 1'b1) begin
            $display("Outputs do not change immediately");
        end else begin
            $display("TC7 IS OK");
        end

        // Scenario 2
        $display("TC2");
        traffic = '0;
        trigger_ptr();
        #5;
        if (red != {N{1'b1}}) begin
            $error("TC2 failed");
        end else begin
            $display("TC2 IS OK");
        end

        // Scenario 3
        $display("TC3");
        traffic = 8'b00000100;
        trigger_ptr();
        #5;
        check_safety("TC3");
        if (green[2] !== 1'b1 || yellow !== '0) begin
            $error("TC3 Failed");
        end else begin
            $display("TC3 IS OK");
        end

        // Scenario 4
        $display("TC4");
        traffic = {N{1'b1}};

        for (int k = 0; k < N; k++) begin
            check_safety("TC4");

            if (green[k] !== 1'b1) begin
                $error("TC4_1 Failed");
            end

            if (yellow[(k+1)%N] !== 1'b1) begin
                $error("TC4_2 Failed");
            end
            trigger_ptr();
            #5;
        end

        // Scenario 5
        $display("TC5");
        traffic = 8'b10110101;
        if (green[0] == 1'b1) begin
            if (yellow[7] !== 1'b1) begin
                $error("Sequence Error");
            end
        end else begin
            $display("TC5 IS OK");
        end

        // Scenario 6
        $display("TC6");
        traffic = 8'b10010000;
        trigger_ptr();
        #5;

        $display("Checking Transition");
        if (green[4] == 1'b1) begin
            if (yellow[7] !== 1'b1) begin
                $error("Sequence Error");
            end
        end else if (green[7] == 1'b1) begin
            if (yellow[4] !== 1'b1) begin
                $error("Sequence Error");
            end
        end else begin
            $display("TC6 IS OK");
        end
        
        $display("Simulation Verification complete.");
        $finish;
    end
endmodule





        

