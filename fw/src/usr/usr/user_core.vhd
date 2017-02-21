library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


use work.ipbus.all;
use work.system_package.all;
--! user packages
use work.user_package.all;
use work.user_version_package.all;

library unisim;
use unisim.vcomponents.all;

use work.cbc3_emulator_package.all;

entity user_core is 
port
(

	--# led
	usrled1_r						: out	std_logic; -- fmc_l12_spare[8]
	usrled1_g						: out	std_logic; -- fmc_l12_spare[9]
	usrled1_b						: out	std_logic; -- fmc_l12_spare[10]
	usrled2_r						: out	std_logic; -- fmc_l12_spare[11]
	usrled2_g						: out	std_logic; -- fmc_l12_spare[12]
	usrled2_b						: out	std_logic; -- fmc_l12_spare[13]

	--# on-board fabric clk
    fabric_clk_p                    : in    std_logic; -- new port [PV 2015.08.19]
    fabric_clk_n                    : in    std_logic; -- new port [PV 2015.08.19]
    fabric_coax_or_osc_p 			: in 	std_logic;
	fabric_coax_or_osc_n 			: in 	std_logic;

	--# on-board mgt clk
	pcie_clk_p						: in	std_logic;
    pcie_clk_n                      : in    std_logic;
	osc_xpoint_a_p					: in	std_logic;
	osc_xpoint_a_n					: in	std_logic;
	osc_xpoint_b_p					: in	std_logic;
	osc_xpoint_b_n					: in	std_logic;
	osc_xpoint_c_p					: in	std_logic;
	osc_xpoint_c_n					: in	std_logic;
	osc_xpoint_d_p					: in	std_logic;
	osc_xpoint_d_n					: in	std_logic;
	ttc_mgt_xpoint_a_p				: in	std_logic;
	ttc_mgt_xpoint_a_n				: in	std_logic;
	ttc_mgt_xpoint_b_p				: in	std_logic;
	ttc_mgt_xpoint_b_n				: in	std_logic;
	ttc_mgt_xpoint_c_p				: in	std_logic;
	ttc_mgt_xpoint_c_n				: in	std_logic;
			
	--# fmc mgt clk		
	fmc_l12_gbtclk0_a_p				: in	std_logic; 
	fmc_l12_gbtclk0_a_n				: in	std_logic; 
	fmc_l12_gbtclk1_a_p				: in	std_logic; 
	fmc_l12_gbtclk1_a_n				: in	std_logic; 
	fmc_l12_gbtclk0_b_p				: in	std_logic; 
	fmc_l12_gbtclk0_b_n				: in	std_logic; 
	fmc_l12_gbtclk1_b_p				: in	std_logic; 
	fmc_l12_gbtclk1_b_n				: in	std_logic; 
	fmc_l8_gbtclk0_p				: in	std_logic; 
	fmc_l8_gbtclk0_n				: in	std_logic; 
	fmc_l8_gbtclk1_p				: in	std_logic; 
	fmc_l8_gbtclk1_n				: in	std_logic; 

	--# fmc mgt
	fmc_l12_dp_c2m_p				: out	std_logic_vector(11 downto 0);
	fmc_l12_dp_c2m_n				: out	std_logic_vector(11 downto 0);
	fmc_l12_dp_m2c_p				: in	std_logic_vector(11 downto 0);
	fmc_l12_dp_m2c_n				: in	std_logic_vector(11 downto 0);
	fmc_l8_dp_c2m_p					: out	std_logic_vector( 7 downto 0);
	fmc_l8_dp_c2m_n					: out	std_logic_vector( 7 downto 0);
	fmc_l8_dp_m2c_p					: in	std_logic_vector( 7 downto 0);
	fmc_l8_dp_m2c_n					: in	std_logic_vector( 7 downto 0);
	
	--# fmc fabric clk	
    fmc_l8_clk0                     : in    std_logic; 
    fmc_l8_clk1                     : in    std_logic;
    fmc_l12_clk0                    : in    std_logic;
    fmc_l12_clk1                    : in    std_logic;    

	--# fmc gpio		
	fmc_l8_la_p						: inout	std_logic_vector(33 downto 0);
	fmc_l8_la_n						: inout	std_logic_vector(33 downto 0);
	fmc_l12_la_p					: inout	std_logic_vector(33 downto 0);
	fmc_l12_la_n					: inout	std_logic_vector(33 downto 0);
	
	--# amc mgt		
	k7_amc_rx_p						: inout	std_logic_vector(15 downto 1);
	k7_amc_rx_n						: inout	std_logic_vector(15 downto 1);
	amc_tx_p						: inout	std_logic_vector(15 downto 1);
	amc_tx_n						: inout	std_logic_vector(15 downto 1);
	
	--# amc fabric
	k7_fabric_amc_rx_p03			: inout	std_logic;
	k7_fabric_amc_rx_n03    		: inout	std_logic;
	k7_fabric_amc_tx_p03    		: inout	std_logic;
	k7_fabric_amc_tx_n03    		: inout	std_logic;

	--# ddr3
	ddr3_sys_clk_p 					: in	std_logic;
	ddr3_sys_clk_n 					: in	std_logic;
	ddr3_dq                 		: inout std_logic_vector( 31 downto 0);
	ddr3_dqs_p              		: inout std_logic_vector(  3 downto 0);
	ddr3_dqs_n              		: inout std_logic_vector(  3 downto 0);
	ddr3_addr               		: out   std_logic_vector( 13 downto 0);
	ddr3_ba                 		: out   std_logic_vector(  2 downto 0);
	ddr3_ras_n              		: out   std_logic;
	ddr3_cas_n              		: out   std_logic;
	ddr3_we_n               		: out   std_logic;
	ddr3_reset_n            		: out   std_logic;
	ddr3_ck_p               		: out   std_logic_vector(  0 downto 0);
	ddr3_ck_n               		: out   std_logic_vector(  0 downto 0);
	ddr3_cke                		: out   std_logic_vector(  0 downto 0);
	ddr3_cs_n               		: out   std_logic_vector(  0 downto 0);
	ddr3_dm                 		: out   std_logic_vector(  3 downto 0);
	ddr3_odt                		: out   std_logic_vector(  0 downto 0);

    --# cdce
	cdce_pll_lock_i                 : in    std_logic; -- new port [PV 2015.08.19]  
    cdce_pri_clk_bufg_o 		    : out 	std_logic; -- new port [PV 2015.08.19] 
    cdce_ref_sel_o                  : out   std_logic; -- new port [PV 2015.08.19]   
    cdce_pwrdown_o                  : out   std_logic; -- new port [PV 2015.08.19]  
    cdce_sync_o                     : out   std_logic; -- new port [PV 2015.08.19]  
    cdce_sync_clk_o                 : out   std_logic; -- new port [PV 2015.08.19]  

	--# system clk		
	osc125_a_bufg_i					: in	std_logic;
	osc125_a_mgtrefclk_i			: in	std_logic;
	osc125_b_bufg_i					: in 	std_logic;
	osc125_b_mgtrefclk_i			: in	std_logic;
    clk_31_250_bufg_i		        : in	std_logic; -- new port [PV 2015.08.19]
    
    --# ipbus comm    
	ipb_clk_o				        : out	std_logic;
	ipb_rst_i				        : in	std_logic;
	ipb_miso_o			            : out	ipb_rbus_array(0 to nbr_usr_slaves-1);
	ipb_mosi_i			            : in	ipb_wbus_array(0 to nbr_usr_slaves-1);

    --# ipbus conf
	ip_addr_o						: out	std_logic_vector(31 downto 0);
    mac_addr_o                      : out   std_logic_vector(47 downto 0);
    rarp_en_o                       : out   std_logic;
    use_i2c_eeprom_o                : out   std_logic
);
end user_core;

