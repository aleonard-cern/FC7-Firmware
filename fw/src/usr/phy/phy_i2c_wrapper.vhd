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
    cmd_reply: out cmd_rbus;
    
    scl : inout std_logic;
    sda : inout std_logic;

    sda_miso_to_master : in std_logic ;
    sda_mosi_to_slave : out std_logic ;
    master_sda_tri : out std_logic
     
);

end phy_i2c_wrapper;

architecture Behavioral of phy_i2c_wrapper is

    signal en: std_logic := '0';

    signal chip_address_req: std_logic_vector(6 downto 0) := "0000111";
    signal reg_address_req: std_logic_vector(7 downto 0) := "00000010";
    signal page_req: std_logic;
    signal data_req: std_logic_vector(7 downto 0) := x"CD";
    signal rw_req: std_logic := '0';
    signal mask_req: std_logic_vector(7downto 0) := x"FF";

    signal chip_address: std_logic_vector(6 downto 0) := "0000111";
    signal reg_address: std_logic_vector(7 downto 0) := "00000010";
    signal data: std_logic_vector(7 downto 0) := x"CD";
    signal rw: std_logic := '0';

    signal valid_o: std_logic := '0';
    signal error_o: std_logic := '0';
    signal data_o: std_logic_vector(7 downto 0) := (others => '0');

    signal cmd_rbus_tmp: cmd_rbus := (cmd_strobe => '0', cmd_data => (others => '0'), cmd_err => '0');

    signal page: std_logic;
    
    signal reg_val: std_logic_vector(7 downto 0) := x"00";

    type state_t is (IDLE, READ_CURRENT_PAGE, WAIT_CURRENT_PAGE, WRITE_PAGE, WAIT_FOR_GOOD_PAGE, READ_REG_VALUE, WAIT_CURRENT_REG, GOOD_TO_GO, WAIT_FOR_DONE, ERROR, SUCCESS);
    signal state : state_t := IDLE;
begin

    cmd_reply <= cmd_rbus_tmp;
    process(clk, reset)
        variable reg0 : std_logic_vector(7 downto 0) := (others => '0');

    begin
        if (reset = '1') then
        
            cmd_rbus_tmp.cmd_strobe <= '0';
            cmd_rbus_tmp.cmd_data <= x"00";
            cmd_rbus_tmp.cmd_err <= '0';
            
            chip_address_req <= (others => '0'); -- need a mapping between CBC id and CBC chip address
            rw_req <= '0';
            page_req <= '0';
            reg_address_req <= (others => '0');
            data_req <= (others => '0');

            state <= IDLE;
            
        elsif (rising_edge(clk)) then

            case state is
                when IDLE =>
                    cmd_rbus_tmp.cmd_strobe <= '0';
                    cmd_rbus_tmp.cmd_data <= x"00";
                    cmd_rbus_tmp.cmd_err <= '0'; 
                    if (cmd_request.cmd_strobe = '1') then

                        -- save request parameters
                        chip_address_req <= "111" & cmd_request.cmd_chip_id; -- need a mapping between CBC id and CBC chip address
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
                        if (reg0(7) = page_req) then -- page is already the good one
                            if (mask_req = x"FF") then -- if the complete mask, no need to read the register first
                                reg_val <= x"00";
                                state <= GOOD_TO_GO;
                            else -- need to read current value of the register to not overwrite
                                state <= READ_REG_VALUE;
                            end if;
                        else -- need to set the proper page
                            state <= WRITE_PAGE;
                        end if;
                    elsif (error_o = '1') then
                        state <= ERROR; --need error handling
                    end if;

                when READ_REG_VALUE =>
                    en <= '1';
                    chip_address <= chip_address_req;
                    reg_address <= reg_address_req;
                    rw <= '1';
                    state <= WAIT_CURRENT_REG;

                when WAIT_CURRENT_REG =>
                    en <= '0';
                    if (valid_o = '1') then
                        reg_val <= data_o;
                        state <= GOOD_TO_GO;
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
                        state <= GOOD_TO_GO;
                    elsif (error_o = '1') then
                        state <= ERROR; --need error handling
                    end if;

               when GOOD_TO_GO => -- now really writing
                    en <= '1';
                    chip_address <= chip_address_req;
                    reg_address <= reg_address_req;
                    rw <= rw_req;
                    data <= (data_req and mask_req) or reg_val;
                    state <= WAIT_FOR_DONE;

                when WAIT_FOR_DONE =>
                    en <= '0';
                    if (valid_o = '1') then
                        --data <= data_o;
                        state <= SUCCESS;
                        cmd_rbus_tmp.cmd_strobe <= '1';
                        cmd_rbus_tmp.cmd_data <= data_o;
                        cmd_rbus_tmp.cmd_err <= '0';
                    elsif (error_o = '1') then
                        state <= ERROR;
                        cmd_rbus_tmp.cmd_strobe <= '1';
                        cmd_rbus_tmp.cmd_data <= x"EE";
                        cmd_rbus_tmp.cmd_err <= '1';
                    end if;

                when ERROR =>
              
                    state <= IDLE;
                
                when SUCCESS =>
 
                    state <= IDLE;


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

--    sda_master_iobuf : iobuf
--    port map (
--        o           => sda_miso_to_master,
--        io          => sda,
--        i           => sda_mosi_to_slave,
--        t           => master_sda_tri
--    );

end Behavioral;
                
