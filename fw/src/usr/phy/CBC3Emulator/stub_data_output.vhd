----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/12/2016 06:16:37 PM
-- Design Name: 
-- Module Name: stub_data_output - Behavioral
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
--for the random generator
use ieee.std_logic_arith.ALL;
use ieee.numeric_std.ALL;
--end of random generator stuff



-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.user_package.ALL;
use work.cbc3_emulator_package.ALL;

entity stub_data_output is
  Port (
      clk320: in std_logic; -- 320 MHz
      reset_i: in std_logic;
      stub_data_to_fc7_o: out stub_lines_r;
      
      regs_page1_i        : in array_reg_page1;
      regs_page2_i        : in array_reg_page2;
      synch_bit_o         : out std_logic  
   );
end stub_data_output;

architecture Behavioral of stub_data_output is


begin
    process(clk320)
        variable counter: integer := 0;
        --for the random generator
        --variable random_number_vector : std_logic_vector(4 downto 0);        
        --end of random generator stuff
        variable VTH_integer : integer := 0;
        variable dp5_temp : std_logic := '0';
        variable rand_num : integer range 4 downto 0 := 0;
        variable random_number_vector : std_logic_vector(4 downto 0) := (others => '0');
        variable VTH : std_logic_vector(9 downto 0) := (others => '0'); 
        
        begin
            --for the random generator
            rand_num:=(random_number_seed_A*rand_num+random_number_seed_B) mod 31;
            --rand_num <= rand_num+1;
            random_number_vector:=conv_std_logic_vector(rand_num,5);
            --random_number_vector:= (others => '1');
            --end of random generator stuff
            if (rising_edge(clk320)) then
                
                
                if (reset_i = '1') then
                    stub_data_to_fc7_o <= (dp1=>'0',dp2=>'0',dp3=>'0',dp4=>'0',dp5=>'0');
                    counter := 0;
                    synch_bit_o <= '0';

                else --output random data on all dp's (for this first version) except for the sync bit that always has to be one
                   
                    counter := counter + 1;
                    
                    if (counter = 8) then
                        dp5_temp := '1';
                        counter:=0;
                        synch_bit_o <= '1';
                    else 
                        dp5_temp := '0';
                        synch_bit_o <= '0';
                    end if; --end of counter condition 
                    VTH := regs_page1_i(80)(1) & regs_page1_i(80)(0) & regs_page1_i(79); 
                    VTH_integer := to_integer(ieee.numeric_std.unsigned(VTH));
                    --define ranges of the output of the CBC on the dp's depending on the
                    --setting of the VTH register. If threshold is low all 1's on dp1-3;
                    --if threshold medium random data on dp1-3; if threshold high all 0's 
                    --on dp1-
                    if(VTH_integer < 350) then
                        stub_data_to_fc7_o <= (dp1=>'1',dp2=>'1',dp3=>'1',dp4=>'0',dp5=>dp5_temp);
                    elsif(VTH_integer < 700) then
                        stub_data_to_fc7_o <= (dp1=>random_number_vector(0),dp2=>random_number_vector(1),dp3=>random_number_vector(2),dp4=>'0',dp5=>dp5_temp);
                    else
                        stub_data_to_fc7_o <= (dp1=>'0',dp2=>'0',dp3=>'0',dp4=>'0',dp5=>dp5_temp);                    
                    end if;--end of condition of VTH register    
                               
                end if; -- end reset condition
            
            end if; -- end rising_edge(clk320) condition    
                    
                   
    end process;

end Behavioral;