architecture usr of user_core is

    --===================================--
    -- Constant definition
    --===================================--
    constant NUM_HYBRIDS            : integer := 1;
    --===================================--
    
    --===================================--
    -- Signal definition
    --===================================--
    signal fabric_clk_pre_buf       : std_logic;                
    signal fabric_clk               : std_logic;
    --===================================--
    
    
    signal mmcm_ready :std_logic;
    signal clk_320MHz : std_logic;
    signal clk_40MHz : std_logic;
    
    
    signal cmd_reply : cmd_rbus;
    signal stub_to_hb : stub_data_to_hb_t_array(0 to NUM_HYBRIDS-1);
    signal trig_data_to_hb : triggered_data_frame_r_array(0 to NUM_HYBRIDS-1);
    signal fast_command_to_phy : cmd_fastbus := (fast_reset=>'0', trigger=>'0', test_pulse_trigger=>'0', orbit_reset=>'1');

    signal scl_io  : std_logic_vector(0 to NUM_HYBRIDS-1);
    signal sda_io  : std_logic_vector(0 to NUM_HYBRIDS-1);
    
    signal cmd_fast : std_logic;
    signal trigger_data_fromCBC : trig_data_from_fe_t_array(0 to NUM_HYBRIDS-1);
    signal stub_data_fromCBC : stub_lines_r_array_array(0 to NUM_HYBRIDS-1);
    
    signal sda_miso : std_logic_vector(0 to NUM_HYBRIDS-1);
    signal sda_mosi : std_logic_vector(0 to NUM_HYBRIDS-1);
    signal scl_mosi : std_logic_vector(0 to NUM_HYBRIDS-1);
    
    attribute keep: boolean;
    attribute keep of clk_320MHz: signal is true;
