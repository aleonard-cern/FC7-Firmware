library ieee;
use ieee.std_logic_1164.all;
 
package cbc3_emulator_package is

    
    --== random number seeds ==--
    constant random_number_seed_A		: integer  := 7895 ;
    constant random_number_seed_B		: integer  := 3454 ;
    
    --== data format for registers ==--
     type array_reg_page1 is array (0 to 80) of std_logic_vector(7 downto 0); 
     type array_reg_page2 is array (0 to 255) of std_logic_vector(7 downto 0); 

     --== default values for registers ==--
     --common register for two pages
     
     --start of page 1 registers
     constant rFE_CTRL_Beta_Mult_Trig_Lat : std_logic_vector(7 downto 0):="00111100";
    --Table 2-Trigger Latency: Page 1 Address 00000001
    constant rTrig_Lat : std_logic_vector(7 downto 0):="11001000";
    --Table 3-Beta Mulitplier and SLVS : Page 1 Address 00000010
    constant rBeta_Mult_SLVS : std_logic_vector(7 downto 0):="00011000";
    --Table 4-Ipre1: Page 1 Address 00000011
    constant rIpre1 : std_logic_vector(7 downto 0):="01000110";
    --Table 5-Ipre2: Page1 Address 00000100
    constant rIpre2 : std_logic_vector(7 downto 0):="00101110";
    --Table 6-Ipsf: Page 1 Address 00000101
    constant rIpfs : std_logic_vector(7 downto 0):="01111010";
    --Table 7-Ipa: Page 1 Address 00000110
    constant rIpa : std_logic_vector(7 downto 0):="01101010";
    --Table 8: Table 8-Ipaos: Page 1 Address 00000111
    constant rIpaos  : std_logic_vector(7 downto 0):="01001011";
    --add a dummy register to keep in track with the counting of register addresses in the CBC3 register addresses manual
    constant rDummy1 : std_logic_vector(7 downto 0):="00000000"; 
    --Table 9-Icomp: Page 1 Address 00001001
    constant rIcomp : std_logic_vector(7 downto 0):="00100011";
    --add a dummy register to keep in track with the counting of register addresses in the CBC3 register addresses manual
    constant rDummy2 : std_logic_vector(7 downto 0):="00000000"; 
    --Table 1-VPLUS1/VLUS2: Page 1 Address 00001011
    constant rVPLUS1_VPLUS2 : std_logic_vector(7 downto 0):="01110111";
    --Table 11-HIP & Test Mode: Page 1 Address 00001100
    constant rHIP_TestMode : std_logic_vector(7 downto 0):="00000000";
    --Table 12-Test Pulse Potentiometer Node Select: Page 1 Address 00001101
    constant rTest_Pulse_Pot_Node_Sel : std_logic_vector(7 downto 0):="00000000";
    --Table 13-Test Pulse Delay & Test Channel Group: Page 1 Address 00001110
    constant rTest_Pulse_Del_Test_Ch_Group : std_logic_vector(7 downto 0):="00000000";
    --Table 14-Misc Test Pulse Control & Analogue Mux: Page 1 Address 00001111
    constant rMisc_Test_Pulse_Ctrl_An_Mux : std_logic_vector(7 downto 0):="00000000";
    --Table 15-CAL_Ibias test pulse reference current: Page 1 Address 00010000
    constant rCAL_Ibias : std_logic_vector(7 downto 0):="00010000";
    --Table 16-CAL_Vcasc test pulse cascade voltage: Page 1 Address 00010001
    constant rVcasc : std_logic_vector(7 downto 0):="00010000";
    --Table 17-Pipeline/Stub logic input select & Pt width: Page 1 Address 00010010
    constant rPipeline_Stublogic_input : std_logic_vector(7 downto 0):= "00000011";
    --Table 18-Coincidence window offset 4 and 3: Page 1 Address 00010011
    constant rCoinc_wind_offset_4_3 : std_logic_vector(7 downto 0):="00000000";
    --Table 19-Coincidence window offset 2 and 1: Page 1 Address 00010100
    constant rCoinc_wind_offset_2_1 : std_logic_vector(7 downto 0):="00000000";
    --Table 20-Bandgap Fuse Reister: Page 1 Address 00010101
    constant rBandgap_Fuse : std_logic_vector(7 downto 0):="00000000";
    --Table 21-Chip ID Fuse REG 1: Page 1 Address 00010110
    constant rChip_ID_Fuse_1 : std_logic_vector(7 downto 0):="00000000";
    --Table 21-Chip ID Fuse REG 1: Page 1 Address 00010110
    constant rChip_ID_Fuse_2 : std_logic_vector(7 downto 0):="00000000";
    --Table 23-Chip ID Fuse REG 3: Page 1 Address 00011000
    constant rChip_ID_Fuse_3 : std_logic_vector(7 downto 0):="00000000";
    --add a dummy register to keep in track with the counting of register addresses in the CBC3 register addresses manual
    constant rDummy3 : std_logic_vector(7 downto 0):="00000000"; 
    --add a dummy register to keep in track with the counting of register addresses in the CBC3 register addresses manual
    constant rDummy4 : std_logic_vector(7 downto 0):="00000000"; 
    --Table 24-Layer Swap and Cluster width: Page 1 Address 00011011
    constant rLayer_swap_Cl_width : std_logic_vector(7 downto 0):="00000000";
    --Table 25-40MHz clock and OR254: Page 1 Address 00011100
    constant rFortyMHz_clk_OR254 : std_logic_vector(7 downto 0):="00011100";
    --Table 26-Serial command interface and Error Flags: Page 1 Address 00011101
    constant rSer_cmd_Err_flags : std_logic_vector(7 downto 0):="00000000";
    --add a dummy register to keep in track with the counting of register addresses in the CBC3 register addresses manual
    constant rDummy5 : std_logic_vector(7 downto 0):="00000000"; 
    --add a dummy register to keep in track with the counting of register addresses in the CBC3 register addresses manual
    constant rDummy6 : std_logic_vector(7 downto 0):="00000000"; 
    --Table 27-Mask Channels 1-248: Page 1 Addresses 00100000 to 00111110
    constant rMask_Channels_1_8 : std_logic_vector(7 downto 0):="00000000";
    constant rMask_Channels_9_16 : std_logic_vector(7 downto 0):="00000000";
    constant rMask_Channels_17_24 : std_logic_vector(7 downto 0):="00000000";
    constant rMask_Channels_25_32 : std_logic_vector(7 downto 0):="00000000";
    constant rMask_Channels_33_40 : std_logic_vector(7 downto 0):="00000000";
    constant rMask_Channels_41_48 : std_logic_vector(7 downto 0):="00000000";
    constant rMask_Channels_49_56 : std_logic_vector(7 downto 0):="00000000";
    constant rMask_Channels_57_64 : std_logic_vector(7 downto 0):="00000000";
    constant rMask_Channels_65_72 : std_logic_vector(7 downto 0):="00000000";
    constant rMask_Channels_73_80 : std_logic_vector(7 downto 0):="00000000";
    
    constant rMask_Channels_81_88 : std_logic_vector(7 downto 0):="00000000";
    constant rMask_Channels_89_96 : std_logic_vector(7 downto 0):="00000000";
    constant rMask_Channels_97_104 : std_logic_vector(7 downto 0):="00000000";
    constant rMask_Channels_105_112 : std_logic_vector(7 downto 0):="00000000";
    constant rMask_Channels_113_120 : std_logic_vector(7 downto 0):="00000000";
    constant rMask_Channels_121_128 : std_logic_vector(7 downto 0):="00000000";
    constant rMask_Channels_129_136 : std_logic_vector(7 downto 0):="00000000";
    constant rMask_Channels_137_144 : std_logic_vector(7 downto 0):="00000000";
    constant rMask_Channels_145_152 : std_logic_vector(7 downto 0):="00000000";
    constant rMask_Channels_153_160 : std_logic_vector(7 downto 0):="00000000";
    
    constant rMask_Channels_161_168 : std_logic_vector(7 downto 0):="00000000";
    constant rMask_Channels_169_176 : std_logic_vector(7 downto 0):="00000000";
    constant rMask_Channels_177_184 : std_logic_vector(7 downto 0):="00000000";
    constant rMask_Channels_185_192 : std_logic_vector(7 downto 0):="00000000";
    constant rMask_Channels_193_200 : std_logic_vector(7 downto 0):="00000000";
    constant rMask_Channels_201_208 : std_logic_vector(7 downto 0):="00000000";
    constant rMask_Channels_209_216 : std_logic_vector(7 downto 0):="00000000";
    constant rMask_Channels_217_224 : std_logic_vector(7 downto 0):="00000000";
    constant rMask_Channels_225_232 : std_logic_vector(7 downto 0):="00000000";
    constant rMask_Channels_233_240 : std_logic_vector(7 downto 0):="00000000";
    
    constant rMask_Channels_241_248 : std_logic_vector(7 downto 0):="00000000";
    
    --Table 28-Mask Channels 249-256: Page 1 Address 00111111
    constant rMask_Channels_249_256 : std_logic_vector(7 downto 0):="00000000";
    --Table 29-Bend register<0:14>: Page 1 Addresses 01000000 - 01001110    
    constant rBend_min_7 : std_logic_vector(7 downto 0):="10011001";
    constant rBend_min_6 : std_logic_vector(7 downto 0):="10101010";
    constant rBend_min_5 : std_logic_vector(7 downto 0):="10111011";
    constant rBend_min_4 : std_logic_vector(7 downto 0):="11001100";
    constant rBend_min_3 : std_logic_vector(7 downto 0):="11011101";
    constant rBend_min_2 : std_logic_vector(7 downto 0):="11101110";
    constant rBend_min_1 : std_logic_vector(7 downto 0):="11111111";
    constant rBend_0 : std_logic_vector(7 downto 0):="00000000";
    constant rBend_plus_1 : std_logic_vector(7 downto 0):="00010001";
    constant rBend_plus_2 : std_logic_vector(7 downto 0):="00100010";
    constant rBend_plus_3 : std_logic_vector(7 downto 0):="00110011";
    constant rBend_plus_4 : std_logic_vector(7 downto 0):="01000100";
    constant rBend_plus_5 : std_logic_vector(7 downto 0):="01010101";
    constant rBend_plus_6 : std_logic_vector(7 downto 0):="01100110";
    constant rBend_plus_7 : std_logic_vector(7 downto 0):="10000111";
    --Table 30-VTH (Threshold Voltage): Page 1 Address 01001111
    constant rVTH1 :  std_logic_vector(7 downto 0):="00000000";
    --Table 31-VTH (Threshold Voltage): Page 1 Address 01010000
    constant rVTH2 : std_logic_vector(7 downto 0):="00000010";
    --end of page 1 registers
    --=======================--
    --start of page 2 registers 
    --for page 2 the registers all look alike. The register 0 we will treat as a dummy. The register that
    --holds this information is stored in register 0 of page 1 anyway. The other registers are all "10000000"
    --Table 32-Channel 1-254 Offset : Page 2 Addresses 00000001 to 11111110
    constant rPage2 : std_logic_vector(7 downto 0):="10000000";
    --end of page 2 registers
    --default registers
    constant regs_page1_default : array_reg_page1 := (
    rFE_CTRL_Beta_Mult_Trig_Lat,
    rTrig_Lat,
    rBeta_Mult_SLVS,
    rIpre1,
    rIpre2,
    rIpfs,
    rIpa,
    rIpaos,
    rDummy1,
    rIcomp,
    rDummy2,
    rVPLUS1_VPLUS2,
   rHIP_TestMode,
   rTest_Pulse_Pot_Node_Sel,
   rTest_Pulse_Del_Test_Ch_Group,
   rMisc_Test_Pulse_Ctrl_An_Mux,
   rCAL_Ibias,rVcasc,
   rPipeline_Stublogic_input, 
   rCoinc_wind_offset_4_3, 
   rCoinc_wind_offset_2_1, 
   rBandgap_Fuse,
   rChip_ID_Fuse_1, 
   rChip_ID_Fuse_2, 
   rChip_ID_Fuse_3, 
   rDummy3, 
   rDummy4,
   rLayer_swap_Cl_width, 
   rFortyMHz_clk_OR254, 
   rSer_cmd_Err_flags,
   rDummy5,
   rDummy6, 
   rMask_Channels_1_8,
    rMask_Channels_9_16 ,
    rMask_Channels_17_24 ,
    rMask_Channels_25_32 ,
    rMask_Channels_33_40 ,
    rMask_Channels_41_48 ,
    rMask_Channels_49_56 ,
    rMask_Channels_57_64 ,
    rMask_Channels_65_72 ,
    rMask_Channels_73_80 ,
    rMask_Channels_81_88 ,
    rMask_Channels_89_96 ,
    rMask_Channels_97_104 ,
    rMask_Channels_105_112 ,
    rMask_Channels_113_120 ,
    rMask_Channels_121_128 ,
    rMask_Channels_129_136 ,
    rMask_Channels_137_144 ,
    rMask_Channels_145_152 ,
    rMask_Channels_153_160 ,
    rMask_Channels_161_168 ,
    rMask_Channels_169_176 ,
    rMask_Channels_177_184 ,
    rMask_Channels_185_192 ,
    rMask_Channels_193_200 ,
    rMask_Channels_201_208 ,
    rMask_Channels_209_216 ,
    rMask_Channels_217_224 ,
    rMask_Channels_225_232 ,
    rMask_Channels_233_240 ,
    rMask_Channels_241_248,
    rMask_Channels_249_256,
    rBend_min_7,
   rBend_min_6, 
   rBend_min_5, 
   rBend_min_4, 
   rBend_min_3, 
   rBend_min_2, 
   rBend_min_1, 
   rBend_0, 
   rBend_plus_1, 
   rBend_plus_2, 
   rBend_plus_3, 
   rBend_plus_4, 
   rBend_plus_5, 
   rBend_plus_6, 
   rBend_plus_7, 
   rVTH1, 
   rVTH2);
    constant regs_page2_default : array_reg_page2 := (others => rPage2);
    --=======================--


end cbc3_emulator_package;
   
package body cbc3_emulator_package is
end cbc3_emulator_package;