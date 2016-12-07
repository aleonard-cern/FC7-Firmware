library ieee;
use ieee.std_logic_1164.all;
 
package user_package is

	constant sys_phase_mon_freq      : string   := "160MHz"; -- valid options only "160MHz" or "240MHz"    

   --=== ipb slaves =============--
	constant nbr_usr_slaves		    : positive := 2 ;
   
	constant user_ipb_stat_regs		: integer  := 0 ;
	constant user_ipb_ctrl_regs		: integer  := 1 ;


    constant NCBC_PER_HYBRID : natural := 8;

    --=== slow control records ===--
    -- The signals going from master to slaves
    type cmd_wbus is
    record
       cmd_strobe            : std_logic;
       -- hybrid_id
       cmd_hybrid_id         : std_logic_vector(4 downto 0);
       -- cbc on hybrid id
       cmd_chip_id           : std_logic_vector(3 downto 0);
       -- page in CBC
       cmd_page              : std_logic;
       -- read or write setting
       cmd_read              : std_logic;
       -- register_address
       cmd_register          : std_logic_vector(7 downto 0);
       -- data to cbc
       cmd_data              : std_logic_vector(7 downto 0);
       -- register write mask ( to avoid overriding of the current settings )
       cmd_write_mask        : std_logic_vector(7 downto 0);
    end record;

    type cmd_wbus_array is array(natural range <>) of cmd_wbus;
        
    -- The signals going from slaves to master      
    type cmd_rbus is
    record
       cmd_strobe            : std_logic;
       cmd_data              : std_logic_vector(7 downto 0);
       cmd_err               : std_logic;
    end record;

    type cmd_rbus_array is array(natural range <>) of cmd_rbus;
   
    --============================-- 
    --=== lines from front-end ===--
    --== triggered data to hybrid block ==--
    subtype trig_data_to_hb_t is std_logic_vector(137 downto 0);
    type trig_data_to_hb_t_array is array(natural range <>) of trig_data_to_hb_t;
    
    --== triggered data from front-end ==--
    subtype trig_data_from_fe_t is std_logic_vector(7 downto 0);
    type trig_data_from_fe_t_array is array(natural range <>) of trig_data_from_fe_t;

    
    --== differential pairs to buffer ==--
    subtype cbc_dp_to_buf is std_logic_vector(5 downto 0);
    type cbc_dp_to_buf_array is array(natural range <>) of cbc_dp_to_buf;
    
    --== stub data from front-end ==--
    type stub_lines_r is
    record
        dp1 : std_logic;
        dp2 : std_logic;
        dp3 : std_logic;
        dp4 : std_logic;
        dp5 : std_logic;
    end record; 
    type stub_lines_r_array is array(7 downto 0) of stub_lines_r;
    
        --== stub data from front-end array (for mutliple hybrids) ==--
    type stub_lines_r_array_array is array(natural range <>) of stub_lines_r_array;
    
    type one_cbc_stubs_r is
    record
        sync_bit : std_logic;
        error_flags : std_logic;
        or254 : std_logic;
        s_overflow : std_logic;
        stub1 : std_logic_vector(7 downto 0);
        bend1 : std_logic_vector(3 downto 0);
        stub2 : std_logic_vector(7 downto 0);
        bend2 : std_logic_vector(3 downto 0);
        stub3 : std_logic_vector(7 downto 0);
        bend3 : std_logic_vector(3 downto 0);                
    end record;
    
        
    --== stub data to hybrid block ==--
    type one_cbc_stubs_r_array is array(NCBC_PER_HYBRID downto 0) of one_cbc_stubs_r;
    
    type stub_data_to_hb_t_array is array(natural range <>) of one_cbc_stubs_r_array;
    
    
    --== fast command record ==--
    type cmd_fastbus is
    record
        fast_reset         : std_logic;
        trigger            : std_logic;
        test_pulse_trigger : std_logic;
        orbit_reset        : std_logic;
    end record;
    
    --== triggered data frame record ==--
    type triggered_data_frame_r is
    record
        start           : std_logic_vector(1 downto 0);
        latency_error   : std_logic;
        buffer_overflow : std_logic;
        pipe_address    : std_logic_vector(8 downto 0);
        l1_counter      : std_logic_vector(8 downto 0);
        channels        : std_logic_vector(253 downto 0);
    end record;
    
    --== triggered data frame record array ==--
    type triggered_data_frame_r_array is array (7 downto 0) of triggered_data_frame_r;
    
end user_package;
   
package body user_package is
end user_package;
