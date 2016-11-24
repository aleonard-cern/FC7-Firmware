----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/24/2016 01:38:25 PM
-- Design Name: 
-- Module Name: triggered_data_all_CBCs - Behavioral
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

entity triggered_data_all_CBCs is
Port ( 
    clk40 : in std_logic;
    clk320 : in std_logic;
    triggered_data_frame_r_array_i : in triggered_data_frame_r_array;
    trig_data_to_hb_o : out trig_data_to_hb_t
);
end triggered_data_all_CBCs;

architecture Behavioral of triggered_data_all_CBCs is
    type trig_data_to_hb_t_array is array (15 downto 0) of trig_data_to_hb_t;
    signal trig_data_tmp : trig_data_to_hb_t_array := (others => (others=>'0')); 
    signal is_sent : std_logic :='0';
    signal reset : std_logic_vector(7 downto 0) := (others=>'0');
      
begin

    process(clk320)
    
        variable previous_clk : std_logic := '0'; 
        variable current_clk : std_logic := '0';
        
        variable dummy : trig_data_to_hb_t := (others =>'0');

    begin
        if (rising_edge(clk320)) then
            
            previous_clk := current_clk;
            current_clk := clk40;
            for I in 0 to 7 loop
                if(triggered_data_frame_r_array_i(I).start="11" and reset(I)='0') then
                       trig_data_tmp(2*I) <= triggered_data_frame_r_array_i(I).start & triggered_data_frame_r_array_i(I).pipe_address & triggered_data_frame_r_array_i(I).channels(253 downto 127);    
                       trig_data_tmp(2*I+1) <= triggered_data_frame_r_array_i(I).latency_error & triggered_data_frame_r_array_i(I).buffer_overflow &  triggered_data_frame_r_array_i(I).l1_counter & triggered_data_frame_r_array_i(I).channels(126 downto 0);    
                       reset(I)<='1';
                elsif(reset=x"FF" and is_sent='1') then
                       reset(I)<='0';
    
                end if;
            end loop;
            
            if (previous_clk = '0' and current_clk = '1') then
                if(reset = x"FF" and trig_data_tmp(0) /= dummy) then
                
                    trig_data_to_hb_o <= trig_data_tmp(0);
                    trig_data_tmp <= dummy & trig_data_tmp(15 downto 1);
                    
                elsif (reset=x"FF" and trig_data_tmp(0)=dummy) then
                    trig_data_to_hb_o <= dummy;
                    is_sent <= '1';
                else  
                    is_sent <= '0';
                end if;                   
                
            end if;
            
            
        end if;
       
    end process;

end Behavioral;
