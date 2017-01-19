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
    reset_i : in std_logic;
    triggered_data_frame_r_array_i : in triggered_data_frame_r_array;
    trig_data_to_hb_o : out trig_data_to_hb_t
);
end triggered_data_all_CBCs;

architecture Behavioral of triggered_data_all_CBCs is
    type trig_data_to_hb_t_array is array (15 downto 0) of trig_data_to_hb_t;
    signal trig_data_tmp : trig_data_to_hb_t_array := (others => (others=>'0')); 
    signal is_sent : std_logic :='0';
    signal CBC_flag : std_logic_vector(NCBC_PER_HYBRID - 1 downto 0) := (others=>'0');
      
begin

    
    
    process(clk320)
        -- variable for current and previous 40MHz clock states 
        variable previous_clk : std_logic := '0'; 
        variable current_clk : std_logic := '0';
        constant flag_ones : std_logic_vector(NCBC_PER_HYBRID - 1 downto 0) := (others => '1'); 
        -- dummy nul vector for reseting output
        constant dummy : trig_data_to_hb_t := (others =>'0');
        
        variable cycle_for_sending : integer := 15;

    begin
        if (rising_edge(clk320)) then
            
            -- synchronous reset
            if (reset_i = '1') then
            
                is_sent <= '0';
                trig_data_tmp <= (others => (others=>'0')); 
                CBC_flag <= (others => '0');
                trig_data_to_hb_o <= (others => '0');
                cycle_for_sending := 15;
                
            else
                
                -- save current and previous 40MHz clock states
                previous_clk := current_clk;
                current_clk := clk40;
                
                
                for I in 0 to (NCBC_PER_HYBRID  - 1) loop
                    
                    if (triggered_data_frame_r_array_i(I).start = "11" and CBC_flag(I)= '0') then
                           trig_data_tmp(2*I) <=   triggered_data_frame_r_array_i(I).start &
                                                   triggered_data_frame_r_array_i(I).pipe_address &
                                                   triggered_data_frame_r_array_i(I).channels(253 downto 127);    
                           
                           trig_data_tmp(2*I+1) <= triggered_data_frame_r_array_i(I).latency_error &
                                                   triggered_data_frame_r_array_i(I).buffer_overflow &
                                                   triggered_data_frame_r_array_i(I).l1_counter &
                                                   triggered_data_frame_r_array_i(I).channels(126 downto 0); 
                                                      
                           CBC_flag(I) <= '1';
                           
                    elsif (CBC_flag = flag_ones and is_sent = '1') then
                           CBC_flag(I) <= '0';
                           
                    end if;
                    
                end loop;
                
                -- on 40MHz clock rising edge
                if (previous_clk = '0' and current_clk = '1') then
                
                    -- if all CBC have sent triggered data (CBC_flag == ff) and there are still data to be sent
                    --if(CBC_flag = x"FF" and trig_data_tmp(0) /= dummy) then
                    if(CBC_flag = flag_ones and cycle_for_sending > -1) then
                    
                        trig_data_to_hb_o <= trig_data_tmp(15 - cycle_for_sending);
                        --trig_data_tmp <= dummy & trig_data_tmp(15 downto 1);
                        cycle_for_sending := cycle_for_sending - 1;
                        
                    --elsif (CBC_flag=x"FF" and trig_data_tmp(0)=dummy) then
                    elsif (CBC_flag=flag_ones and cycle_for_sending = -1) then
                        trig_data_to_hb_o <= dummy;
                        trig_data_tmp <= (others => (others=>'0')); 
                        is_sent <= '1';
                        cycle_for_sending := 15;
                    else  
                        is_sent <= '0';
                        cycle_for_sending := 15;
                    end if;                   
                    
                end if;
                
            end if; --end reset condition
        end if;
       
    end process;

end Behavioral;
