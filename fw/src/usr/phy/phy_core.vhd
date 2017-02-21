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
        constant NUM_HYBRIDS       : natural range 1 to 32
    );
    port (
    
        clk_40              : in std_logic;
        clk_320_i           : in std_logic;
        clk_320_o           : out std_logic;
        reset_i             : in std_logic;
        reset_o             : out std_logic;
    
        -- fast command input bus
        cmd_fast_i          : in cmd_fastbus;
        
        -- fast command serial output
        cmd_fast_o          : out std_logic;
    
        -- hybrid block interface for triggered data
       -- trig_data_o         : out trig_data_to_hb_t_array(0 to NUM_HYBRID-1);
        trig_data_o         : out triggered_data_frame_r_array(0 to NUM_HYBRIDS-1);

        -- hybrid block interface for stub data
        stub_data_o         : out stub_data_to_hb_t_array(0 to NUM_HYBRIDS-1);
        
        -- triggered data lines from CBC
        trig_data_i         : in trig_data_from_fe_t_array(0 to NUM_HYBRIDS-1);
    
        -- stubs lines from CBC
        stub_data_i         : in stub_lines_r_array_array(0 to NUM_HYBRIDS-1);
        
        -- slow control command from command generator
        cmd_request_i       : in cmd_wbus;
        
        -- slow control response to command generator
        cmd_reply_o         : out cmd_rbus;
        
--        scl_io              : inout std_logic_vector(0 to NUM_HYBRID-1);
--        sda_io              : inout std_logic_vector(0 to NUM_HYBRID-1)

        sda_miso_i : in std_logic_vector(0 to NUM_HYBRIDS-1);
        sda_mosi_o : out std_logic_vector(0 to NUM_HYBRIDS-1);
        scl_o :out std_logic_vector(0 to NUM_HYBRIDS-1);
        mmcm_ready_i : in std_logic

        
    );
end phy_core;

architecture rtl of phy_core is

    --signal dummy_signal             : std_logic := '0';
    signal cmd_request              : cmd_wbus_array(0 to NUM_HYBRIDS-1);
    signal cmd_reply                : cmd_rbus_array(0 to NUM_HYBRIDS-1);
    signal scl_mosi                 : std_logic_vector(0 to NUM_HYBRIDS-1) := (others => '1');

    signal sda_mosi : std_logic_vector(0 to NUM_HYBRIDS-1) := (others => '1');
    signal sda_miso : std_logic_vector(0 to NUM_HYBRIDS-1) := (others => '1');
    signal sda_tri : std_logic_vector(0 to NUM_HYBRIDS-1) := (others => '1');
    --signal cbc_dp_to_buf : cbc_dp_to_buf_array_array(0 to NUM_HYBRID-1)  := (others => (others => (others => '0')));
    signal cbc_dp_to_buf : cbc_dp_to_buf_array_array(0 to NUM_HYBRIDS-1);
    --signal fast_cmd : std_logic;
    
    attribute keep: boolean;
    attribute keep of clk_320_i: signal is true;  
    attribute keep of cmd_fast_o: signal is true;
    attribute keep of trig_data_o: signal is true;
begin

    clk_320_o <= clk_320_i;
    --dummy_signal <= '1';
    
    sda_mosi_o <= sda_mosi;
    sda_miso <= sda_miso_i;
    scl_o <= scl_mosi ;
    
    --== fast command block ==--
    fast_cmd_inst: entity work.fast_cmd_block
    port map (
        clk40 => clk_40,
        clk320 => clk_320_i,
        reset_i => reset_i,
        fast_cmd_i => cmd_fast_i,
        fast_cmd_o => cmd_fast_o,
        mmcm_ready_i => mmcm_ready_i

    );

    --== slow control block ==--
    -- muxdemux to select which hybrid is concerned for slow control
    slow_control_muxdemux_inst : entity work.slow_control_muxdemux
    generic map (
        NUM_HYBRID => NUM_HYBRIDS
    )
    port map (
        clk => clk_40,
        reset_i => reset_i,
        cmd_request_i => cmd_request_i,
        cmd_request_o => cmd_request,
        cmd_reply_i => cmd_reply,
        cmd_reply_o => cmd_reply_o
    );
    
    -- i2c master cores for the NHYBRIDS
    gen_i2c: for index in 0 to NUM_HYBRIDS-1 generate
        phy_i2c_wrapper_inst : entity work.phy_i2c_wrapper
        port map (
            clk => clk_40,
            reset => reset_i,
            cmd_request => cmd_request(index),
            cmd_reply => cmd_reply(index),
            
            scl_mosi => scl_mosi(index),
        
            sda_miso_to_master => sda_miso(index),
            sda_mosi_to_slave => sda_mosi(index),
            master_sda_tri => sda_tri(index)
        );
    end generate gen_i2c;
    
    
    --== triggered data readout block ==--
    gen_trig_data_readout : for index in 0 to NUM_HYBRIDS-1 generate
        trigger_data_readout_wrapper_inst : entity work.trigger_data_readout_wrapper
        --trigger_data_readout_wrapper_inst : entity work.trigger_data_readout_wrapper
        port map (
            clk320 => clk_320_i,
            clk40 => clk_40,
            reset_i => reset_i,
            triggered_data_from_fe_i => trig_data_i(index),
            sync_from_CBC_i => stub_data_i(index),
            trig_data_to_hb_o => trig_data_o(index)
        );
    end generate gen_trig_data_readout; 
    
    
    --== stub lines block ==--
    gen_stub_data_readout : for index in 0 to NUM_HYBRIDS-1 generate
       stub_data_readout_inst : entity work.stub_data_all_CBCs
        port map (
            clk320 => clk_320_i,
            reset_i => reset_i,       
            stub_lines_i =>  stub_data_i(index),
            cbc_data_to_hb_o => stub_data_o(index)
        );
    end generate gen_stub_data_readout;
    
    -- buffers
--    gen_buffers: for index in 0 to NUM_HYBRID-1 generate
--        buffers_inst : entity work.buffers
--        Port map (       
--            CBC_dp_p_i => cbc_dp_to_buf(index),
--            CBC_dp_n_i => cbc_dp_to_buf(index),
            
--            CBC_dp_o => open,
            
--            clk320_p_o  => open,
--            clk320_n_o  => open,
--            clk320_i    => '0',
            
--            fast_cmd_p_o     => cmd_fast_o,
--            fast_cmd_n_o     => open,
--            fast_cmd_i       => fast_cmd,   
        
--            reset_o          => reset_o,
--            reset_i          => reset_i,
            
--            SCL_i  => scl_mosi(index),
--            --SCL_o            : out std_logic; only the master drives the scl clock right now
--            SCL_io => scl_io(index),
               
--            SDA_io => sda_io(index),
--            SDA_mosi_i => sda_mosi(index),
--            SDA_miso_o => sda_miso(index),
--            SDA_tri_i => sda_tri(index)        
--        );
--    end generate gen_buffers;
    
end rtl;
