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
        fast_cmd_o: out std_logic;
        mmcm_ready_i : in std_logic

    
    );
end fast_cmd_block;

architecture Behavioral of fast_cmd_block is
        signal fast_cmd : std_logic_vector(3 downto 0) := x"0";
        signal flag40 : std_logic := '0';
        signal previousFlag40 : std_logic := '1';
        signal frame_to_send: std_logic_vector(7 downto 0) := x"00"; 

begin
    
    process(clk40)
    begin
        if (rising_edge(clk40)) then
            flag40 <= not flag40;
            fast_cmd <= fast_cmd_i.fast_reset & fast_cmd_i.trigger & fast_cmd_i.test_pulse_trigger & fast_cmd_i.orbit_reset; 
        end if;
    end process;
    
    send_fast_cmd: process(clk320)
   
    begin
        if (rising_edge(clk320)) then
            if (mmcm_ready_i = '1' and reset_i = '0') then
                
                    if (flag40 /= previousFlag40) then
                        frame_to_send <= "0" & fast_cmd & "111";
                    else
                        frame_to_send <= frame_to_send(6 downto 0) & '0';
                    end if;
                    
                    previousFlag40 <= flag40;
                    
                    fast_cmd_o <= frame_to_send(7);
                    
            else 
            
                frame_to_send <= x"00";
                fast_cmd_o <= '0';
                previousFlag40 <= flag40;
                        
            end if;
        end if;
    end process;

end Behavioral;
