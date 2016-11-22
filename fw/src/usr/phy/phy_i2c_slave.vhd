----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/22/2016 04:00:25 PM
-- Design Name: 
-- Module Name: phy_i2c_slave - Behavioral
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

entity phy_i2c_slave is
generic (
    CHIP_ADDR : std_logic_vector(6 downto 0) := (others => '1')
);
port(

    ref_clk_i   : in std_logic;
    reset_i     : in std_logic;

    -- I2C lines
    scl_i       : in std_logic;
    sda_miso_o  : out std_logic;
    sda_mosi_i  : in std_logic;
    sda_tri_o   : out std_logic
    --sda_o: out std_logic;
    --sda_i: in std_logic

);
end phy_i2c_slave;

architecture Behavioral of phy_i2c_slave is

    signal chip_address_requested :std_logic_vector(6 downto 0) := (others => '0');
    signal reg_address_requested: std_logic_vector(7 downto 0) := (others => '0');
    signal rw_requested: std_logic := '0';

    signal chip_address_cnt: integer := 6;
    signal reg_address_cnt: integer := 7;
    signal data_cnt: integer := 7;

    type state_t is (IDLE, START, CHECK_CHIP_ADDR, REST_1, REST_4, RW_BIT, SEND_ACK, GET_REG_ADDR, FETCH_REG_DATA_AND_ACK, REST_2, READ_DATA_OR_STOP, ADJUST_DATA, WRITE_DATA_AND_ACK, REST_3, SEND_DATA, WAIT_MASTER_ACK);
    signal state: state_t := IDLE;

    type array_t is array (0 to 32) of std_logic_vector(7 downto 0);
    signal regs : array_t := (others => (others => '0'));
    signal data : std_logic_vector(7 downto 0) := (others => '0');
    signal data_tmp : std_logic_vector(7 downto 0) := (others => '0');

