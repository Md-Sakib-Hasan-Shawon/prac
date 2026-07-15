module practice;

class axi_txn;

  rand bit [7:0]    id;
  rand bit [63:0]   addr;
  rand bit [63:0]   data[];
  rand bit [7:0]    user;

  rand bit [3:0]    len;
  rand bit [2:0]    size;
  rand bit [1:0]    burst;

  // -------------------------
  // Constraints
  // -------------------------
  constraint c_id    { id inside {[0:15]}; }
  constraint c_len   { len inside {0,1,3,7,15}; }
  constraint c_size  { size inside {[0:3]}; }
  constraint c_burst { burst inside {0,1,2}; }

  constraint c_4gb_boundary {
    (addr + ((1 << size) * (len + 1)) - 1) < 64'h1_0000_0000;
  }

  // -------------------------
  // Setup
  // -------------------------
//   function void pre_randomize();
//     data = new[16];
//     beat_addr = new[16];
//   endfunction

  // -------------------------
  // Post-randomize: build beats
  // -------------------------
  function void post_randomize();

    int unsigned beats;
    int unsigned beat_bytes;
    bit [63:0] end_addr;                               // end_addr = addr + (beats * beat_bytes) - 1
    bit [63:0] beat_addr[];                            // beat_addr[i] = addr + (i * beat_bytes)

    beats      = len + 1;
    beat_bytes = (1 << size);

    end_addr = addr + (beats * beat_bytes) - 1;

    // Generate per-beat addresses
    for (int i = 0; i < beats; i++) begin
      if (burst == 0) begin
        // FIXED burst → same address
        beat_addr[i] = addr;
      end
      else begin
        // INCR/WRAP → incrementing address
        beat_addr[i] = addr + (i * beat_bytes);
      end
      
    end

  endfunction

  // -------------------------
  // Display
  // -------------------------
  function void display();

    int beats = len + 1;

    $display("\n========== AXI TXN ==========");
    $display("ID    = %0d", id);
    $display("ADDR  = 0x%0h", addr);
    $display("LEN   = %0d (beats=%0d)", len, beats);
    $display("SIZE  = %0d", size);
    $display("BURST = %0d", burst);
    $display("END   = 0x%0h", end_addr);

    $display("---- BEAT ADDRESSES ----");
    for (int i = 0; i < beats; i++) begin
      $display("Beat %0d addr = 0x%0h", i, beat_addr[i]);
    end

    $display("=============================\n");

  endfunction

endclass


// =====================================================
// TEST
// =====================================================
initial begin
  axi_txn tx;

  repeat (5) begin
    tx = new();

    if (!tx.randomize())
      $fatal("Randomization failed");

    tx.display();
  end

  #10;
  $finish;
end

endmodule