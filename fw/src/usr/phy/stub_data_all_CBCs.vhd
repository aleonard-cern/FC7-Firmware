----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/29/2016 12:01:22 PM
-- Design Name: 
-- Module Name: stub_data_all_CBCs - structural
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

entity stub_data_all_CBCs is
    port (
        clk320: in std_logic;
        reset_i: in std_logic;       
        stub_lines_i : in stub_lines_r_array;
        cbc_data_to_hb_o: out one_cbc_stubs_r_array
    );
end stub_data_all_CBCs;

architecture structural of stub_data_all_CBCs is
    
    signal cbc_data_to_hb: one_cbc_stubs_r_array;

begin


    --== instantiate the NCBC (or NMPA) front-end chips per hybrid blocks ==--
    CBCs:
    for I in 0 to NCBC_PER_HYBRID - 1 generate
        Stub_readout : entity work.stub_data_readout
        port map (
            clk320 => clk320,
            reset_i => reset_i,

            stub_data_from_fe_i => stub_lines_i(I),
        
            -- output triggered data frame
            stub_data_from_fe_o => cbc_data_to_hb(I)
        );

    end generate CBCs;

    cbc_data_to_hb_o <= cbc_data_to_hb;

end structural;
