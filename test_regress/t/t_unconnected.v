// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2020 Wilson Snyder
// SPDX-License-Identifier: CC0-1.0

module t (
    input clk
);

  wire o_n;
  wire o_0;
  wire o_1;
  wire [2:0] o_0w;  // Multi-bit pulls (#9165)
  wire [2:0] o_1w;

  // verilator lint_off PINMISSING
  sub_0 sub_0 (.o_0);
  sub_1 sub_1 (.o_1);
  sub_n sub_n (.o_n);
  sub_0 #(3) sub_0w (.o_0(o_0w));
  sub_1 #(3) sub_1w (.o_1(o_1w));
  // verilator lint_on PINMISSING

  always @(posedge clk) begin
    if (o_0 !== 1'b0) $stop;
    if (o_1 !== 1'b1) $stop;
    if (o_0w !== 3'b000) $stop;
    if (o_1w !== 3'b111) $stop;
    //4-state if (o_n !== 1'bz) $stop;
    $write("*-* All Finished *-*\n");
    $finish;
  end

endmodule

`unconnected_drive pull0
module sub_0 #(
    parameter W = 1
) (
    input [W-1:0] i,
    output wire [W-1:0] o_0
);
  assign o_0 = i;
endmodule

`unconnected_drive pull1
module sub_1 #(
    parameter W = 1
) (
    input [W-1:0] i,
    output wire [W-1:0] o_1
);
  assign o_1 = i;
endmodule

`nounconnected_drive
module sub_n (
    input i,
    output wire o_n
);
  assign o_n = i;
endmodule