begin

    --===========================================--
    -- other clocks
    --===========================================--
    fclk_ibuf:      ibufgds     port map (i => fabric_clk_p, ib => fabric_clk_n, o => fabric_clk_pre_buf);
    --fclk_bufg:      bufg        port map (i => fabric_clk_pre_buf,               o => fabric_clk);
    --===========================================--

    --===================================--
    -- Block responsible for clock generation
    --===================================--
    clock_generator_block: entity work.clock_generator_core;
    --===================================--
    --generic map
    --(
    --)
    --port map
    --(
    --);       
    --===================================--	
    
    --===================================--
    -- Block responsible for I2C command processing. Is connected to: fast command block, hybrids.
    --===================================--
    command_processor_block: entity work.command_processor_core;
    --===================================--
    --generic map
    --(
    --)
    --port map
    --(
    --);        
    --===================================--    
    
    --===================================--
    -- Fast commands. Connected to: physical interface, hybrids.
    --===================================--
    fast_command_block: entity work.fast_command_core;
    --===================================--
    --generic map
    --(
    --)
    --port map
    --(
    --);        
    --===================================-- 
    
    --===================================--
    -- Hybrids generation
    --===================================--   
    HYB_GEN : FOR hybrid_i IN 1 TO NUM_HYBRIDS GENERATE
    --===================================--
    hybrid_block: entity work.hybrid_core;
    --===================================--
    --generic map
    --(
    --)
    --port map
    --(
    --);        
    --===================================--
    END GENERATE HYB_GEN;
    --===================================--    
    
    --===================================--
    -- Physical interface layer. Connected to: hybrids (40mhz lines + I2C lines), fast commands, FMC 1&2
    --===================================--
    -- temporary mmcm for 320 and 40 MHz clocks
    mmcm_inst : entity work.mmcm
    port map ( 
    
       -- Clock in ports
       clk_in1 => fabric_clk_pre_buf,
      -- Clock out ports  
       clk_out40 => clk_40MHz,
       clk_out320 => clk_320MHz,
      -- Status and control signals                
       reset => '0',
       locked => mmcm_ready            
    );
     
     CBC3_emulator : entity work.CBC3_generator
     port map(
        --scl_io => scl_io,
        --sda_io => sda_io,
        reset_i => '0',
 
        clk320_i =>  clk_320MHz,
        cmd_fast_i => cmd_fast,
        trig_data_o => trigger_data_fromCBC,
        stub_data_o => stub_data_fromCBC,
        sda_miso_o_top => sda_miso,
        sda_mosi_i_top => sda_mosi,
        scl_i => scl_mosi,
        clk40_test_i => clk_40MHz,
        mmcm_ready_i => mmcm_ready
 
--       -- clk_40_CBC3_o => clk_40_CBC3
--        --clk40_i => clk_40MHz
--        led2_red_o => led2_red_o,
--        led1_red_o => led1_red_o,
--       -- led1_blue_o => led1_blue_o,
--       -- led1_green_o => led1_green_o,
--        clk40_test_i => clk_40_i
 
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
        clk_320_o           => usrled1_g,
        reset_i             => '0',

        -- fast command input bus
        cmd_fast_i          => fast_command_to_phy, --0001 
    
        -- fast command serial output
        cmd_fast_o          => cmd_fast, 

        -- hybrid block interface for triggered data
        trig_data_o         => trig_data_to_hb,

        -- hybrid block interface for stub data
        stub_data_o         => stub_to_hb,
    
        -- triggered data lines from CBC
        trig_data_i         => trigger_data_fromCBC,

        -- stubs lines from CBC
        stub_data_i         => stub_data_fromCBC,
    
        -- slow control command from command generator
        cmd_request_i       => (cmd_strobe => '1', cmd_hybrid_id => (others => '0'), cmd_chip_id => (others => '0'), cmd_page => '0', cmd_read => '0', cmd_register => (others => '0'), cmd_data => (others => '0'), cmd_write_mask => (others => '0')),
    
        -- slow control response to command generator
        cmd_reply_o         => cmd_reply,
        
        sda_miso_i => sda_miso,
        sda_mosi_o => sda_mosi,
        scl_o => scl_mosi,
        mmcm_ready_i => mmcm_ready

        
--        scl_io => scl_io,
--        sda_io => sda_io
    );        
    usrled1_r <= sda_miso(0);
    fmc_l8_la_p(32 downto 25) <= cmd_reply.cmd_data;
    usrled2_r <= cmd_reply.cmd_err;
    usrled2_g <= trig_data_to_hb(0).latency_error;
    usrled1_b <= stub_to_hb(0)(0).stub1(0);
    usrled2_b <= cmd_fast;
    --===================================--
    
    --===================================--
    -- BE Data Buffer - Contains Global Event Builder. Connected to: hybrids
    --===================================--
    be_data_buffer_block: entity work.be_data_buffer_core;
    --===================================--
    --generic map
    --(
    --)
    --port map
    --(
    --);        
    --===================================--  
    

end usr;
