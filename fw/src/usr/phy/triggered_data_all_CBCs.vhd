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
    --trig_data_to_hb_o : out trig_data_to_hb_t
    trig_data_to_hb_o : out triggered_data_frame_r
--    trig_data_to_hb_o : out trig_data_to_hb_t_array
);
end triggered_data_all_CBCs;

architecture Behavioral of triggered_data_all_CBCs is
    type trig_data_to_hb_t_array is array (15 downto 0) of trig_data_to_hb_t;
    signal trig_data_tmp : trig_data_to_hb_t_array := (others => (others=>'0')); 
    signal is_sent : std_logic :='0';
    signal CBC_flag : std_logic_vector(NUM_CHIPS - 1 downto 0) := (others=>'0');
--    type std_logic_vector_array is array(NUM_CHIPS - 1 downto 0) of std_logic_vector(126 downto 0);
--    signal trig_data_to_hb_even : std_logic_vector_array := (others => (others => '0'));
--    signal trig_data_to_hb_odd : std_logic_vector_array := (others => (others => '0'));

    
begin
    
--    cbc_loop : for I in 0 to (NUM_CHIPS  - 1) generate
--        odd : for index in 0 to 126 generate
--            trig_data_to_hb_even(I)(index) <= triggered_data_frame_r_array_i(I).channels(2*index);
--            trig_data_to_hb_odd(I)(index) <= triggered_data_frame_r_array_i(I).channels(2*index + 1);
--        end generate;
--    end generate;
    
    process(clk40)
        -- variable for current and previous 40MHz clock states 
        --variable previous_clk : std_logic := '0'; 
        --variable current_clk : std_logic := '0';
        constant flag_ones : std_logic_vector(NUM_CHIPS - 1 downto 0) := (others => '1'); 
        -- dummy nul vector for reseting output
        constant dummy : triggered_data_frame_r := (start => "00", latency_error => '0', buffer_overflow => '0', pipe_address => (others => '0'), l1_counter => (others => '0'), channels => (others => '0'));     
        variable cycle_for_sending : integer := NUM_CHIPS;
        variable nDummys : integer := NUM_CHIPS;

    begin
        if (rising_edge(clk40)) then
            
            -- synchronous reset
            if (reset_i = '1') then
            
                is_sent <= '0';
                trig_data_tmp <= (others => (others=>'0')); 
                CBC_flag <= (others => '0');
                --trig_data_to_hb_o <= (others => '0');
                cycle_for_sending := NUM_CHIPS;
                nDummys := NUM_CHIPS;
            else
                
                -- save current and previous 40MHz clock states
                --previous_clk := current_clk;
                --current_clk := clk40;
                
                
                -- on 40MHz clock rising edge
                --if (previous_clk = '0' and current_clk = '1') then
                
                -- if all CBC have sent triggered data (CBC_flag == ff) and there are still data to be sent
                if(cycle_for_sending > 0) then
                    trig_data_to_hb_o <= triggered_data_frame_r_array_i(NUM_CHIPS - cycle_for_sending);
                    cycle_for_sending := cycle_for_sending - 1;
                    nDummys := NUM_CHIPS;
                --elsif (CBC_flag=flag_ones and cycle_for_sending = -1) then
                elsif (cycle_for_sending = 0 and nDummys<8) then
                    trig_data_to_hb_o <= dummy;
                    nDummys:=nDummys+1;
                    --trig_data_tmp <= (others => (others=>'0')); 
                    --is_sent <= '1';
                    cycle_for_sending := NUM_CHIPS;
                else  
                    is_sent <= '0';
                    cycle_for_sending := NUM_CHIPS;
                    trig_data_to_hb_o <= dummy;
                    nDummys := NUM_CHIPS;
                end if;                   
                    
                --end if;
                
            end if; --end reset condition
        end if;
       
    end process;

end Behavioral;
