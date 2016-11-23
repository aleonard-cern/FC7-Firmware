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

entity triggered_data_readout is
    port (
        clk: in std_logic; -- 320 MHz
        reset_i: in std_logic;
        trigger_accept_i: in std_logic;
        trigger_accept_o: out std_logic;
        triggered_data_from_CBC_i: in std_logic;
        sync_from_CBC_i: in std_logic
    );
end triggered_data_readout;


architecture FSM of triggered_data_readout is

    type state_t is (IDLE, CHECK_START, RECEIVING, OUTPUT);
    signal state : state_t := IDLE;
    signal fullFrame: std_logic_vector(275 downto 0) := (others => '0');
    signal start : std_logic_vector(1 downto 0) := "00";
    signal latency_error : std_logic := '0';
    signal buffer_overflow: std_logic := '0';
    signal pipe_address : std_logic_vector(8 downto 0) := (others => '0');
    signal l1_counter: std_logic_vector(8 downto 0) := (others => '0');
    signal channels: std_logic_vector(253 downto 0) := (others => '0');

    signal nBitsToBeReceived: integer := 276;

begin

    trigger_accept_o <= trigger_accept_i;



    -- triggered data line
    process(clk)

    begin
        if (rising_edge(clk)) then

            if (reset_i = '1') then
                fullFrame <= (others =>'0');
                nBitsToBeReceived <= 276;
                state <= IDLE;
            else
                case state is

                    when IDLE =>
                        -- reset the start bits
                        if (sync_from_CBC_i = '1' and triggered_data_from_CBC_i = '1') then
                            fullFrame(nBitsToBeReceived - 1) <= triggered_data_from_CBC_i;
                            nBitsToBeReceived <= 275;
                            state <= CHECK_START;
                        end if;

                    when CHECK_START =>
                        if (nBitsToBeReceived = 275 and triggered_data_from_CBC_i /= '1') then
                            nBitsToBeReceived <= 276;
                            state <= IDLE;
                        else
                            fullFrame(nBitsToBeReceived - 1) <= triggered_data_from_CBC_i;
                            nBitsToBeReceived <= nBitsToBeReceived - 1;
                            state <= RECEIVING;
                        end if;

                    when RECEIVING =>
                        fullFrame(nBitsToBeReceived - 1) <= triggered_data_from_CBC_i;
                        nBitsToBeReceived <= nBitsToBeReceived - 1;
                        if (nBitsToBeReceived - 1 = 0) then
                            state <= OUTPUT;
                        end if;

                    when OUTPUT =>
                        -- really output things
                        start <= fullFrame(275 downto 274);
                        latency_error <= fullFrame(273);
                        buffer_overflow <= fullFrame(272);
                        pipe_address <= fullFrame(271 downto 263);
                        l1_counter <= fullFrame(262 downto 254);
                        channels <= fullFrame(253 downto 0);
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
    signal start : std_logic_vector(1 downto 0) := "00";
    signal latency_error : std_logic := '0';
    signal buffer_overflow: std_logic := '0';
    signal pipe_address : std_logic_vector(8 downto 0) := (others => '0');
    signal l1_counter: std_logic_vector(8 downto 0) := (others => '0');
    signal channels: std_logic_vector(253 downto 0) := (others => '0');


begin

    trigger_accept_o <= trigger_accept_i;

    -- triggered data line
    process(clk)

    begin
        if (rising_edge(clk)) then

            if (reset_i = '1') then
                fullFrame <= (others =>'0');
            else
                if (fullFrame(303 downto 302) = "11" and fullFrame(27 downto 0) = x"0000000" and syncLine(303) = '1') then
                    start <= fullFrame(303 downto 302);
                    latency_error <= fullFrame(301);
                    buffer_overflow <= fullFrame(300);
                    pipe_address <= fullFrame(299 downto 291);
                    l1_counter <= fullFrame(290 downto 282);
                    channels <= fullFrame(281 downto 28);
                    fullFrame(303 downto 1) <= (others => '0');
                    fullFrame(0) <= triggered_data_from_CBC_i;
                else
                    fullFrame <= fullFrame(302 downto 0) & triggered_data_from_CBC_i;
                end if;

            end if;

        end if;

    end process;

    -- look for the sync bit on the 5th serial line
    process(clk)
    begin
        if (rising_edge(clk)) then
            if (reset_i = '1') then
                syncLine <= (others => '0');
            else
                syncLine <= syncLine(302 downto 0) & sync_from_CBC_i;
            end if;
        end if;
    end process;

end FSM_WithTrailingZeros;
