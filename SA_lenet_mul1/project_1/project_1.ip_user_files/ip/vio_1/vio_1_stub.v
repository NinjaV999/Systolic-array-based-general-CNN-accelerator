// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Sat Oct 26 15:54:04 2024
// Host        : NinjaV-PC running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               D:/HuaweiMoveData/Users/kiwi/Desktop/SA_lenet/project_1/project_1.srcs/sources_1/ip/vio_1/vio_1_stub.v
// Design      : vio_1
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "vio,Vivado 2019.2" *)
module vio_1(clk, probe_in0, probe_in1, probe_out0, 
  probe_out1, probe_out2)
/* synthesis syn_black_box black_box_pad_pin="clk,probe_in0[15:0],probe_in1[3:0],probe_out0[0:0],probe_out1[3:0],probe_out2[7:0]" */;
  input clk;
  input [15:0]probe_in0;
  input [3:0]probe_in1;
  output [0:0]probe_out0;
  output [3:0]probe_out1;
  output [7:0]probe_out2;
endmodule
