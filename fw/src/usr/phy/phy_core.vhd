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
        constant NHYBRID       : natural range 1 to 32;
        constant NCBCPERHYBRID : natural range 1 to 8
    );
    port (
    
        clk_40              : in std_logic;
        clk_320             : in std_logic;
        reset_i             : in std_logic;
    
        -- fast command input bus
        cmd_fast_i          : in cmd_fastbus;
        
        -- fast command serial output
        cmd_fast_o          : out std_logic;
    
        -- hybrid block interface for triggered data
        trig_data_o         : out trig_data_to_hb_t_array(1 to NHYBRID);
    
        -- hybrid block interface for stub data
        stub_data_o         : out stub_data_to_hb_t_array(1 to NHYBRID);
        
        -- triggered data lines from CBC
        trig_data_i         : in trig_data_from_fe_t_array(1 to NHYBRID);
    
        -- stubs lines from CBC
        stub_data_i         : in stub_lines_r_array_array(1 to NHYBRID);
        
        -- slow control command from command generator
        cmd_request_i       : in cmd_wbus;
        
        -- slow control response to command generator
        cmd_reply_o         : out cmd_rbus 
        
        
    );
end phy_core;

architecture rtl of phy_core is

    signal dummy_signal             : std_logic := '0';
    signal cmd_request              : cmd_wbus_array(1 to NHYBRID);
    signal cmd_reply                : cmd_rbus_array(1 to NHYBRID);

begin

    dummy_signal <= '1';
    
    --== fast command block ==--
    fast_cmd_inst: entity work.fast_cmd_block
    port map (
        clk40 => clk_40,
        clk320 => clk_320,
        reset_i => reset_i,
        fast_cmd_i => cmd_fast_i,
        fast_cmd_o => cmd_fast_o
    );

    --== slow control block ==--
    -- muxdemux to select which hybrid is concerned
    slow_control_muxdemux_inst : entity work.slow_control_muxdemux
    port map (
        clk => clk_40,
        reset_i => clk_40,
        cmd_request_i => cmd_request_i,
        cmd_request_o => cmd_request,
        cmd_reply_i => cmd_reply,
        cmd_reply_o => cmd_reply_o
    );
    
    -- i2c master cores for the NHYBRIDS
    gen_i2c: for I in 1 to NHYBRID generate
        phy_i2c_wrapper_inst : entity work.phy_i2c_wrapper
        port map (
            clk => clk_40,
            reset => reset_i,
            cmd_request => cmd_request(I),
            cmd_reply => cmd_reply(I)
        );
    end generate gen_i2c;
    
    
    --== triggered data readout block ==--
    gen_trig_data_readout : for I in 1 to NHYBRID generate

        trigger_data_readout_wrapper_inst : entity work.trigger_data_readout_wrapper
        port map (
            clk320 => clk_320,
            clk40 => clk_40,
            reset_i => reset_i,
            triggered_data_from_fe_i => trig_data_i(I),
            sync_from_CBC_i => stub_data_i(I),
            trig_data_to_hb_o => trig_data_o(I)
        );

    end generate gen_trig_data_readout; 
    
    
    --== stub lines block ==--
    gen_stub_data_readout : for I in 1 to NHYBRID generate
    
        stub_data_readout_inst : entity work.stub_data_all_CBCs
        port map (
            clk320 => clk_320,
            reset_i => reset_i,       
            stub_lines_i =>  stub_data_i(I),
            cbc_data_to_hb_o => stub_data_o(I)
        );
        
    end generate gen_stub_data_readout;
    
    -- buffers
    
    
    
end rtl;
