----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/28/2016 03:48:43 PM
-- Design Name: 
-- Module Name: stub_data_readout - Behavioral
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

entity stub_data_readout is

    port (
        clk320: in std_logic; -- 320 MHz
        reset_i: in std_logic;

        stub_data_from_fe_i: in stub_lines_r;
        
        -- output triggered data frame
        stub_data_from_fe_o: out one_cbc_stubs_r
        
    );

end stub_data_readout;

architecture Behavioral of stub_data_readout is

    
    
    type state_t is (SYNCING, DONE);
    signal state : state_t := SYNCING;




begin



    process(clk320)
    
        variable ten_sync_byte: std_logic_vector(79 downto 0);

    
        variable counter: integer := 8;
        
        variable stub1       : std_logic_vector(7 downto 0);
        variable stub2       : std_logic_vector(7 downto 0);
        variable stub3       : std_logic_vector(7 downto 0);
        variable bend1       : std_logic_vector(3 downto 0);
        variable bend2       : std_logic_vector(3 downto 0);
        variable bend3       : std_logic_vector(3 downto 0);
        variable sync_bit    : std_logic;
        variable error_flags : std_logic;
        variable or254       : std_logic;
        variable s_overflow  : std_logic;
        
        variable sum0: std_logic_vector(9 downto 0) := (others => '0');
        variable sum6: std_logic_vector(9 downto 0) := (others => '0');
       
    begin
        if(rising_edge(clk320)) then
            if (reset_i = '1') then
            
                -- reset input buffer --
                ten_sync_byte := (others => '0');
                
                -- go to SYNCING mode
                state <= SYNCING;
                
                --== reset output ==--
                stub_data_from_fe_o.sync_bit <= '0';
                stub_data_from_fe_o.error_flags <= '0';                            
                stub_data_from_fe_o.or254 <= '0';
                stub_data_from_fe_o.s_overflow <= '0';
                stub_data_from_fe_o.stub1 <= (others => '0');
                stub_data_from_fe_o.bend1 <= (others => '0');
                stub_data_from_fe_o.stub2 <= (others => '0');
                stub_data_from_fe_o.bend2 <= (others => '0');
                stub_data_from_fe_o.stub3 <= (others => '0');
                stub_data_from_fe_o.bend3 <= (others => '0');
                               
            else 
            
                ten_sync_byte := ten_sync_byte(78 downto 0) & stub_data_from_fe_i.dp5;
                
                sum0 := ten_sync_byte(79) & ten_sync_byte(71) & ten_sync_byte(63) & ten_sync_byte(55) & ten_sync_byte(47) & ten_sync_byte(39) & ten_sync_byte(31) & ten_sync_byte(23) & ten_sync_byte(15) & ten_sync_byte(7); 
                sum6 := ten_sync_byte(73) & ten_sync_byte(65) & ten_sync_byte(57) & ten_sync_byte(49) & ten_sync_byte(41) & ten_sync_byte(33) & ten_sync_byte(25) & ten_sync_byte(17) & ten_sync_byte(9) & ten_sync_byte(1); 
              
                case state is
                
                    when SYNCING =>
                    
                        --== reset output ==--
                        stub_data_from_fe_o.sync_bit <= '0';
                        stub_data_from_fe_o.error_flags <= '0';                            
                        stub_data_from_fe_o.or254 <= '0';
                        stub_data_from_fe_o.s_overflow <= '0';
                        stub_data_from_fe_o.stub1 <= (others => '0');
                        stub_data_from_fe_o.bend1 <= (others => '0');
                        stub_data_from_fe_o.stub2 <= (others => '0');
                        stub_data_from_fe_o.bend2 <= (others => '0');
                        stub_data_from_fe_o.stub3 <= (others => '0');
                        stub_data_from_fe_o.bend3 <= (others => '0');
                            
                        -- if we are lucky and we observe 10000000 (it might never appear however),
                        -- this pattern means that at the next rising edge we will get the sync bit
                        -- another possibility to get sync bit at next rising edge is sum0 = "1111111111"
                        -- meaning that 10 consecutive '1' were observed at the same place in the 8-bit of dp5
                        -- this must happen for sync bit (even if not lickey, this could also happen for another bit... life is hard) 
                        -- if or254 is '1' for 10 consecutive times, (could happen if there is a noisy strip)
                        -- then we make sure that sum0 does not count or254 bit, if it would be the case, then sum6
                        -- would count the sync bit and we would have sum6 = "1111111111"                      
                        if (ten_sync_byte(7 downto 0) = "10000000" or (sum0 = "1111111111" and sum6 /= "1111111111")) then 
                            
                            counter := 8;                -- so we can set the counter to 8 and go to DONE state at next rising edge
                            state <= DONE;                         

                        end if;
                                       
                    when DONE =>
                    
                      case counter is
                      
                        when 8 => 
                            stub1(counter - 1) := stub_data_from_fe_i.dp1;
                            stub2(counter - 1) := stub_data_from_fe_i.dp2;
                            stub3(counter - 1) := stub_data_from_fe_i.dp3;
                            bend2(3) := stub_data_from_fe_i.dp4;
                            sync_bit := stub_data_from_fe_i.dp5;
                            counter := 7;
                            
                        when 7 =>                             
                            stub1(counter - 1) := stub_data_from_fe_i.dp1;
                            stub2(counter - 1) := stub_data_from_fe_i.dp2;
                            stub3(counter - 1) := stub_data_from_fe_i.dp3;
                            bend2(2) := stub_data_from_fe_i.dp4;
                            error_flags := stub_data_from_fe_i.dp5;
                            counter := 6;                      

                        when 6 =>                             
                            stub1(counter - 1) := stub_data_from_fe_i.dp1;
                            stub2(counter - 1) := stub_data_from_fe_i.dp2;
                            stub3(counter - 1) := stub_data_from_fe_i.dp3;
                            bend2(1) := stub_data_from_fe_i.dp4;
                            or254 := stub_data_from_fe_i.dp5;
                            counter := 5;                         

                        when 5 =>
                            
                            -- the reset of the output is done in the midle of the 40MHz cycle --
                            -- is this necessary ? should we leave the output for the full cycle ? --
                            -- we could also reset it sooner, after one 320MHz clock cycle and the hybrid block
                            -- would run at the 320 MHz 
                            -- need to see with hybrid block what is expected as an input --                         
                            --== reset output ==--
                            stub_data_from_fe_o.sync_bit <= '0';
                            stub_data_from_fe_o.error_flags <= '0';                            
                            stub_data_from_fe_o.or254 <= '0';
                            stub_data_from_fe_o.s_overflow <= '0';
                            stub_data_from_fe_o.stub1 <= (others => '0');
                            stub_data_from_fe_o.bend1 <= (others => '0');
                            stub_data_from_fe_o.stub2 <= (others => '0');
                            stub_data_from_fe_o.bend2 <= (others => '0');
                            stub_data_from_fe_o.stub3 <= (others => '0');
                            stub_data_from_fe_o.bend3 <= (others => '0');
                            
                            stub1(counter - 1) := stub_data_from_fe_i.dp1;
                            stub2(counter - 1) := stub_data_from_fe_i.dp2;
                            stub3(counter - 1) := stub_data_from_fe_i.dp3;
                            bend2(0) := stub_data_from_fe_i.dp4;
                            s_overflow := stub_data_from_fe_i.dp5;
                            counter := 4;

                        when 4 =>    
                            stub1(counter - 1) := stub_data_from_fe_i.dp1;
                            stub2(counter - 1) := stub_data_from_fe_i.dp2;
                            stub3(counter - 1) := stub_data_from_fe_i.dp3;
                            bend1(3) := stub_data_from_fe_i.dp4;
                            bend3(3) := stub_data_from_fe_i.dp5;
                            counter := 3;

                        when 3 =>                             
                            stub1(counter - 1) := stub_data_from_fe_i.dp1;
                            stub2(counter - 1) := stub_data_from_fe_i.dp2;
                            stub3(counter - 1) := stub_data_from_fe_i.dp3;
                            bend1(2) := stub_data_from_fe_i.dp4;
                            bend3(2) := stub_data_from_fe_i.dp5;
                            counter := 2;

                        when 2 =>                             
                            stub1(counter - 1) := stub_data_from_fe_i.dp1;
                            stub2(counter - 1) := stub_data_from_fe_i.dp2;
                            stub3(counter - 1) := stub_data_from_fe_i.dp3;
                            bend1(1) := stub_data_from_fe_i.dp4;
                            bend3(1) := stub_data_from_fe_i.dp5;
                            counter := 1;
 
                        when 1 =>                             
                            stub1(counter - 1) := stub_data_from_fe_i.dp1;
                            stub2(counter - 1) := stub_data_from_fe_i.dp2;
                            stub3(counter - 1) := stub_data_from_fe_i.dp3;
                            bend1(0) := stub_data_from_fe_i.dp4;
                            bend3(0) := stub_data_from_fe_i.dp5;
                            
                            --== reset counter for next batch ==-
                            counter := 8; 
                            
                            --== set output ==-
                            stub_data_from_fe_o.sync_bit <= sync_bit;
                            stub_data_from_fe_o.error_flags <= error_flags;                            
                            stub_data_from_fe_o.or254 <= or254;
                            stub_data_from_fe_o.s_overflow <= s_overflow;
                            stub_data_from_fe_o.stub1 <= stub1;
                            stub_data_from_fe_o.bend1 <= bend1;
                            stub_data_from_fe_o.stub2 <= stub2;
                            stub_data_from_fe_o.bend2 <= bend2;
                            stub_data_from_fe_o.stub3 <= stub3;                            
                            stub_data_from_fe_o.bend3 <= bend3;
                                
                        when others =>
                                                
                            --== reset output ==--
                            stub_data_from_fe_o.sync_bit <= '0';
                            stub_data_from_fe_o.error_flags <= '0';                            
                            stub_data_from_fe_o.or254 <= '0';
                            stub_data_from_fe_o.s_overflow <= '0';
                            stub_data_from_fe_o.stub1 <= (others => '0');
                            stub_data_from_fe_o.bend1 <= (others => '0');
                            stub_data_from_fe_o.stub2 <= (others => '0');
                            stub_data_from_fe_o.bend2 <= (others => '0');
                            stub_data_from_fe_o.stub3 <= (others => '0');
                            stub_data_from_fe_o.bend3 <= (others => '0');
                                            
                      end case;  
                    
                end case;
            
            end if;
        
        end if;    
    end process;

end Behavioral;
