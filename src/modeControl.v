module modeControl(
  input             clock,
  input             reset,
  input             mode,
  input             valid_vote_casted,
  input      [7:0]  candidate1_vote,
  input      [7:0]  candidate2_vote,
  input      [7:0]  candidate3_vote,
  input      [7:0]  candidate4_vote,
  input             candidate1_button_pressed_level,
  input             candidate2_button_pressed_level,
  input             candidate3_button_pressed_level,
  input             candidate4_button_pressed_level,
  output reg [7:0]  leds
);

  localparam integer FLASH_CYCLES = 100;
  localparam integer FCW = $clog2(FLASH_CYCLES + 1);
  reg [FCW-1:0] flash_ctr;

  always @(posedge clock) begin
    if (reset)
      flash_ctr <= {FCW{1'b0}};
    else if (valid_vote_casted)
      flash_ctr <= FLASH_CYCLES;
    else if (flash_ctr > 0)
      flash_ctr <= flash_ctr - 1'b1;
  end

  always @(posedge clock) begin
    if (reset)
      leds <= 8'h00;
    else if (mode == 1'b0)
      leds <= (flash_ctr > 0) ? 8'hFF : 8'h00;
    else begin
      if (candidate1_button_pressed_level)
        leds <= candidate1_vote;
      else if (candidate2_button_pressed_level)
        leds <= candidate2_vote;
      else if (candidate3_button_pressed_level)
        leds <= candidate3_vote;
      else if (candidate4_button_pressed_level)
        leds <= candidate4_vote;
      else
        leds <= 8'h00;
    end
  end
endmodule
