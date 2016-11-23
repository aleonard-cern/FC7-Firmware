----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/23/2016 03:45:08 PM
-- Design Name: 
-- Module Name: fast_cmd_block - Behavioral
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


entity fast_cmd_block is
    port (
        -- clock at 40 MHz for reading input
        clk40:  in std_logic;
        -- clock at 320 MHz for sending output
        clk320: in std_logic;
        
        reset_i: in std_logic;
        
        fast_cmd_i: in cmd_fastbus;
        fast_cmd_o: out std_logic
    
    );
end fast_cmd_block;

architecture Behavioral of fast_cmd_block is
    
begin
    
    send_fast_cmd: process(clk320)
    
        variable prev_clk : std_logic := '0';
        variable current_clk: std_logic := '0';
        variable frame_to_send: std_logic_vector(7 downto 0) := "11000001"; 

    begin
        if (rising_edge(clk320)) then
            prev_clk := current_clk;
            current_clk := clk40;

            if (reset_i = '1') then
                fast_cmd_o <= '0';
                frame_to_send := "11000001";
            else

                if (prev_clk = '0' and current_clk = '1') then
                    frame_to_send := "110" & fast_cmd_i.fast_reset & fast_cmd_i.trigger & fast_cmd_i.test_pulse_trigger & fast_cmd_i.orbit_reset & '1';
                end if;
                
                fast_cmd_o <= frame_to_send(7);
                frame_to_send := frame_to_send(6 downto 0) & '0';
                
            end if;
        end if;
    end process;

end Behavioral;
