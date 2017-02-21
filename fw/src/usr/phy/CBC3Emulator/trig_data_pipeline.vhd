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
    --type pipeline_arr is array (5 downto 0) of trig_event;
  
    signal pipeline_add_in : integer := 0;

    signal w_enabled: std_logic_vector(0 downto 0) := (others=>'0');
    signal ena: std_logic;
    signal r_enabled: std_logic;
    --signal pipeline : pipeline_arr;
    signal l1_cnt : integer := 0;
    --signal tr_event : trig_event := (start_bits=>"00", error_bits=>"00", pipeline_address=>"000000000", l1_counter=>"000000000",cbc_data=>(others=>'0'), zeros=>"0000");
    signal tr_event_in : std_logic_vector(279 downto 0);
    signal tr_event_out : std_logic_vector(279 downto 0);
    signal l1_latency : integer := 2; 
  
   
begin

      pipeline_bram : entity work.cbc3_pipeline
      PORT MAP (
        clka => clk_40,
        ena => ena,
        wea => w_enabled,
        addra => std_logic_vector(to_unsigned(pipeline_add_in,9)),
        dina => tr_event_in,
        clkb => clk_40,
        enb => r_enabled,
        addrb => std_logic_vector(to_unsigned(pipeline_add_in-2,9)),
        doutb => tr_event_out
      );
  --  l1_latency <= to_integer(unsigned(trig_lat_i));
    -- writing to the pipeline
    write_to_pipe: process (clk_40)
    begin
        if (rising_edge(clk_40)) then
            if (reset_i='1') then
                --tr_event <= (start_bits=>"00", error_bits=>"00", pipeline_address=>"000000000", l1_counter=>"000000000",cbc_data=>(others=>'0'), zeros=>"0000");
                tr_event_in <=(others=>'0');
                pipeline_add_in <= 0;
            end if;
            ena<='1';
            w_enabled<=(others=>'1');
            tr_event_in <= "0000" &
                      data_i & 
                      std_logic_vector(to_unsigned(l1_cnt,9)) &
                      std_logic_vector(to_unsigned(pipeline_add_in,9))&
                      "00" & 
                      "11";
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
            r_enabled<='1';
            if (reset_i='1') then
                data_o <= (others=>'0');
                l1_cnt<=0; 
                --pipeline_add_out:=0;
            elsif (trigger_i='1') then
                data_o <= tr_event_out;
                -- FIXME implement latency error
                if l1_cnt+1=512 then
                    l1_cnt<=0;
                else
                    l1_cnt<=l1_cnt+1;
                end if; -- L1 cnt                   
             else
                data_o <= (others=>'0');
                r_enabled<='1';
            end if; -- trigger
        end if; -- rising edge
    end process;
end Behavioral;
