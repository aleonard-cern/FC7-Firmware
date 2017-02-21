----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/13/2016 04:40:07 PM
-- Design Name: 
-- Module Name: generate_data - Behavioral
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


-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity generate_data is
Port ( 
    clk_40 : in std_logic;
    data : out std_logic_vector(253 downto 0)
);
end generate_data;

architecture Behavioral of generate_data is
signal data_tmp : std_logic_vector(253 downto 0) := (0=>'1', 1=>'1', others=>'0');
begin
    process(clk_40)
    variable strip_num : integer :=12;

    begin
        if rising_edge(clk_40) then
--            if strip_num>248 then
--                strip_num := 0;
--            else
--                strip_num := strip_num+5;
--            end if;
--            data_tmp(253 downto 12) <= (others=>'0');
--            data_tmp(11 downto 10)  <= "11";
--            data_tmp(9 downto 0) <= (others=>'0');
              
            data <= data_tmp(4 downto 0) & data_tmp(253 downto 5);
            data_tmp <= data_tmp(4 downto 0) & data_tmp(253 downto 5);
        end if;
    end process;


end Behavioral;
