----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/08/2016 01:00:19 PM
-- Design Name: 
-- Module Name: phy_core - rtl
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

entity phy_core is
    generic(
        constant NUM_HYBRID       : natural range 1 to 32
    );
    port (
    
        clk_40              : in std_logic;
        clk_320_i           : in std_logic;
        clk_320_o           : out std_logic;
        reset_i             : in std_logic;
    
        -- fast command input bus
        cmd_fast_i          : in cmd_fastbus;
        
        -- fast command serial output
        cmd_fast_o          : out std_logic;
    
        -- hybrid block interface for triggered data
        trig_data_o         : out trig_data_to_hb_t_array(1 to NUM_HYBRID);
    
        -- hybrid block interface for stub data
        stub_data_o         : out stub_data_to_hb_t_array(1 to NUM_HYBRID);
        
        -- triggered data lines from CBC
        trig_data_i         : in trig_data_from_fe_t_array(1 to NUM_HYBRID);
    
        -- stubs lines from CBC
        stub_data_i         : in stub_lines_r_array_array(1 to NUM_HYBRID);
        
        -- slow control command from command generator
        cmd_request_i       : in cmd_wbus;
        
        -- slow control response to command generator
        cmd_reply_o         : out cmd_rbus;
        
        scl_io              : inout std_logic;
        sda_io              : inout std_logic
        --i2c_mosi            : out std_logic;
        --i2c_miso            : in std_logic
        
    );
end phy_core;

architecture rtl of phy_core is

    signal dummy_signal             : std_logic := '0';
    signal cmd_request              : cmd_wbus_array(1 to NUM_HYBRID);
    signal cmd_reply                : cmd_rbus_array(1 to NUM_HYBRID);
    signal scl                      : std_logic := '1';
    signal sda                      : std_logic := '1';

    signal sda_mosi : std_logic := '1';
    signal sda_miso : std_logic := '1';
    signal sda_tri : std_logic := '1';
    signal cbc_dp_to_buf : cbc_dp_to_buf_array(1 to 1) := (others => (others => '0'));
    signal fast_cmd : std_logic;
    
begin

    clk_320_o <= clk_320_i;
    dummy_signal <= '1';
    
    --== fast command block ==--
    fast_cmd_inst: entity work.fast_cmd_block
    port map (
        clk40 => clk_40,
        clk320 => clk_320_i,
        reset_i => reset_i,
        fast_cmd_i => cmd_fast_i,
        fast_cmd_o => fast_cmd
    );

    --== slow control block ==--
    -- muxdemux to select which hybrid is concerned
    slow_control_muxdemux_inst : entity work.slow_control_muxdemux
    generic map (
        NUM_HYBRID => NUM_HYBRID
    )
    port map (
        clk => clk_40,
        reset_i => '0',
        cmd_request_i => cmd_request_i,
        cmd_request_o => cmd_request,
        cmd_reply_i => cmd_reply,
        cmd_reply_o => cmd_reply_o
    );
    
    -- i2c master cores for the NHYBRIDS
    --gen_i2c: for index in 1 to NUM_HYBRID generate
        phy_i2c_wrapper_inst : entity work.phy_i2c_wrapper
        port map (
            clk => clk_40,
            reset => reset_i,
            cmd_request => cmd_request(1),
            cmd_reply => cmd_reply(1),
            
            scl => scl,
            sda => sda,
        
            sda_miso_to_master => sda_miso,
            sda_mosi_to_slave => sda_mosi,
            master_sda_tri => sda_tri
        );
    --end generate gen_i2c;
    
    
    --== triggered data readout block ==--
    --gen_trig_data_readout : for index in 1 to NUM_HYBRID generate
        trigger_data_readout_wrapper_inst : entity work.trigger_data_readout_wrapper
        port map (
            clk320 => clk_320_i,
            clk40 => clk_40,
            reset_i => reset_i,
            triggered_data_from_fe_i => trig_data_i(1),
            sync_from_CBC_i => stub_data_i(1),
            trig_data_to_hb_o => trig_data_o(1)
        );
    --end generate gen_trig_data_readout; 
    
    
    --== stub lines block ==--
    --gen_stub_data_readout : for index in 1 to NUM_HYBRID generate
       stub_data_readout_inst : entity work.stub_data_all_CBCs
        port map (
            clk320 => clk_320_i,
            reset_i => reset_i,       
            stub_lines_i =>  stub_data_i(1),
            cbc_data_to_hb_o => stub_data_o(1)
        );
    --end generate gen_stub_data_readout;
    
    -- buffers
    buffers_inst : entity work.buffers
      generic map (
        NCBC_PER_HYBRID => NCBC_PER_HYBRID
      )
      Port map (       
        CBC_dp_p_i => cbc_dp_to_buf,
        CBC_dp_n_i => cbc_dp_to_buf,
        
        CBC_dp_o => open,
        
        clk320_p_o  => open,
        clk320_n_o  => open,
        clk320_i    => '0',
        
        fast_cmd_p_o     => cmd_fast_o,
        fast_cmd_n_o     => open,
        fast_cmd_i       => fast_cmd,   
    
        reset_o          => open,
        reset_i          => '0',
        
        SCL_i  => scl,   
        --SCL_o            : out std_logic; only the master drives the scl clock right now
        SCL_io => scl_io,
           
        SDA_io => sda_io,
        SDA_mosi_i => sda_mosi,
        SDA_miso_o => sda_miso,
        SDA_tri_i => sda_tri

        
      );
    
    
end rtl;
