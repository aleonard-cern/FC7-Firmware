----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/22/2016 03:29:44 PM
-- Design Name: 
-- Module Name: slow_control_package - Behavioral
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

package slow_control_package is
    
    --== Slow Control options ==--
    
    constant SC_TIMEOUT         : integer := 200_000;
    constant SC_TIMEOUT_ERROR : std_logic_vector(31 downto 0) := x"00000001";
    
end slow_control_package;
    
package body slow_control_package is
    
end slow_control_package;
