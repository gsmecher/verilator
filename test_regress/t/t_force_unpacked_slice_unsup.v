// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain
// SPDX-FileCopyrightText: 2026 Graeme Smecher
// SPDX-License-Identifier: CC0-1.0

module t;

  logic [3:0] a[4];
  logic [3:0] b[2][3];
  logic [3:0] src[2];

  initial begin
    // Unsupported: a slice of an unpacked array, of the array or of a row
    force a[1:2] = src;
    release a[1:2];
    force b[1][0:1] = src;
    release b[1][0:1];
    // Supported: the whole array, a row, an element
    force a = '{default: 4'h0};
    release a;
    force b[1] = '{default: 4'h0};
    release b[1];
    force a[0] = 4'h1;
    release a[0];
    $write("*-* All Finished *-*\n");
    $finish;
  end

endmodule
