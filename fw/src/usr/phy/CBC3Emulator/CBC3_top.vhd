----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/31/2016 04:36:15 PM
-- Design Name: 
-- Module Name: CBC3_top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use work.user_package.all;
use work.user_package.all;
use work.cbc3_emulator_package.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity CBC3_top is
  Port ( 
       scl_io_top : inout std_logic;
       sda_io : inout std_logic;
       reset_i : in std_logic; 
       --sda_miso_o_top : out std_logic;
       --sda_mosi_i_top : in std_logic;
       --sda_tri_o_top : out std_logic;
       clk320_top : in std_logic;
       fast_cmd_top : in std_logic;
       data_bit_out_top : out std_logic;
       stub_data_out : out stub_lines_r
       --i2c_mosi : in std_logic;
       --i2c_miso : out std_logic
  );
end CBC3_top;

architecture Behavioral of CBC3_top is

    --Jarne: do these signals have to be IOs for this top module???
--    signal ref_clk_i_top : std_logic :='0';
--    signal reset_i_top : std_logic :='0';
--    signal scl_io_top : std_logic := '1';
    signal sda_miso_o_top : std_logic := '0';
    signal sda_mosi_i_top : std_logic := '0';
    signal sda_tri_o_top : std_logic := '1';
--    signal clk320_top : std_logic :='0';
      signal regs_page1_top : array_reg_page1 := regs_page1_default;
      signal regs_page2_top : array_reg_page2 := regs_page2_default;
     
      signal synch_bit_top : std_logic := '0';  
      signal fast_reset_top:  std_logic := '0';
      signal trigger_top : std_logic := '0';
      signal test_pulse_trigger_top : std_logic := '0';
      signal orbit_reset_top : std_logic := '0';
      signal clk40_top : std_logic := '0';
      signal trig_lat_top : std_logic_vector (8 downto 0) := regs_page1_top(0)(0) & regs_page1_top(1); 
      signal scl_i : std_logic := '1';
      signal reset : std_logic := '0';
      
begin
    
    
    reset <= reset_i or fast_reset_top;
--==============================--
i2c: entity work.phy_i2c_slave
--==============================--
port map
(
    ref_clk_i =>clk40_top,
    reset_i => reset,
    scl_i => scl_i,
    sda_miso_o => sda_miso_o_top,
    sda_mosi_i => sda_mosi_i_top,
    sda_tri_o => sda_tri_o_top,
    
    regs_page1_o => regs_page1_top,
    regs_page2_o => regs_page2_top
);

 --==============================--
    slc_obuf : iobuf -- right now t => '1' is always input mode so the CBC does not drive the scl clock
 --==============================--
   generic map(
        drive       => 12,
        iostandard  => "lvcmos25",
        slew        => "slow"
    )
    port map(
        o           => scl_i,
        io          => scl_io_top,
        i           => '0',
        t           => '1'
    );
    
    SDA_iobuf : iobuf
    generic map (
        drive       => 12,
        iostandard  => "lvcmos25",
        slew        => "slow"
    )
    port map (
        o           => sda_mosi_i_top,
        io          => sda_io,
        i           => sda_miso_o_top,
        t           => sda_tri_o_top
    );
    
--==============================--
stubs: entity work.stub_data_output
--==============================--
port map
(
    reset_i => reset,
    clk320 => clk320_top,
    synch_bit_o => synch_bit_top,
    
    regs_page1_i => regs_page1_top,
    regs_page2_i => regs_page2_top,
    
    stub_data_to_fc7_o => stub_data_out
    
);

--==============================--
fast_cmd: entity work.fast_cmd
--==============================--
port map
(
    fast_cmd_i => fast_cmd_top,
    clk320 => clk320_top,
    
    fast_reset_o => fast_reset_top,
    trigger_o => trigger_top,
    test_pulse_trigger_o => test_pulse_trigger_top,
    orbit_reset_o => orbit_reset_top,
    clk40_o => clk40_top 
   
);

--==============================--
trig_data: entity work.trig_data
--==============================--
port map( 
    clk_40 => clk40_top,
    clk_320 => clk320_top,
    reset_i => reset,
    trigger_i => trigger_top,
    --trig_lat_i => trig_lat_top,
    synch_bit_i => synch_bit_top,
    data_bit_out => data_bit_out_top
);


end Behavioral;
