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

    constant clk40MHz_period : time := 25 ns;
    
    signal reset_i     : std_logic := '0';
    signal reset     : std_logic := '0';

    signal clk_40MHz   : std_logic := '0';
    signal mmcm_ready  : std_logic := '0';
    signal clk_320MHz  : std_logic := '0';
    signal clk320_fromPhyToCBC3 : std_logic := '0';
    signal clk40 : std_logic := '0';
    
    signal fast_command_to_phy : cmd_fastbus := (fast_reset => '0', trigger => '0', test_pulse_trigger => '0', orbit_reset => '0' );
    signal cmd_fast : std_logic;
       
    signal slow_control_req_i : cmd_wbus := (cmd_strobe => '0', cmd_hybrid_id => (others => '0'), cmd_chip_id => (others => '0'), cmd_page => '0', cmd_read => '0', cmd_register => (others => '0'), cmd_data => (others => '0'), cmd_write_mask => (others => '0'));
    signal slow_control_rep_o : cmd_rbus := (cmd_strobe => '0', cmd_data => (others => '0'), cmd_err => '0');
    
    signal trigger_data_fromCBC : trig_data_from_fe_t_array(0 to NUM_HYBRIDS-1);
    signal stub_data_fromCBC : stub_lines_r_array_array(0 to NUM_HYBRIDS-1);
    
    -- I2C lines
    signal sda_miso : std_logic_vector(0 to NUM_HYBRIDS-1);
    signal sda_mosi : std_logic_vector(0 to NUM_HYBRIDS-1);
    signal scl_mosi : std_logic_vector(0 to NUM_HYBRIDS-1);
    
begin


     mmcm_inst : entity work.mmcm
     port map ( 
     
        -- Clock in ports
        clk_in1 => clk40,
       -- Clock out ports  
        clk_out40 => clk_40MHz,
        clk_out320 => clk_320MHz,
       -- Status and control signals                
        reset => '0',
        locked => mmcm_ready            
     );
      
      CBC3_emulator : entity work.CBC3_generator
      port map(

         reset_i => reset_i,
  
         clk320_i => clk320_fromPhyToCBC3,
         cmd_fast_i => cmd_fast,
         trig_data_o => trigger_data_fromCBC,
         stub_data_o => stub_data_fromCBC,
         sda_miso_o_top => sda_miso,
         sda_mosi_i_top => sda_mosi,
         scl_i => scl_mosi,
         clk40_test_i => clk_40MHz,
         mmcm_ready_i => mmcm_ready
  
    );
 
      
     phy_block: entity work.phy_core
     --===================================--
     generic map
     (
         NUM_HYBRIDS => NUM_HYBRIDS
     )
     port map
     (
         clk_40              => clk_40MHz, --mmcm
         clk_320_i           => clk_320MHz, --mmcm
         clk_320_o           => clk320_fromPhyToCBC3,
         reset_i             => reset_i,
 
         -- fast command input bus
         cmd_fast_i          => fast_command_to_phy, 
     
         -- fast command serial output
         cmd_fast_o          => cmd_fast, 
 
         -- hybrid block interface for triggered data
         trig_data_o         => open,
 
         -- hybrid block interface for stub data
         stub_data_o         => open,
     
         -- triggered data lines from CBC
         trig_data_i         => trigger_data_fromCBC,
 
         -- stubs lines from CBC
         stub_data_i         => stub_data_fromCBC,
     
         -- slow control command from command generator
         cmd_request_i       => slow_control_req_i,
     
         -- slow control response to command generator
         cmd_reply_o         => open,
         
         sda_miso_i => sda_miso,
         sda_mosi_o => sda_mosi,
         scl_o => scl_mosi,
         mmcm_ready_i => mmcm_ready
 
         
 --        scl_io => scl_io,
 --        sda_io => sda_io
     );  
     
    clk40MHz_prc: process
     begin
         clk40 <= '1';
         wait for clk40MHz_period/2;
         clk40 <= '0';
         wait for clk40MHz_period/2;
      end process; 
     
     gen_fast_cmd : process
     begin
        
         --reset_i <= '1';
         --wait for 2*clk40MHz_period;
         --reset_i <= '0';
         --wait until (mmcm_ready = '1');
         wait for 20*clk40MHz_period;
         fast_command_to_phy <= (fast_reset => '0', trigger => '1', test_pulse_trigger => '0', orbit_reset => '0' );
         wait for clk40MHz_period;
         fast_command_to_phy <= (fast_reset => '0', trigger => '0', test_pulse_trigger => '0', orbit_reset => '0' );
         
         wait for 2*clk40MHz_period;
         fast_command_to_phy <= (fast_reset => '0', trigger => '1', test_pulse_trigger => '0', orbit_reset => '0' );
         wait for clk40MHz_period;
         fast_command_to_phy <= (fast_reset => '0', trigger => '0', test_pulse_trigger => '0', orbit_reset => '0' );
   

         --wait;
         
     end process;

    slow_cmd : process
    begin
         wait until (mmcm_ready = '1');
         wait for 10*clk40MHz_period;
         slow_control_req_i <= (cmd_strobe => '1', cmd_hybrid_id => (others => '0'), cmd_chip_id => x"F", cmd_page => '1', cmd_read => '1', cmd_register => x"00", cmd_data => (others => '1'), cmd_write_mask => (others => '1'));
         wait for clk40MHz_period;
         slow_control_req_i <= (cmd_strobe => '0', cmd_hybrid_id => (others => '0'), cmd_chip_id => (others => '0'), cmd_page => '0', cmd_read => '0', cmd_register => x"00", cmd_data => (others => '0'), cmd_write_mask => (others => '0'));
         wait;
    end process;



    reset_proc : process
    begin
        wait until (mmcm_ready = '1');
        wait for 16.25*clk40MHz_period;
        --reset_i <= '1';
        
        wait for 1.0*clk40MHz_period;
        --reset_i <= '0';
        wait;
        
    end process;
    
    
end Behavioral;
