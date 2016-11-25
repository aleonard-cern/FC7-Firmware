----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/25/2016 01:22:44 PM
-- Design Name: 
-- Module Name: tb_stub_readout - Behavioral
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

entity tb_stub_readout is
-- Port ( );
end tb_stub_readout;

architecture Behavioral of tb_stub_readout is
    signal clk320: std_logic := '0'; -- 320 MHz
    signal reset_i: std_logic := '0';
    signal stub_data_from_fe_i: stub_lines_r := (dp1=>'0',dp2=>'0',dp3=>'0',dp4=>'0',dp5=>'0');
    signal stub_data_from_fe_o: one_cbc_stubs_r := ( sync_bit=>'0', error_flags => '0', or254=>'0', s_overflow =>'0',stub1 =>(others=>'0'),bend1 =>(others=>'0'), stub2 =>(others=>'0'), bend2 =>(others=>'0'), stub3 =>(others=>'0'), bend3 =>(others=>'0'));

begin

uut_stub_data_readout : entity work.stub_data_readout 
    port map(
        clk320 => clk320, -- 320 MHz
        reset_i => reset_i,
        stub_data_from_fe_i => stub_data_from_fe_i,
        -- output triggered data frame
        stub_data_from_fe_o => stub_data_from_fe_o
        );
        
    clk320_prc: process
    begin
        clk320 <= '1';
        wait for 15.625 ns;
        clk320 <= '0';
        wait for 15.625 ns;
    end process;

    generate_stub : process
    begin
        stub_data_from_fe_i<=(dp1=>'0',dp2=>'0', dp3=>'0',dp4=>'0',dp5=>'1');
        wait for 31.25 ns;
--        stub_data_from_fe_i<=(dp1<='0',dp2<='0', dp3<='0',dp4<='0',dp5<='0');
--        wait for 31.25 ns;
--        stub_data_from_fe_i<=(dp1<='0',dp2<='0', dp3<='0',dp4<='0',dp5<='0');
--        wait for 31.25 ns;
--        stub_data_from_fe_i<=(dp1<='0',dp2<='0', dp3<='0',dp4<='0',dp5<='0');
--        wait for 31.25 ns;
--        stub_data_from_fe_i<=(dp1<='0',dp2<='0', dp3<='0',dp4<='0',dp5<='0');
--        wait for 31.25 ns;
--        stub_data_from_fe_i<=(dp1<='0',dp2<='0', dp3<='0',dp4<='0',dp5<='0');
--        wait for 31.25 ns;
--        stub_data_from_fe_i<=(dp1<='0',dp2<='0', dp3<='0',dp4<='0',dp5<='0');
--        wait for 31.25 ns;
--        stub_data_from_fe_i<=(dp1<='0',dp2<='0', dp3<='0',dp4<='0',dp5<='0');
--        wait for 31.25 ns;
    end process;        

end Behavioral;
