// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain
// SPDX-FileCopyrightText: 2026 Graeme Smecher
// SPDX-License-Identifier: CC0-1.0

// verilog_format: off
`define stop $stop
`define checkh(gotv,expv) do if ((gotv) !== (expv)) begin $write("%%Error: %s:%0d:  got='h%x exp='h%x\n", `__FILE__,`__LINE__, (gotv), (expv)); `stop; end while(0)
// verilog_format: on

// Force and release of a whole unpacked array, as Xilinx's XPM CDC models
// do to mimic GSR: force ff = '{default:0}; ... release ff;

module t;

  logic [3:0] var_arr[2];  // A variable: keeps the forced value after release
  wire [3:0] net_arr[2];  // A net: returns to its driver on release
  logic [3:0] src[2];
  logic [3:0] arr2d[2][3];  // Two unpacked dimensions
  logic [3:0] cpy[2];  // Forced to another array: follows it
  logic [3:0] elm[2];  // Forced by element, released whole
  logic [3:0] pca[2];  // Procedural continuous assign, then deassign
  logic [3:0] stm[2];  // Forced to a stream of a packed value
  logic [7:0] pkd;
  logic [3:0] rev[1:0];  // Opposite direction to src: pairs left to right
  logic [3:0] rvp[1:0];  // Forced to a pattern, which is left to right too

  assign net_arr[0] = src[0];
  assign net_arr[1] = src[1];

  initial begin
    var_arr[0] = 4'h1;
    var_arr[1] = 4'h2;
    src[0] = 4'h3;
    src[1] = 4'h4;
    arr2d = '{'{4'h1, 4'h2, 4'h3}, '{4'h4, 4'h5, 4'h6}};
    cpy = '{4'h1, 4'h2};
    elm = '{4'h1, 4'h2};
    pca = '{4'h1, 4'h2};
    stm = '{4'h1, 4'h2};
    pkd = 8'h5a;
    rev = '{4'h1, 4'h2};
    rvp = '{4'h1, 4'h2};
    #1;
    `checkh(net_arr[0], 4'h3);
    `checkh(net_arr[1], 4'h4);

    force var_arr = '{default: 4'h0};
    force net_arr = '{4'h5, 4'h6};
    force arr2d = '{default: 4'hf};
    force cpy = src;
    force elm[0] = 4'hc;
    force elm[1] = 4'hd;
    // verilator lint_off IEEEMAYDEPRECATE
    assign pca = src;
    // verilator lint_on IEEEMAYDEPRECATE
    force stm = {>>{pkd}};
    force rev = src;
    force rvp = '{4'ha, 4'hb};
    #1;
    `checkh(arr2d[0][0], 4'hf);
    `checkh(arr2d[1][2], 4'hf);
    `checkh(cpy[0], 4'h3);
    `checkh(cpy[1], 4'h4);
    `checkh(elm[0], 4'hc);
    `checkh(elm[1], 4'hd);
    `checkh(pca[0], 4'h3);
    `checkh(pca[1], 4'h4);
    `checkh(stm[0], 4'h5);
    `checkh(stm[1], 4'ha);
    `checkh(rev[1], 4'h3);
    `checkh(rev[0], 4'h4);
    `checkh(rvp[1], 4'ha);
    `checkh(rvp[0], 4'hb);
    `checkh(var_arr[0], 4'h0);
    `checkh(var_arr[1], 4'h0);
    `checkh(net_arr[0], 4'h5);
    `checkh(net_arr[1], 4'h6);

    var_arr[0] = 4'h7;  // Ignored while forced
    src[1] = 4'h8;
    #1;
    `checkh(var_arr[0], 4'h0);
    `checkh(net_arr[1], 4'h6);
    `checkh(cpy[1], 4'h8);  // A force is continuous
    `checkh(rev[0], 4'h8);
    `checkh(pca[1], 4'h8);

    release var_arr;
    release net_arr;
    release arr2d;
    release cpy;
    release elm;
    // verilator lint_off IEEEMAYDEPRECATE
    deassign pca;
    // verilator lint_on IEEEMAYDEPRECATE
    release stm;
    #1;
    `checkh(arr2d[1][2], 4'hf);
    `checkh(cpy[1], 4'h8);
    `checkh(elm[0], 4'hc);
    `checkh(pca[1], 4'h8);
    `checkh(stm[1], 4'ha);
    `checkh(var_arr[0], 4'h0);  // Keeps the forced value until next written
    `checkh(var_arr[1], 4'h0);
    `checkh(net_arr[0], 4'h3);
    `checkh(net_arr[1], 4'h8);

    var_arr[1] = 4'h9;
    arr2d[1][2] = 4'h9;
    cpy[1] = 4'h9;
    elm[0] = 4'h9;
    pca[1] = 4'h9;
    stm[1] = 4'h9;
    #1;
    `checkh(var_arr[1], 4'h9);
    `checkh(arr2d[1][2], 4'h9);
    `checkh(cpy[1], 4'h9);
    `checkh(elm[0], 4'h9);
    `checkh(pca[1], 4'h9);
    `checkh(stm[1], 4'h9);

    $write("*-* All Finished *-*\n");
    $finish;
  end

endmodule
