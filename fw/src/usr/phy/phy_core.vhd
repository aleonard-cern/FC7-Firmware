----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/08/2016 01:00:19 PM
-- Design Name: 
-- Module Name: phy_core - rtl
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.user_package.ALL;

entity phy_core is
    generic(
        constant NHYBRID: natural range 1 to 32
    );
    port (
    
        clk_40              : in std_logic;
        clk_320             : in std_logic;
        reset_i             : in std_logic;
    
        -- fast command input bus
        cmd_fast_i          : in cmd_fastbus;
        
        -- fast command serial output
        cmd_fast_o          : out std_logic;
    
        -- hybrid block interface for triggered data
        trig_data_o         : out trig_data_to_hb_t_array(1 to NHYBRID);
    
        -- hybrid block interface for stub data
        stub_data_o         : out stub_data_to_hb_t_array(1 to NHYBRID);
        
        -- triggered data lines from CBC
        trig_data_i         : in trig_data_from_fe_t_array(1 to NHYBRID);
    
        -- stubs lines from CBC
        stub_data_i         : in stub_lines_r_array(1 to NHYBRID);
        
        -- slow control command from command generator
        cmd_request_i       : in cmd_wbus;
        
        -- slow control response to command generator
        cmd_reply_o         : out cmd_rbus 
        
        
    );
end phy_core;

architecture rtl of phy_core is

    signal dummy_signal             : std_logic := '0';

begin

    dummy_signal <= '1';
    
    --== fast command block ==--
    fast_cmd_inst: entity work.fast_cmd_block
    port map (
        clk40 => clk_40,
        clk320 => clk_320,
        reset_i => reset_i,
        fast_cmd_i => cmd_fast_i,
        fast_cmd_o => cmd_fast_o
    );

    --== slow control block ==--
    
    -- buffers
    
    
end rtl;
