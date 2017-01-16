----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/22/2016 03:36:30 PM
-- Design Name: 
-- Module Name: triggered_data_readout - Behavioral
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

entity triggered_data_readout is
    port (
        clk320: in std_logic; -- 320 MHz
        reset_i: in std_logic;

        triggered_data_from_fe_i: in std_logic;
        sync_from_CBC_i: in std_logic;
        
        -- output triggered data frame
        triggered_data_frame_o: out triggered_data_frame_r
        
    );
end triggered_data_readout;


architecture FSM of triggered_data_readout is

    -- FMS states
    type state_t is (IDLE, CHECK_START, RECEIVING, OUTPUT);
    signal state : state_t := IDLE;
    
    -- temporary triggered data frame
    signal fullFrame: std_logic_vector(275 downto 0) := (others => '0');
    
    -- counter for number of bits to be received
    signal nBitsToBeReceived: integer := 276;

begin




    -- triggered data line
    process(clk320)

    begin
        if (rising_edge(clk320)) then

            if (reset_i = '1') then
            
                fullFrame <= (others =>'0');
                nBitsToBeReceived <= 276;
                state <= IDLE;
                triggered_data_frame_o.start <= "00";

            else
                case state is

                    when IDLE =>
                    
                        -- reset the triggered data output frame
                        triggered_data_frame_o <= (start => "00", latency_error => '0', buffer_overflow => '0', pipe_address => (others => '0'), l1_counter => (others => '0'), channels => (others => '0'));
                       
                        -- if sync_bit and first start bit are detected simultaneously
                        if (sync_from_CBC_i = '1' and triggered_data_from_fe_i = '1') then
                        
                            -- start filling the full frame with first start bit
                            fullFrame(nBitsToBeReceived - 1) <= triggered_data_from_fe_i;
                            
                            -- decrement counter of bit to be received
                            nBitsToBeReceived <= nBitsToBeReceived - 1;
                            
                            -- go to checkt start to confirm the second start bit
                            state <= CHECK_START;
                            
                        end if;

                    when CHECK_START =>
                    
                        -- read the second start bit, should be '1' to confirm start sequence 
                        if (nBitsToBeReceived = 275 and triggered_data_from_fe_i /= '1') then
                            -- the second start bit has not been detected, go back to iddle
                            nBitsToBeReceived <= 276;
                            state <= IDLE;
                            
                        else
                            -- the second start bit has been detected, fill the full frame
                            fullFrame(nBitsToBeReceived - 1) <= triggered_data_from_fe_i;
                            
                            -- decrement the counter
                            nBitsToBeReceived <= nBitsToBeReceived - 1;
                            
                            -- go to receiving state for the rest of the frame
                            state <= RECEIVING;
                            
                        end if;

                    when RECEIVING =>
                        -- filling the rest of the triggered data frame
                        fullFrame(nBitsToBeReceived - 1) <= triggered_data_from_fe_i;
                        nBitsToBeReceived <= nBitsToBeReceived - 1;
                        
                        -- when all the frame has been received
                        if (nBitsToBeReceived - 1 = 0) then
                            -- go to the output state
                            state <= OUTPUT;
                        end if;

                    when OUTPUT =>

                        -- build the output frame
                        triggered_data_frame_o.start <= fullFrame(275 downto 274);
                        triggered_data_frame_o.latency_error <= fullFrame(273);
                        triggered_data_frame_o.buffer_overflow <= fullFrame(272);
                        triggered_data_frame_o.pipe_address <= fullFrame(271 downto 263);
                        triggered_data_frame_o.l1_counter <= fullFrame(262 downto 254);
                        triggered_data_frame_o.channels <= fullFrame(253 downto 0);
                        
                        -- reset counter and state
                        nBitsToBeReceived <= 276;
                        state <= IDLE;

                end case;

            end if;

        end if;

    end process;

end FSM;

architecture FSM_WithTrailingZeros of triggered_data_readout is

    signal fullFrame: std_logic_vector(303 downto 0) := (others => '0'); -- including the 28 trailing zeros
    signal syncLine: std_logic_vector(303 downto 0) := (others => '0');


begin


    -- triggered data line
    process(clk320)

    begin
        if (rising_edge(clk320)) then

            if (reset_i = '1') then
                fullFrame <= (others =>'0');
                triggered_data_frame_o.start <= "00";

            else
                if (fullFrame(303 downto 302) = "11" and fullFrame(27 downto 0) = x"0000000" and syncLine(303) = '1') then
                    triggered_data_frame_o.start <= fullFrame(303 downto 302);
                    triggered_data_frame_o.latency_error <= fullFrame(301);
                    triggered_data_frame_o.buffer_overflow <= fullFrame(300);
                    triggered_data_frame_o.pipe_address <= fullFrame(299 downto 291);
                    triggered_data_frame_o.l1_counter <= fullFrame(290 downto 282);
                    triggered_data_frame_o.channels <= fullFrame(281 downto 28);
                    fullFrame(303 downto 1) <= (others => '0');
                    fullFrame(0) <= triggered_data_from_fe_i;
                else
                    triggered_data_frame_o.start <= "00";
                    fullFrame <= fullFrame(302 downto 0) & triggered_data_from_fe_i;
                end if;

            end if;

        end if;

    end process;

    -- look for the sync bit on the 5th serial line
    process(clk320)
    begin
        if (rising_edge(clk320)) then
            if (reset_i = '1') then
                syncLine <= (others => '0');
            else
                syncLine <= syncLine(302 downto 0) & sync_from_CBC_i;
            end if;
        end if;
    end process;

end FSM_WithTrailingZeros;
