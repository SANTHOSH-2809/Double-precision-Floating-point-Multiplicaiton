module tb_floatingpointmultiplication;

  reg  [63:0] A, B;
  wire [63:0] final_product;

  // Instantiate DUT
  floatingpointmultiplication uut (
      .A(A),
      .B(B),
      .final_product(final_product)
  );

  // -----------------------------
  // Task to apply and display
  // -----------------------------
  task apply_test;
    input [63:0] a_in;
    input [63:0] b_in;
    input [127:0] test_name;
  begin
    A = a_in;
    B = b_in;
    #10;   // allow combinational settle

    $display("--------------------------------------------------");
    $display("TEST  : %s", test_name);
    $display("A     : %h", A);
    $display("B     : %h", B);
    $display("RESULT: %h", final_product);
  end
  endtask

  initial begin

    $dumpfile("floatingpointmultiplication.vcd");
    $dumpvars(0, tb_floatingpointmultiplication);

    A = 0;
    B = 0;

    // =========================
    // ZERO CASES
    // =========================
    apply_test(64'h0000000000000000, 64'h0000000000000000, "0 * 0");
    apply_test(64'h8000000000000000, 64'h0000000000000000, "-0 * 0");
    apply_test(64'h0000000000000000, 64'h3FF0000000000000, "0 * 1");

    // =========================
    // NORMAL CASES
    // =========================
    apply_test(64'h3FF0000000000000, 64'h4000000000000000, "1 * 2");
    apply_test(64'hBFF0000000000000, 64'h4000000000000000, "-1 * 2");
    apply_test(64'h3FF8000000000000, 64'h3FF8000000000000, "1.5 * 1.5");

    // =========================
    // OVERFLOW
    // =========================
    apply_test(64'h7FEFFFFFFFFFFFFF,
               64'h7FEFFFFFFFFFFFFF,
               "MAX * MAX");

    apply_test(64'h7FEFFFFFFFFFFFFF,
               64'h4000000000000000,
               "MAX * 2");

    // =========================
    // UNDERFLOW
    // =========================
    apply_test(64'h0010000000000000,
               64'h0010000000000000,
               "MIN_NORMAL * MIN_NORMAL");

    apply_test(64'h0000000000000001,
               64'h0000000000000001,
               "DEN * DEN");

    apply_test(64'h0000000000000001,
               64'h3FF0000000000000,
               "DEN * 1");

    // =========================
    // INFINITY
    // =========================
    apply_test(64'h7FF0000000000000,
               64'h3FF0000000000000,
               "INF * 1");

    apply_test(64'hFFF0000000000000,
               64'h3FF0000000000000,
               "-INF * 1");

    apply_test(64'h7FF0000000000000,
               64'h0000000000000000,
               "INF * 0");

    apply_test(64'h7FF0000000000000,
               64'hFFF0000000000000,
               "INF * -INF");

    // =========================
    // NaN
    // =========================
    apply_test(64'h7FF8000000000000,
               64'h3FF0000000000000,
               "NaN * 1");

    apply_test(64'h7FF8000000000000,
               64'h7FF0000000000000,
               "NaN * INF");

    // =========================
    // RANDOM
    // =========================
    repeat (10) begin
        apply_test($random, $random, "Random Test");
    end

    #20;
    $finish;
  end

endmodule