begin

    process(ref_clk_i)
        variable previous_sda: std_logic := '1';
        variable current_sda: std_logic := '1';
        variable previous_scl: std_logic := '1';
        variable current_scl: std_logic := '1';
    begin
        -- start condition
        if (rising_edge(ref_clk_i)) then
            previous_sda := current_sda;
            current_sda := sda_mosi_i;
            --current_sda := sda_i;
            previous_scl := current_scl;
            current_scl := scl_i;

            -- Reset & default values
            if (reset_i = '1') then
                -- master controls the bus
                sda_miso_o <= '1';
                sda_tri_o <= '1';
                --sda_o <= '1';

                state <= IDLE;
                chip_address_requested <= (others => '0');
                rw_requested <= '0';
                reg_address_requested <= (others => '0');
            else
                case state is
                    when IDLE =>
                        -- master controls the bus
                        sda_miso_o <= '1';
                        sda_tri_o <= '1';
                        --sda_o <= '1';
                        if (current_sda = '0' and previous_sda = '1' and scl_i = '1') then
                            chip_address_cnt <= 6;
                            state <= START;
                        end if;

                    when START =>
                        -- master controls the bus
                        sda_miso_o <= '1';
                        sda_tri_o <= '1';
                        --sda_o <= '1';
                        if (previous_scl = '0' and current_scl = '1') then
                            chip_address_requested(chip_address_cnt) <= sda_mosi_i;
                            --chip_address_requested(chip_address_cnt) <= sda_i;

                            if (chip_address_cnt = 0) then
                                state <= CHECK_CHIP_ADDR;
                            else
                                chip_address_cnt <= chip_address_cnt - 1;
                            end if;

                        end if;

                    when CHECK_CHIP_ADDR =>
                        -- master controls the bus
                        sda_miso_o <= '1';
                        sda_tri_o <= '1';
                        --sda_o <= '1';
                        if (chip_address_requested = CHIP_ADDR) then
                            state <= RW_BIT;
                        else
                            state <= IDLE;
                        end if;

                    when RW_BIT =>
                        -- master controls the bus
                        sda_miso_o <= '1';
                        sda_tri_o <= '1';
                        --sda_o <= '1';
                        if (previous_scl = '0' and current_scl = '1') then
                            rw_requested <= sda_mosi_i;
                            --rw_requested <= sda_i;
                            state <= SEND_ACK;
                        end if;

                    when SEND_ACK =>
                        -- slave controls the bus
                        if (previous_scl = '1' and current_scl = '0') then --test
                            sda_tri_o <= '0';
                            sda_miso_o <= '0';
                            --sda_o <= '0';
                            state <= REST_1;

                        end if;

                    when REST_1 =>
                        if (previous_scl = '1' and current_scl = '0') then
                            sda_miso_o <= '1';
                            sda_tri_o <= '1'; -- test
                            --sda_o <= '1';
                            reg_address_cnt <= 7;
                            data_cnt <= 7;
                            case rw_requested is
                                when '0' => state <= GET_REG_ADDR;
                                when others => state <= SEND_DATA;
                            end case;

                        end if;


                    when GET_REG_ADDR =>
                            -- master controls the bus
                            sda_miso_o <= '1';
                            sda_tri_o <= '1';
                            --sda_o <= '1';
                            if (previous_scl = '0' and current_scl = '1') then
                                reg_address_requested(reg_address_cnt) <= sda_mosi_i;
                                --reg_address_requested(reg_address_cnt) <= sda_i;
                                if (reg_address_cnt = 0) then
                                    state <= FETCH_REG_DATA_AND_ACK;
                                else
                                    reg_address_cnt <= reg_address_cnt - 1;
                                end if;
                            end if;


                    when FETCH_REG_DATA_AND_ACK =>
                        data <= regs(to_integer(unsigned(reg_address_requested)));
                        data_cnt <= 7;
                        -- slave controls the bus
                        if (previous_scl = '1' and current_scl = '0') then
                            sda_tri_o <= '0';
                            sda_miso_o <= '0';
                            --sda_o <= '0';
                            state <= REST_2;
                        end if;

                     when REST_2 =>
                        if (previous_scl = '1' and current_scl = '0') then
                            sda_tri_o <= '0';
                            sda_miso_o <= '1';
                            --sda_o <= '1';
                            data_cnt <= 7;
                            state <= READ_DATA_OR_STOP;
                        end if;

                    when READ_DATA_OR_STOP =>
                        -- master controls the bus
                        sda_miso_o <= '1';
                        sda_tri_o <= '1';
                        --sda_o <= '1';
                        if (current_sda = '1' and previous_sda = '0' and scl_i = '1') then --stop signal
                            state <= IDLE;
                        elsif (previous_scl = '0' and current_scl = '1') then
                            data_tmp(data_cnt) <= sda_mosi_i;
                            --data_tmp(data_cnt) <= sda_i;
                            if (data_cnt = 0) then
                                state <= ADJUST_DATA;
                            else
                                data_cnt <= data_cnt - 1;
                            end if;
                        end if;
                    when ADJUST_DATA =>
                        data <= data_tmp;
                        state <= WRITE_DATA_AND_ACK;


                    when WRITE_DATA_AND_ACK =>
                        regs(to_integer(unsigned(reg_address_requested))) <= data;
                        -- slave controls the bus
                        if (previous_scl = '1' and current_scl = '0') then
                            sda_tri_o <= '0';
                            sda_miso_o <= '0';
                            --sda_o <= '0';
                            data_cnt <= 7;
                            state <= REST_3;
                        end if;

                   when REST_3 =>
                       if (previous_scl = '1' and current_scl = '0') then
                           sda_tri_o <= '0';
                           sda_miso_o <= '1';
                           --sda_o <= '1';
                           data_cnt <= 7;
                           state <= IDLE;
                       end if;

                    when SEND_DATA  =>
                        sda_tri_o <= '0';
                        -- slave controls the bus
                        if (previous_scl = '0' and current_scl = '1') then
                            sda_miso_o <= data(data_cnt);
                            sda_tri_o <= '0';
                            --sda_o <= data(data_cnt);
                            if (data_cnt = 0) then
                                state <= REST_4;
                            -- or decrement counter
                            else
                                data_cnt <= data_cnt - 1;
                            end if;
                        end if;

                    when REST_4 =>
                        if (previous_scl = '1' and current_scl = '0') then
                            sda_tri_o <= '1';
                            sda_miso_o <= '1';
                            state <= WAIT_MASTER_ACK;
                        end if;


                    when WAIT_MASTER_ACK =>
                         -- master controls the bus
                         sda_miso_o <= '1';
                         sda_tri_o <= '1';
                         --sda_o <= '1';
                        if (previous_scl = '0' and current_scl = '1') then
                             if (sda_mosi_i = '0') then
                             --if (sda_i = '0') then
                                state <= IDLE;
                             else
                                 state <= IDLE; -- should do something with error here
                             end if;
                         end if;

                end case;

            end if;

        end if;


    end process;


end Behavioral;
                    
