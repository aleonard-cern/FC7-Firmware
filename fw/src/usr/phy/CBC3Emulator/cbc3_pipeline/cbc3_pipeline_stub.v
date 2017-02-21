// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.3 (lin64) Build 1682563 Mon Oct 10 19:07:26 MDT 2016
// Date        : Fri Feb 17 19:24:57 2017
// Host        : daq running 64-bit Linux Mint 17.2 Rafaela
// Command     : write_verilog -force -mode synth_stub -rename_top cbc3_pipeline -prefix
//               cbc3_pipeline_ cbc3_pipeline_stub.v
// Design      : cbc3_pipeline
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k420tffg1156-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_3_4,Vivado 2016.3" *)
module cbc3_pipeline(clka, ena, wea, addra, dina, clkb, enb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[0:0],addra[8:0],dina[279:0],clkb,enb,addrb[8:0],doutb[279:0]" */;
  input clka;
  input ena;
  input [0:0]wea;
  input [8:0]addra;
  input [279:0]dina;
  input clkb;
  input enb;
  input [8:0]addrb;
  output [279:0]doutb;
endmodule
