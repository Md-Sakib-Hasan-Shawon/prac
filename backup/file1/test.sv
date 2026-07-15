`timescale 1ns/1ps

module tb_traffic_light_controller;

    parameter int N = 8;
    
    // Inputs
    logic          clk;
    logic          rst_n;
    logic          ptr;
    logic  [N-1:0] traffic;

    // Outputs
    logic [N-1:0] green;
    logic [N-1:0] yellow;
    logic [N-1:0] red;

    // Instantiate Design Under Test (DUT)
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

    // Clock Generation (50MHz)
    always #10 clk = ~clk;

    // Helper task to pulse the trigger
    task automatic trigger_ptr();
        @(posedge clk);
        ptr = 1'b1;
        @(posedge clk);
        ptr = 1'b0;
    endtask

    // Helper task to check safety rule: No overlapping greens, and red calculation
    task automatic check_safety(string test_name);
        // Ensure no road has both green and yellow, and red is inverted complement
        if ((green & yellow) != '0) $error("[%s] CRITICAL: Traffic light overlap error! Green and Yellow active on same road.", test_name);
        if (red != ~(green | yellow)) $error("[%s] CRITICAL: Red light logic mismatch.", test_name);
    endtask

    // Main Stimulus
    initial begin
        // Initialize inputs
        clk = 0;
        rst_n = 0;
        ptr = 0;
        traffic = '0;

        // ----------------------------------------------------
        // Scenario 1: Reset Behavior
        // ----------------------------------------------------
        #40;
        $display("TC1: Checking Reset Behavior...");
        if (red != {N{1'b1}} || green != '0 || yellow != '0) 
            $error("TC1 Failed: All lights must be RED during reset.");
        
        rst_n = 1; // Release reset
        #5;

        // ----------------------------------------------------
        // Scenario 2: No Traffic Scenario
        // ----------------------------------------------------
        $display("TC2: Checking No Traffic Scenario...");
        traffic = '0;
        trigger_ptr();
        #5;
        if (red != {N{1'b1}}) $error("TC2 Failed: No traffic must result in All Red.");

        // ----------------------------------------------------
        // Scenario 3: Only One Road Has Traffic (Road 2)
        // ----------------------------------------------------
        $display("TC3: Checking Single Road Traffic...");
        traffic = 8'b0000_0100; // Road 2 has traffic
        trigger_ptr();
        #5;
        check_safety("TC3");
        if (green[2] !== 1'b1 || yellow !== '0) 
            $error("TC3 Failed: Only Road 2 should be Green. Yellow should be empty.");

        // ----------------------------------------------------
        // Scenario 4: All Roads Have Traffic
        // ----------------------------------------------------
        $display("TC4: Checking All Roads Traffic...");
        traffic = {N{1'b1}}; // All roads active
        
        // Loop through all roads to see sequential stepping
        for (int k = 0; k < N; k++) begin
            check_safety("TC4");
            // In all-traffic mode, the next sequential road should be warning yellow
            if (green[k] !== 1'b1) $error("TC4 Failed: Expected green on road %0d", k);
            if (yellow[(k+1)%N] !== 1'b1) $error("TC4 Failed: Expected yellow on road %0d", (k+1)%N);
            trigger_ptr();
            #5;
        end

        // ----------------------------------------------------
        // Scenario 5 & 6: Some Roads Traffic & Sequence Check
        // ----------------------------------------------------
        $display("TC5/6: Checking Sparse Traffic Round-Robin Skipping...");
        traffic = 8'b1001_0000; // Only Road 4 and Road 7 have traffic
        
        // Move state to stabilize onto active roads
        trigger_ptr(); #5; 
        
        $display("Checking transition sequence between active roads...");
        if (green[4] == 1'b1) begin
            if (yellow[7] !== 1'b1) $error("Sequence Error: Road 4 is green, Road 7 should be prep-yellow.");
        end else if (green[7] == 1'b1) begin
            if (yellow[4] !== 1'b1) $error("Sequence Error: Road 7 is green, Road 4 should be prep-yellow.");
        end

        // ----------------------------------------------------
        // Scenario 7: Post-Reset Combinational Behavior
        // ----------------------------------------------------
        $display("TC7: Checking Post-Reset immediate actions...");
        rst_n = 0; #20; rst_n = 1; // Quick Reset
        traffic = 8'b0000_1000; // Road 3 has traffic, ptr is LOW
        #1; // Wait for combinational settling
        if (green[3] !== 1'b1) begin
            $display("Note: Module outputs do not immediately change combinational after reset without a ptr edge.");
        end else begin
            $display("Note: Module evaluates outputs instantly upon post-reset traffic changes.");
        end

        $display("Simulation Verification Complete.");
        $finish;
    end

endmodule