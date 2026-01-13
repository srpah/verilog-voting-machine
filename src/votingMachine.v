module votingMachine(
  input        clock,
  input        reset,
  input        mode,
  input        button1_raw,
  input        button2_raw,
  input        button3_raw,
  input        button4_raw,
  output [7:0] led,
  output [2:0] winner_id,
  output [7:0] winner_votes,
  output       tie,
  output [7:0] cand1_count,
  output [7:0] cand2_count,
  output [7:0] cand3_count,
  output [7:0] cand4_count
);

  wire valid_vote_1, valid_vote_2, valid_vote_3, valid_vote_4;
  wire pressed_1, pressed_2, pressed_3, pressed_4;

  wire [7:0] c1, c2, c3, c4;
  wire anyValidVote = valid_vote_1 | valid_vote_2 | valid_vote_3 | valid_vote_4;

  buttonControl bc1(clock, reset, button1_raw, valid_vote_1, pressed_1);
  buttonControl bc2(clock, reset, button2_raw, valid_vote_2, pressed_2);
  buttonControl bc3(clock, reset, button3_raw, valid_vote_3, pressed_3);
  buttonControl bc4(clock, reset, button4_raw, valid_vote_4, pressed_4);

  voteLogger VL(
    clock, reset, mode,
    valid_vote_1, valid_vote_2, valid_vote_3, valid_vote_4,
    c1, c2, c3, c4
  );

  modeControl MC(
    clock, reset, mode, anyValidVote,
    c1, c2, c3, c4,
    pressed_1, pressed_2, pressed_3, pressed_4,
    led
  );

  results RES(c1, c2, c3, c4, winner_id, winner_votes, tie);

  assign cand1_count = c1;
  assign cand2_count = c2;
  assign cand3_count = c3;
  assign cand4_count = c4;

endmodule
