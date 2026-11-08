// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain
// SPDX-FileCopyrightText: 2026 Graeme Smecher
// SPDX-License-Identifier: CC0-1.0

module t;

  typedef struct {
    logic [3:0] inner[3];
    logic [3:0] z;
  } s_t;

  s_t arr[2];
  s_t f;

  initial begin
    // Unsupported: more than one element, of an array whose struct elements hold arrays
    force arr = '{default: f};
    release arr;
    force arr[1].inner = '{4'ha, 4'hb, 4'hc};
    release arr[1].inner;
    // Supported: a single element
    force arr[1].inner[2] = 4'h9;
    release arr[1].inner[2];
    $write("*-* All Finished *-*\n");
    $finish;
  end

endmodule
