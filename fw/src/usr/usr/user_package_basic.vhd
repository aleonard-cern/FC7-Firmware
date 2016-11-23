library ieee;
use ieee.std_logic_1164.all;
 
package user_package is

	constant sys_phase_mon_freq      : string   := "160MHz"; -- valid options only "160MHz" or "240MHz"    

   --=== ipb slaves =============--
	constant nbr_usr_slaves				: positive := 2 ;
   
	constant user_ipb_stat_regs		: integer  := 0 ;
	constant user_ipb_ctrl_regs		: integer  := 1 ;

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
    
    --== triggered data to hybrid block ==--
    subtype trig_data_to_hb_t is std_logic_vector(137 downto 0);
    type trig_data_to_hb_t_array is array(natural range <>) of trig_data_to_hb_t;
    
    --== triggered data from front-end ==--
    subtype trig_data_from_fe_t is std_logic_vector(7 downto 0);
    type trig_data_from_fe_t_array is array(natural range <>) of trig_data_from_fe_t;
    
    --== stub data to hybrid block ==--
    subtype stub_data_to_hb_t is std_logic_vector(319 downto 0);
    type stub_data_to_hb_t_array is array(natural range <>) of stub_data_to_hb_t;
    
    --== stub data from front-end ==--
    type stub_lines_r is
    record
        dp1: std_logic;
        dp2: std_logic;
        dp3: std_logic;
        dp4: std_logic;
        dp5: std_logic;
    end record; 
    type stub_lines_t is array(7 downto 0) of stub_lines_r;
    type stub_lines_t_array is array(natural range <>) of stub_lines_t;
    
    --== fast command record ==--
    type cmd_fastbus is
    record
        fast_reset:         std_logic;
        trigger:            std_logic;
        test_pulse_trigger: std_logic;
        orbit_reset:        std_logic;
    end record;

end user_package;
   
package body user_package is
end user_package;
