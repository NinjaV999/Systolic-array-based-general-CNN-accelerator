-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
-- Date        : Wed Oct 23 12:29:35 2024
-- Host        : NinjaV-PC running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               d:/HuaweiMoveData/Users/kiwi/Desktop/SA_lenet/project_1/project_1.srcs/sources_1/ip/bias2_rom3/bias2_rom3_stub.vhdl
-- Design      : bias2_rom3
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bias2_rom3 is
  Port ( 
    clka : in STD_LOGIC;
    ena : in STD_LOGIC;
    addra : in STD_LOGIC_VECTOR ( 1 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 15 downto 0 )
  );

end bias2_rom3;

architecture stub of bias2_rom3 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clka,ena,addra[1:0],douta[15:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "blk_mem_gen_v8_4_4,Vivado 2019.2";
begin
end;
