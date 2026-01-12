module buttonControl #(
  parameter integer DEBOUNCE_CYCLES  = 500,
  parameter integer LONG_PRESS_CYCLES = 11
)(
  input  wire clock,
  input  wire reset,
  input  wire button_raw,
  output reg  valid_vote,
  output reg  pressed_level
);

  localparam integer DBW = $clog2(DEBOUNCE_CYCLES + 1);
  localparam integer LPW = $clog2(LONG_PRESS_CYCLES + 1);

  reg sync_0, sync_1;
  reg [DBW-1:0] debounce_cnt;
  reg debounced;
  reg [LPW-1:0] hold_cnt;

  always @(posedge clock) begin
    if (reset) begin
      sync_0        <= 1'b0;
      sync_1        <= 1'b0;
      debounce_cnt  <= {DBW{1'b0}};
      debounced     <= 1'b0;
      hold_cnt      <= {LPW{1'b0}};
      valid_vote    <= 1'b0;
      pressed_level <= 1'b0;
    end else begin
      // Synchronizer
      sync_0 <= button_raw;
      sync_1 <= sync_0;

      // Debounce logic
      if (sync_1 != debounced) begin
        if (debounce_cnt < DEBOUNCE_CYCLES)
          debounce_cnt <= debounce_cnt + 1'b1;
        else begin
          debounced    <= sync_1;
          debounce_cnt <= {DBW{1'b0}};
        end
      end else
        debounce_cnt <= {DBW{1'b0}};

      pressed_level <= debounced;

      // Long-press detection
      valid_vote <= 1'b0;
      if (debounced) begin
        if (hold_cnt == (LONG_PRESS_CYCLES - 1)) begin
          hold_cnt   <= hold_cnt + 1'b1;
          valid_vote <= 1'b1;
        end else if (hold_cnt < (LONG_PRESS_CYCLES - 1))
          hold_cnt <= hold_cnt + 1'b1;
      end else
        hold_cnt <= {LPW{1'b0}};
    end
  end
endmodule
