----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/13/2016 04:40:07 PM
-- Design Name: 
-- Module Name: buffer_fifo - Behavioral
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

entity buffer_fifo is
    Generic (
        constant DATA_WIDTH : positive := 276;
        constant FIFO_DEPTH : positive := 32
    );
    Port (
        clk_40 : in std_logic;
        clk_320 : in std_logic;
        reset_i : in std_logic;
        synch_bit_i : in std_logic;
        data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
        trigger_in : in std_logic;
        data_bit_out : out std_logic
    );
end buffer_fifo;

architecture Behavioral of buffer_fifo is

    type state_t is (IDLE, WAIT_FOR_SYNCH, ALMOST_SYNCH, TRANSMITTING);
    signal state: state_t := IDLE;
    
    signal is_empty_fifo : std_logic := '1';
    signal is_full_fifo : std_logic := '0';
    signal is_valid : std_logic := '0';
    signal is_full_32 : std_logic := '0';
    signal wr_en : std_logic := '0';
    signal rd_en : std_logic := '0';
    signal data_out : std_logic_vector (DATA_WIDTH-1 downto 0);    
    signal transmition_in_progress : std_logic := '0';
    signal index : natural range 1 to DATA_WIDTH := 1;
    signal reset_dummy : std_logic := '1';
    signal reset_count : natural range 0 to 20 := 0;


begin

    -- fifo instance
    fifo_buffer: entity work.fifo_cbc3
    PORT MAP(
        clk => clk_40,
        rst => reset_dummy,
        din => data_in,
        wr_en => wr_en,
        rd_en => rd_en,
        dout => data_out,
        full => is_full_fifo,
        empty => is_empty_fifo,
        valid => is_valid,
        prog_full => is_full_32
    );


    -- write triggered data to fifo on L1 trigger event
    fifo_write: process(clk_40)
    begin
        if rising_edge(clk_40) then
            
            if (reset_count > 6) then
                reset_dummy <= '0';
            else 
                reset_count <= reset_count + 1;
            end if;
        
            if (reset_i = '1' or reset_dummy = '1') then
                wr_en <= '0';
            else
                if (trigger_in = '1') then
                    wr_en <= '1';
                else
                    wr_en <= '0';
                end if;
            end if;
            
        end if;
    end process;
    
    fifo_read: process(clk_40)
    begin
        if rising_edge(clk_40) then
            if (reset_i = '1'  or reset_dummy = '1') then
                rd_en <= '0';
            else 
                if (is_empty_fifo = '0' and transmition_in_progress = '0') then
                    rd_en <= '1';
                else 
                    rd_en <= '0';
                end if;
            end if;
        
        end if;
    end process;
    
    data_send: process(clk_320)
    begin
        if rising_edge(clk_320) then
        
            case state is
                when IDLE =>
                    if (rd_en = '1') then
                        transmition_in_progress <= '1';
                        state <= WAIT_FOR_SYNCH;
        
                    else
                        data_bit_out <= '0';
                        state <= IDLE;
                    end if;
        
                when WAIT_FOR_SYNCH =>    
                    if (synch_bit_i = '1') then
                        state <= TRANSMITTING;
                        data_bit_out <= data_out(0);
                    else
                        data_bit_out <= '0';
                    end if;
            
            
                when TRANSMITTING =>
                    if (index /= DATA_WIDTH) then
        
                        data_bit_out <= data_out(index);
                        index <= index + 1;

                    else
                    
                        state <= IDLE;
                        index <= 1;
                        data_bit_out <= '0';
                        transmition_in_progress <= '0';

                    end if;
                    
                when others =>
                    state <= IDLE;
                    index <= 1;
                    data_bit_out <= '0';
                    transmition_in_progress <= '0';

            end case;            
        end if;
    end process;

end Behavioral;
