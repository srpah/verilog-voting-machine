module results(
  input  wire [7:0] cand1,
  input  wire [7:0] cand2,
  input  wire [7:0] cand3,
  input  wire [7:0] cand4,
  output reg  [2:0] winner_id,
  output reg  [7:0] winner_votes,
  output reg        tie
);

  integer eq_count;

  always @(*) begin
    winner_id    = 3'd1;
    winner_votes = cand1;
    tie          = 1'b0;

    if (cand2 > winner_votes) begin winner_votes = cand2; winner_id = 3'd2; end
    if (cand3 > winner_votes) begin winner_votes = cand3; winner_id = 3'd3; end
    if (cand4 > winner_votes) begin winner_votes = cand4; winner_id = 3'd4; end

    eq_count = 0;
    if (cand1 == winner_votes) eq_count++;
    if (cand2 == winner_votes) eq_count++;
    if (cand3 == winner_votes) eq_count++;
    if (cand4 == winner_votes) eq_count++;

    if (eq_count > 1) begin
      tie = 1'b1;
      winner_id = 3'd0;
    end
  end
endmodule
