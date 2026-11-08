// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain
// SPDX-FileCopyrightText: 2026 Graeme Smecher
// SPDX-License-Identifier: CC0-1.0

// verilog_format: off
`define stop $stop
`define checkh(gotv,expv) do if ((gotv) !== (expv)) begin $write("%%Error: %s:%0d:  got='h%x exp='h%x\n", `__FILE__,`__LINE__, (gotv), (expv)); `stop; end while(0)
// verilog_format: on

// A bit select forced within an element of a whole-array or row force: the other
// elements of the range must still read their forced values

module t;

  logic [7:0] a[4];  // Whole force, then a bit force within one element
  logic [7:0] b[3][2];  // Row force, then a bit force within one element of the row
  logic [99:0] w[3];  // As 'a', with elements wider than 64 bits
  logic [7:0] c[4];  // A bit force, then a whole force over it
  logic [7:0] d[4];  // Whole force, then a bit release within one element
  logic [7:0] rd[4];

  initial begin
    a = '{8'h01, 8'h02, 8'h03, 8'h04};
    b = '{'{8'h01, 8'h02}, '{8'h03, 8'h04}, '{8'h05, 8'h06}};
    w = '{100'h1, 100'h2, 100'h3};
    c = '{8'h01, 8'h02, 8'h03, 8'h04};
    d = '{8'h01, 8'h02, 8'h03, 8'h04};

    force a = '{default: 8'haa};
    force a[1][3:0] = 4'h5;
    force b[1] = '{8'hb1, 8'hb2};
    force b[1][1][7:4] = 4'h6;
    force w = '{default: {25{4'hc}}};
    force w[1][3:0] = 4'h5;
    force c[1][3:0] = 4'h5;
    force c = '{default: 8'hcc};
    force d = '{default: 8'hdd};
    release d[2][3:0];
    #1;
    `checkh(a[0], 8'haa);
    `checkh(a[1], 8'ha5);
    `checkh(a[2], 8'haa);
    `checkh(a[3], 8'haa);
    rd = a;
    `checkh(rd[1], 8'ha5);
    `checkh(rd[3], 8'haa);
    `checkh(b[0][1], 8'h02);
    `checkh(b[1][0], 8'hb1);
    `checkh(b[1][1], 8'h62);
    `checkh(b[2][0], 8'h05);
    `checkh(w[0], {25{4'hc}});
    `checkh(w[1], {{24{4'hc}}, 4'h5});
    `checkh(w[2], {25{4'hc}});
    `checkh(c[1], 8'hcc);
    `checkh(c[3], 8'hcc);
    `checkh(d[1], 8'hdd);
    `checkh(d[3], 8'hdd);

    release a[1];
    release b[1][1];
    release w[1];
    #1;
    `checkh(a[0], 8'haa);
    `checkh(a[1], 8'ha5);  // Keeps its forced value until next written
    `checkh(a[2], 8'haa);
    `checkh(a[3], 8'haa);
    `checkh(b[1][0], 8'hb1);
    `checkh(b[1][1], 8'h62);  // Keeps its forced value until next written
    `checkh(b[2][0], 8'h05);
    `checkh(w[0], {25{4'hc}});
    `checkh(w[2], {25{4'hc}});
    a[1] = 8'h11;
    a[2] = 8'h22;  // Still forced
    #1;
    `checkh(a[1], 8'h11);
    `checkh(a[2], 8'haa);

    $write("*-* All Finished *-*\n");
    $finish;
  end

endmodule
