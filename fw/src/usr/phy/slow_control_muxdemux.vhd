----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/22/2016 03:23:38 PM
-- Design Name: 
-- Module Name: slow_control_muxdemux - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.ipbus.ALL;

entity slow_control_muxdemux is
    generic (
        NHYBRID : integer := 32
    );
    port (
        clk: in std_logic;
        reset_i: std_logic;
        ipb_request_i: in ipb_wbus;
        ipb_request_o: out ipb_wbus_array(1 to NHYBRID);
        ipb_reply_i: in ipb_rbus_array(1 to NHYBRID);
        ipb_reply_o: out ipb_rbus
    );
end slow_control_muxdemux;

architecture Behavioral of slow_control_muxdemux is

    type state_t is (IDLE, ACK);
    signal state : state_t := IDLE;
    signal timeout: unsigned(31 downto 0) := (others => '0');
    constant SC_TIMEOUT         : integer := 200_000;
    constant SC_TIMEOUT_ERROR : std_logic_vector(31 downto 0) := x"EEEEEEEE";

begin


    process(clk)
        variable sel : integer range 0 to NHYBRID;
    begin
        if (rising_edge(clk)) then
            if (reset_i = '1') then

                -- reset all output requests, reply, counter, state and sel
                ipb_request_o <= (others => (ipb_addr => (others => '0'), ipb_wdata => (others => '0'), ipb_strobe => '0', ipb_write => '0'));
                ipb_reply_o <= (ipb_rdata => (others => '0'), ipb_ack => '0', ipb_err => '0');
                timeout <= (others => '0');
                state <= IDLE;
                sel := 0;

            else
                case state is

                    -- Wait for a strobe from command processor
                    when IDLE =>

                        -- reset all output requests
                        ipb_request_o <= (others => (ipb_addr => (others => '0'), ipb_wdata => (others => '0'), ipb_strobe => '0', ipb_write => '0'));

                        -- When strobe detected
                        if (ipb_request_i.ipb_strobe = '1') then

                            -- Set timeout
                            timeout <= to_unsigned(SC_TIMEOUT - 4, 32);

                            -- Get hybrid number from addr
                            sel := to_integer(unsigned(ipb_request_i.ipb_addr(31 downto 19)));

                            -- Forward request to selected bus
                            ipb_request_o(sel) <= ipb_request_i;

                            -- Go to ACK state
                            state <= ACK;

                        end if;

                    -- Wait for acknoledgment 
                    when ACK =>

                        -- reset output strobe
                        ipb_request_o(sel).ipb_strobe <= '0';

                        -- when timeout is reached
                        if (timeout = 0) then

                            -- send SC_TIMEOUT_ERROR with err bit high
                            ipb_reply_o <= (ipb_rdata => SC_TIMEOUT_ERROR, ipb_ack => '1', ipb_err => '1');

                            -- Go to IDLE state
                            state <= IDLE;

                        else

                            -- Decrement timeout
                            timeout <= timeout - 1;

                            -- When acknoledge received, forward the reply to command processor
                            if (ipb_reply_i(sel).ipb_ack = '1') then
                                ipb_reply_o <= ipb_reply_i(sel);

                                -- and go to IDLE state
                                state <= IDLE;

                            end if; -- end ack received condition

                        end if; -- end timeout = 0 condition

                end case; -- end case state

            end if; -- end reset condition

        end if; -- end rising_edge(clk) condition

    end process;

end Behavioral;
