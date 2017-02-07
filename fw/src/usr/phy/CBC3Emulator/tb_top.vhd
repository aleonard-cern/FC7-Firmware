----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/20/2016 11:53:54 AM
-- Design Name: 
-- Module Name: tb_i2cslave - Behavioral
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
use work.user_package.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.user_package.ALL;

entity tb_top is
--  Port ( );
end tb_top;

architecture Behavioral of tb_top is
    constant clk320MHz_period : time := 10 ns; --put to 10 ns for simplicity, in real life it is 3.125ns
    constant clk100kHz_period : time := 32 us; --if I put the 320MHz clock to a period of 10ns then this one should be 32us
    constant clk40MHz_period : time := 80 ns;
--    signal ref_clk_i    : std_logic := '0';
    signal reset_i     : std_logic := '0';
    signal reset     : std_logic := '0';
    -- I2C lines
    signal scl_i       : std_logic := '0';
    signal sda_miso_o  : std_logic := '0';
    signal sda_mosi_i  : std_logic := '1';
    signal sda_tri_o   : std_logic := '0';
    signal clk320 : std_logic :='0';
    signal clk320_fromPhyToCBC3 : std_logic := '0';
    signal clk40 : std_logic := '0';
    
    signal fast_command_to_phy : cmd_fastbus := (fast_reset => '0', trigger => '0', test_pulse_trigger => '0', orbit_reset => '0' );
    signal fast_cmd : std_logic;
    signal data_bit_o : trig_data_from_fe_t_array(1 to 1);
    
    signal stub_data_to_fc7 : stub_lines_r := (dp1 => '0', dp2 => '0', dp3 => '0', dp4 => '0', dp5 => '0');
    signal all_stub_data : stub_lines_r_array_array(1 to 1);
    
    signal stub_to_hb :  stub_data_to_hb_t_array(1 to 1);
    signal trig_data_to_hb: trig_data_to_hb_t_array(1 to 1);
     
    
   -- signal regs_page1_top : array_reg_page1 := regs_page1_default;
   -- signal regs_page2_top : array_reg_page2 := regs_page2_default;
   
    signal slow_control_req_i : cmd_wbus := (cmd_strobe => '0', cmd_hybrid_id => (others => '0'), cmd_chip_id => (others => '0'), cmd_page => '0', cmd_read => '0', cmd_register => (others => '0'), cmd_data => (others => '0'), cmd_write_mask => (others => '0'));
    signal slow_control_rep_o : cmd_rbus := (cmd_strobe => '0', cmd_data => (others => '0'), cmd_err => '0');
    
    signal scl : std_logic_vector(1 to 1) := '1';
    signal sda : std_logic := '1';

    
begin

    all_stub_data(1)(0) <= stub_data_to_fc7;

    uut_core : entity work.phy_core
    generic map
        (
            NUM_HYBRID => 1
        )
    port map
    (
        clk_40              => clk40,
        clk_320_o           => clk320_fromPhyToCBC3,
        clk_320_i           => clk320,
        reset_i             => reset_i,
        reset_o             => reset,
        -- fast command input bus
        cmd_fast_i          => fast_command_to_phy,
    
        -- fast command serial output
        cmd_fast_o          => fast_cmd,

        -- hybrid block interface for triggered data
        trig_data_o         => trig_data_to_hb,

        -- hybrid block interface for stub data
        stub_data_o         => stub_to_hb,
    
        -- triggered data lines from CBC
        trig_data_i         => data_bit_o,

        -- stubs lines from CBC
        stub_data_i         => all_stub_data,
    
        -- slow control command from command generator
        cmd_request_i       => slow_control_req_i,
    
        -- slow control response to command generator
        cmd_reply_o         => slow_control_rep_o,
        
        scl_io              => scl,
        sda_io              => sda
        --i2c_mosi            => mosi,
        --i2c_miso            => miso
    );    



    uut_top: entity work.CBC3_top
    port map(
        -- I2C lines
        scl_io_top => scl,
        sda_io => sda,
        reset_i => reset,
        clk320_top => clk320_fromPhyToCBC3,
        fast_cmd_top => fast_cmd,
        data_bit_out_top => data_bit_o(1)(0),
        stub_data_out => stub_data_to_fc7
        --regs_page1_top_o => regs_page1,
        --regs_page2_top_o => regs_page2
        --i2c_mosi            => mosi,
        --i2c_miso            => miso
    );
    
--    clk40MHz_prc: process
--    begin
--        ref_clk_i <= '1';
--        wait for 125 ns;
--        ref_clk_i <= '0';
--        wait for 125 ns;
--    end process;
    
    clk40MHz_prc: process
     begin
         clk40 <= '1';
         wait for clk40MHz_period/2;
         clk40 <= '0';
         wait for clk40MHz_period/2;
      end process; 
     
     clk320MHz_prc: process
     begin
         clk320 <= '1';
         wait for clk320MHz_period/2;
         clk320 <= '0';
         wait for clk320MHz_period/2;
      end process;
     
     gen_fast_cmd : process
     begin
          --fast_command_to_phy <= (fast_reset => not(fast_command_to_phy.fast_reset), trigger => '0', test_pulse_trigger => '0', orbit_reset => '0' );
--         fast_command_to_phy <= (fast_reset => '0', trigger => '0', test_pulse_trigger => '0', orbit_reset => '0' );
        
         wait for 10*clk40MHz_period;
         fast_command_to_phy <= (fast_reset => '0', trigger => '1', test_pulse_trigger => '0', orbit_reset => '0' );
         wait for clk40MHz_period;
         fast_command_to_phy <= (fast_reset => '0', trigger => '0', test_pulse_trigger => '0', orbit_reset => '0' );
         
         wait for 20*clk40MHz_period;
         fast_command_to_phy <= (fast_reset => '0', trigger => '1', test_pulse_trigger => '0', orbit_reset => '0' );
         wait for clk40MHz_period;
         fast_command_to_phy <= (fast_reset => '0', trigger => '0', test_pulse_trigger => '0', orbit_reset => '0' );
   

         wait;
         
     end process;

    slow_cmd : process
    begin
         wait for 10*clk40MHz_period;
         slow_control_req_i <= (cmd_strobe => '1', cmd_hybrid_id => (others => '0'), cmd_chip_id => x"F", cmd_page => '1', cmd_read => '1', cmd_register => x"05", cmd_data => (others => '1'), cmd_write_mask => (others => '1'));
         wait for clk40MHz_period;
         slow_control_req_i <= (cmd_strobe => '0', cmd_hybrid_id => (others => '0'), cmd_chip_id => (others => '0'), cmd_page => '0', cmd_read => '0', cmd_register => x"00", cmd_data => (others => '0'), cmd_write_mask => (others => '0'));
         wait;
    end process;

    reset_proc : process
    begin
        wait for 16.25*clk40MHz_period;
        reset_i <= '1';
        
        wait for 1.0*clk40MHz_period;
        reset_i <= '0';
        wait;
        
    end process;
    
    
end Behavioral;
