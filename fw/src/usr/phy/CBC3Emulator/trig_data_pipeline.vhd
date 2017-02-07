----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/13/2016 04:37:57 PM
-- Design Name: 
-- Module Name: trig_data_pipeline - Behavioral
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

entity trig_data_pipeline is
Port ( 
    clk_40 : in std_logic;
    reset_i : in std_logic;
    trigger_i : in std_logic;
    --trig_lat_i : in std_logic_vector(8 downto 0);
    data_i : in std_logic_vector(253 downto 0);
    data_o : out std_logic_vector(279 downto 0)
);
end trig_data_pipeline;

architecture Behavioral of trig_data_pipeline is

    type trig_event is record
        start_bits : std_logic_vector(1 downto 0);
        error_bits : std_logic_vector(1 downto 0);
        pipeline_address : std_logic_vector(8 downto 0);
        l1_counter : std_logic_vector(8 downto 0);
        cbc_data : std_logic_vector(253 downto 0); 
        zeros : std_logic_vector (3 downto 0);
    end record; 
    type pipeline_arr is array (511 downto 0) of trig_event;
  
    signal pipeline_add_in : integer := 0;

    signal pipeline : pipeline_arr;
    signal l1_cnt : integer := 0;
    signal tr_event : trig_event := (start_bits=>"00", error_bits=>"00", pipeline_address=>"000000000", l1_counter=>"000000000",cbc_data=>(others=>'0'), zeros=>"0000");
    signal l1_latency : integer := 2; 
     
begin
  --  l1_latency <= to_integer(unsigned(trig_lat_i));
    -- writing to the pipeline
    write_to_pipe: process (clk_40)
    begin
        if (rising_edge(clk_40)) then
            if (reset_i='1') then
                tr_event <= (start_bits=>"00", error_bits=>"00", pipeline_address=>"000000000", l1_counter=>"000000000",cbc_data=>(others=>'0'), zeros=>"0000");
                pipeline_add_in <= 0;
            end if;
            tr_event <=(start_bits=>"11", error_bits=>"00", pipeline_address=>std_logic_vector(to_unsigned(pipeline_add_in,9)), l1_counter=>std_logic_vector(to_unsigned(l1_cnt,9)),cbc_data=>data_i, zeros=>"0000");
            pipeline(pipeline_add_in)<= tr_event;
            if (pipeline_add_in+1=512) then
                pipeline_add_in<=0;
            else
                pipeline_add_in <= pipeline_add_in+1;
            end if; 
        end if;
    end process;
    
    -- reading from the pipeline
    read_from_pipe: process(clk_40)
    variable pipeline_add_out : integer := 0;
    begin
        if (rising_edge(clk_40)) then   
            if (reset_i='1') then
                data_o <= (others=>'0');
                l1_cnt<=0; 
                pipeline_add_out:=0;
            elsif (trigger_i='1') then
                -- trigger latency
                if (pipeline_add_in<l1_latency) then
                    pipeline_add_out := 512-l1_latency+pipeline_add_in;
                else
                    pipeline_add_out := pipeline_add_in-l1_latency;
                end if;
                -- output data
                  data_o <= pipeline(pipeline_add_out).zeros &
                            pipeline(pipeline_add_out).cbc_data & 
                            std_logic_vector(to_unsigned(l1_cnt,9)) &
                            pipeline(pipeline_add_out).pipeline_address &
                            pipeline(pipeline_add_out).error_bits & 
                            pipeline(pipeline_add_out).start_bits;
                -- FIXME implement latency error
                if l1_cnt+1=512 then
                    l1_cnt<=0;
                else
                    l1_cnt<=l1_cnt+1;
                end if; -- L1 cnt                
             else
                data_o <= (others=>'0');
            end if; -- trigger
        end if; -- rising edge
    end process;
end Behavioral;
