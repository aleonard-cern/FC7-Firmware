-- Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2016.3 (lin64) Build 1682563 Mon Oct 10 19:07:26 MDT 2016
-- Date        : Fri Feb 17 15:46:55 2017
-- Host        : daq running 64-bit Linux Mint 17.2 Rafaela
-- Command     : write_vhdl -force -mode synth_stub -rename_top mmcm -prefix
--               mmcm_ mmcm_stub.vhdl
-- Design      : mmcm
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7k420tffg1156-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mmcm is
  Port ( 
    clk_out40 : out STD_LOGIC;
    clk_out320 : out STD_LOGIC;
    reset : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in1 : in STD_LOGIC
  );

end mmcm;

architecture stub of mmcm is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_out40,clk_out320,reset,locked,clk_in1";
begin
end;
