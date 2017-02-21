----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/07/2017 11:38:46 AM
-- Design Name: 
-- Module Name: CBC3_generator - Behavioral
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
use ieee.std_logic_arith.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.user_package.all;
use work.cbc3_emulator_package.ALL;

entity CBC3_generator is
  Port ( 
        reset_i : in std_logic;
        clk320_i : in std_logic;
        cmd_fast_i : in std_logic;
        trig_data_o : out trig_data_from_fe_t_array;
        stub_data_o : out stub_lines_r_array_array;
        
        sda_miso_o_top : out std_logic_vector(0 to NUM_HYBRIDS-1);
        sda_mosi_i_top : in std_logic_vector(0 to NUM_HYBRIDS-1);
        scl_i : in std_logic_vector(0 to NUM_HYBRIDS-1);
        --scl_io : inout std_logic_vector(0 to NUM_HYBRIDS-1);
        --sda_io : inout std_logic_vector(0 to NUM_HYBRIDS-1)
        
        
        
     --clk40_i : in std_logic
       led2_red_o :out std_logic;
       led1_red_o : out std_logic;
     --  led1_blue_o :out std_logic;
     --  led1_green_o :out std_logic;
       clk40_test_i : in std_logic;
       mmcm_ready_i : in std_logic
  );
end CBC3_generator;

architecture Behavioral of CBC3_generator is 

  
begin

GEN_HYBRIDS:
for I in 0 to NUM_HYBRIDS-1 generate
    GEN_CBCS:
    for J in 0 to NUM_CHIPS-1 generate
        CBC3: entity work.CBC3_top 
        generic map(
            CHIP_ADDR => "111" & conv_std_logic_vector(J,4)
        )
        port map(
            reset_i => reset_i,
            clk320_top => clk320_i,
            
            fast_cmd_top => cmd_fast_i,
            
            data_bit_out_top => trig_data_o(I)(J),
            
            stub_data_out => stub_data_o(I)(J),
            
            sda_miso_o_top => sda_miso_o_top(I),
            sda_mosi_i_top => sda_mosi_i_top(I),
            scl_i => scl_i(I),
            
            
            led2_red_o => led2_red_o,
            led1_red_o => led1_red_o,
       --    led1_blue_o => led1_blue_o,
      --     led1_green_o => led1_green_o,
            clk40_test_i => clk40_test_i,
            --scl_io_top => scl_io(I),
            --sda_io => sda_io(I)
            mmcm_ready_i => mmcm_ready_i
            
           --clk40_i => clk40_i
        );
    end generate GEN_CBCS;
end generate GEN_HYBRIDS;

end Behavioral;
