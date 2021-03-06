-- A simulated MAC core. Uses the FLI mechanism to send / receive packets
-- via a tun/tap virtual interface.
--
-- There are two modes of operation:
--
-- If MULTI_PACKET = false, there is a 'one-in, one-out' assumption, i.e.
-- multiple packets cannot be processed simultaneously. This allows the
-- simulator to be paused while waiting for a new packet, reducing the
-- number of cycles to be simulated. A timeout applies in case the firmware
-- decides not to reply to a packet.
--
-- If MULTI_PACKET = true, the simulator runs continuously, can receive
-- and transmit simultaneously, and can queue multiple input packets. This
-- will cause a large number of cycles to be simulated.
--
-- Dave Newbold, July 2012
--
-- $Id$

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity eth_mac_sim is
	generic(
		MULTI_PACKET: boolean := false
	);
	port(
  	clk: in std_logic; -- 125MHz clock for GBE
  	rst: in std_logic; -- Synchronous reset
  	tx_data: in std_logic_vector(7 downto 0);
  	tx_valid: in std_logic;
  	tx_last: in std_logic;
  	tx_error: in std_logic; -- Ignored in this design
  	tx_ready: out std_logic;
  	rx_data: out std_logic_vector(7 downto 0);
  	rx_valid: out std_logic;
  	rx_last: out std_logic;
  	rx_error: out std_logic -- Not used in this design
  );
  
  
end eth_mac_sim;

architecture behavioural of eth_mac_sim is

  attribute FOREIGN: string;

  procedure get_mac_data(
  	variable del_return: in integer;
    variable mac_data_out, mac_data_valid: out integer)
  is begin
    report "ERROR: get_mac_data can't get here";
  end;
  
  attribute FOREIGN of get_mac_data : procedure is "get_mac_data mac_fli.so";
  
  procedure store_mac_data(
    variable mac_data_in: in integer)
  is begin
    report "ERROR: store_mac_data can't get here";
  end;
  
  attribute FOREIGN of store_mac_data : procedure is "store_mac_data mac_fli.so";
  
  procedure put_packet
  is begin
    report "ERROR: put_packet can't get here";
  end;
  
  attribute FOREIGN of put_packet : procedure is "put_packet mac_fli.so";

  constant timeout: integer := 32768;

  signal rxen, rx_valid_d, rx_valid_i: std_logic;
  signal rx_data_i, rx_data_d: std_logic_vector(7 downto 0);
  signal timer: integer;
  signal last_del: std_logic_vector(3 downto 0);
  
begin

  rx_error <= '0';
  
  packet_rx: process(clk)    
    variable del, data, datav: integer;
  begin
    if MULTI_PACKET then
      del := 0;
    else
      del := 1;
    end if;

    if rising_edge(clk) then
      if rst = '1' then
        rxen <= '1';
        timer <= 0;
        last_del <= (others => '0');
      elsif rxen = '1' or MULTI_PACKET then
        get_mac_data(del_return => del,
        	mac_data_out => data,
        	mac_data_valid => datav);
        rx_data_i <= std_logic_vector(to_unsigned(data,8));
        if datav = 1 then
          rx_valid_i <= '1';
        else
          rx_valid_i <= '0';
          if rx_valid_d='1' then
            rxen <= '0';
          end if;          
        end if;
      else
        if tx_last = '1' or timer = timeout then
          rxen <= '1';
          timer <= 0;
        else
          timer <= timer + 1;
        end if;
      end if;
    
      rx_valid_d <= rx_valid_i;
      rx_data_d <= rx_data_i; -- Delay to allow generation of rx_last flag

      last_del <= last_del(2 downto 0) & (rx_valid_d and not rx_valid_i);
      
      if rx_valid_d = '1' then
      	rx_data <= rx_data_d;
      end if;
      
      rx_valid <= (rx_valid_d and rx_valid_i) or last_del(3);
      rx_last <= last_del(3);
    
    end if;
  end process;

  packet_tx: process(clk)
    variable data: integer;
  begin
  	if rising_edge(clk) then
  	
  		if tx_valid = '1' then
  			data := to_integer(unsigned(tx_data));
  			store_mac_data(mac_data_in => data);
  		end if;
  		if tx_last = '1' then
  			put_packet;
  		end if;
  		
  	end if;
  end process;
          
  tx_ready <= tx_valid;

end behavioural;
