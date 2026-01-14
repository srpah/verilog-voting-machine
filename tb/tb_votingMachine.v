`timescale 1ns/1ps

module test;

  // Inputs
  reg clock;
  reg reset;
  reg mode;
  reg button1_raw;
  reg button2_raw;
  reg button3_raw;
  reg button4_raw;

  // Outputs
  wire [7:0] led;
  wire [2:0] winner_id;
  wire [7:0] winner_votes;
  wire       tie;
  wire [7:0] cand1_count;
  wire [7:0] cand2_count;
  wire [7:0] cand3_count;
  wire [7:0] cand4_count;

  // Instantiate Unit Under Test (UUT)
  votingMachine uut (
    .clock(clock),
    .reset(reset),
    .mode(mode),
    .button1_raw(button1_raw),
    .button2_raw(button2_raw),
    .button3_raw(button3_raw),
    .button4_raw(button4_raw),
    .led(led),
    .winner_id(winner_id),
    .winner_votes(winner_votes),
    .tie(tie),
    .cand1_count(cand1_count),
    .cand2_count(cand2_count),
    .cand3_count(cand3_count),
    .cand4_count(cand4_count)
  );

  // Clock generation: 100 MHz (10 ns period)
  initial begin
    clock = 0;
    forever #5 clock = ~clock;
  end

  // Design timing parameters (must match DUT)
  localparam integer CLK_PERIOD_NS     = 10;
  localparam integer DEBOUNCE_CYCLES    = 500;
  localparam integer LONG_PRESS_CYCLES  = 11;

  localparam integer DEBOUNCE_TIME_NS =
      DEBOUNCE_CYCLES * CLK_PERIOD_NS;

  localparam integer LONG_PRESS_TIME_NS =
      DEBOUNCE_TIME_NS + (LONG_PRESS_CYCLES * CLK_PERIOD_NS);

  localparam integer RELEASE_WAIT_NS =
      DEBOUNCE_TIME_NS + 500;

  // Task: simulate a valid long button press
  task long_press(input integer which);
    begin
      button1_raw = 0;
      button2_raw = 0;
      button3_raw = 0;
      button4_raw = 0;

      case (which)
        1: button1_raw = 1;
        2: button2_raw = 1;
        3: button3_raw = 1;
        4: button4_raw = 1;
      endcase

      // Hold long enough for debounce + long press
      #(LONG_PRESS_TIME_NS + 500);

      // Release button
      button1_raw = 0;
      button2_raw = 0;
      button3_raw = 0;
      button4_raw = 0;

      // Wait for debounce of release
      #(RELEASE_WAIT_NS);
      #200;
    end
  endtask

  // LED blink monitor in voting mode
  reg [7:0] led_prev;
  initial led_prev = 8'h00;

  always @(posedge clock) begin
    led_prev <= led;
    if (led == 8'hFF && led_prev != 8'hFF && mode == 1'b0) begin
      $display("[%0t] LED BLINK detected (vote registered)", $time);
    end
  end

  // Waveform dump
  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,
      test.clock,
      test.reset,
      test.mode,
      test.button1_raw,
      test.button2_raw,
      test.button3_raw,
      test.button4_raw,
      test.led,
      test.cand1_count,
      test.cand2_count,
      test.cand3_count,
      test.cand4_count,
      test.winner_id,
      test.winner_votes,
      test.tie
    );
  end

  // Test sequence
  initial begin
    reset = 1;
    mode  = 0; // voting mode
    button1_raw = 0;
    button2_raw = 0;
    button3_raw = 0;
    button4_raw = 0;

    #100 reset = 0;

    $display("\n=== CASTING VOTES (Voting Mode) ===");

    // Candidate 1 → 3 votes
    long_press(1);
    long_press(1);
    long_press(1);

    // Candidate 2 → 6 votes
    long_press(2);
    long_press(2);
    long_press(2);
    long_press(2);
    long_press(2);
    long_press(2);

    // Candidate 3 → 4 votes
    long_press(3);
    long_press(3);
    long_press(3);
    long_press(3);

    // Candidate 4 → 1 vote
    long_press(4);

    #500;

    // Switch to result mode
    mode = 1;
    #1000;

    $display("\n=== RESULT MODE ===");
    $display("Holding candidate 2 button to display its votes");
    long_press(2);

    #500;

    // Final results
    $display("\n=== FINAL RESULTS ===");
    $display("Candidate 1 votes = %0d", cand1_count);
    $display("Candidate 2 votes = %0d", cand2_count);
    $display("Candidate 3 votes = %0d", cand3_count);
    $display("Candidate 4 votes = %0d", cand4_count);
    $display("Winner ID         = %0d", winner_id);
    $display("Winner Votes      = %0d", winner_votes);
    $display("Tie               = %b", tie);

    #100;
    $finish;
  end

  // Continuous console monitor
  initial begin
    $monitor("[%0t] mode=%b b1=%b b2=%b b3=%b b4=%b led=%02h "
             "c1=%0d c2=%0d c3=%0d c4=%0d winner=%0d tie=%b",
             $time, mode,
             button1_raw, button2_raw, button3_raw, button4_raw,
             led,
             cand1_count, cand2_count, cand3_count, cand4_count,
             winner_id, tie);
  end

endmodule
