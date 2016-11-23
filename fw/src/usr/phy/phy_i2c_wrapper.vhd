----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/22/2016 04:15:38 PM
-- Design Name: 
-- Module Name: phy_i2c_wrapper - Behavioral
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
library UNISIM;
use UNISIM.VComponents.all;

use work.user_package.ALL;


entity phy_i2c_wrapper is
  port (
    clk: in std_logic;
    reset: in std_logic;

    cmd_request: in cmd_wbus;
    cmd_reply: out cmd_rbus

  );

end phy_i2c_wrapper;

architecture Behavioral of phy_i2c_wrapper is

    signal en: std_logic := '0';

    signal chip_address_req: std_logic_vector(6 downto 0) := "0000111";
    signal reg_address_req: std_logic_vector(7 downto 0) := "00000010";
    signal page_req: std_logic;
    signal data_req: std_logic_vector(7 downto 0) := x"CD";
    signal rw_req: std_logic := '0';

    signal chip_address: std_logic_vector(6 downto 0) := "0000111";
    signal reg_address: std_logic_vector(7 downto 0) := "00000010";
    signal data: std_logic_vector(7 downto 0) := x"CD";
    signal rw: std_logic := '0';

    signal valid_o: std_logic := '0';
    signal error_o: std_logic := '0';
    signal data_o: std_logic_vector(7 downto 0) := (others => '0');

    signal scl: std_logic;
    signal sda: std_logic;

    signal sda_miso_to_master: std_logic := '1';
    signal sda_mosi_to_slave: std_logic := '1';
    signal master_sda_tri: std_logic := '0';

    signal page: std_logic;

    type state_t is (IDLE, READ_CURRENT_PAGE, WAIT_CURRENT_PAGE, WRITE_PAGE, WAIT_FOR_GOOD_PAGE, GOOD_PAGE, WAIT_FOR_DONE, ERROR, SUCCESS);
    signal state : state_t := IDLE;
begin


    process(clk, reset)
        variable reg0 : std_logic_vector(7 downto 0) := (others => '0');

    begin
        if (reset = '1') then

        elsif (rising_edge(clk)) then

            case state is
                when IDLE =>
                    if (cmd_request.cmd_strobe = '1') then

                        -- save request parameters
                        chip_address_req <= cmd_request.cmd_cbc_id; -- need a mapping between CBC id and CBC chip address
                        rw_req <= cmd_request.cmd_read;
                        page_req <= cmd_request.cmd_page;
                        reg_address_req <= cmd_request.cmd_register;
                        data_req <= cmd_request.cmd_data;

                        state <= READ_CURRENT_PAGE;

                    end if;

                when READ_CURRENT_PAGE =>
                    en <= '1';
                    chip_address <= chip_address_req;
                    reg_address <= x"00";
                    rw <= '1';
                    state <= WAIT_CURRENT_PAGE;

                when WAIT_CURRENT_PAGE =>
                    en <= '0';
                    if (valid_o = '1') then
                        reg0 := data_o;
                        if (reg0(7) = page_req) then
                            state <= GOOD_PAGE;
                        else
                            state <= WRITE_PAGE;
                        end if;
                    elsif (error_o = '1') then
                        state <= ERROR; --need error handling
                    end if;

                when WRITE_PAGE =>
                    en <= '1';
                    chip_address <= chip_address_req;
                    reg_address <= x"00";
                    rw <= '0'; -- write
                    data <= page_req & reg0(6 downto 0);
                    state <= WAIT_FOR_GOOD_PAGE;

               when WAIT_FOR_GOOD_PAGE =>
                    en <= '0';
                    if (valid_o = '1') then
                        state <= GOOD_PAGE;
                    elsif (error_o = '1') then
                        state <= ERROR; --need error handling
                    end if;

               when GOOD_PAGE =>
                    en <= '1';
                    chip_address <= chip_address_req;
                    reg_address <= reg_address_req;
                    rw <= rw_req;
                    data <= data_req;
                    state <= WAIT_FOR_DONE;

                when WAIT_FOR_DONE =>
                    en <= '0';
                    if (valid_o = '1') then
                        data <= data_o;
                        state <= SUCCESS;
                    elsif (error_o = '1') then
                        state <= ERROR;
                    end if;

                when ERROR =>
                    

            end case;
        end if;
    end process;


    phy_i2c_master_inst : entity work.phy_i2c_master
    generic map (

        -- Input frequency clock
        IN_FREQ => 40_000_000,
        -- SCL frequency clock
        OUT_FREQ => 100_000

    )
    port map (
        ref_clk_i => clk,
        reset_i  => reset,

        -- Request
        en_i => en,
        chip_address_i => chip_address,
        reg_address_i => reg_address,
        rw_i => rw,
        data_i => data,

        -- Response
        valid_o => valid_o,
        error_o => error_o,
        data_o => data_o,

        -- I2C lines
        scl_o => scl,

        sda_miso_i => sda_miso_to_master,
        sda_mosi_o => sda_mosi_to_slave,
        sda_tri_o => master_sda_tri
    );

    sda_master_iobuf : iobuf
    port map (
        o           => sda_miso_to_master,
        io          => sda,
        i           => sda_mosi_to_slave,
        t           => master_sda_tri
    );

end Behavioral;
                
