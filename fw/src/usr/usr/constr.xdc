
#set_property ASYNC_REG true [get_cells sys/eth/phy/transceiver_inst/gtwizard_inst/gt0_rx_recclk_mon_i/HW_circuitry.reset_logic_ref_meta_reg]
#set_property ASYNC_REG true [get_cells sys/eth/phy/transceiver_inst/gtwizard_inst/gt0_rx_recclk_mon_i/HW_circuitry.reset_logic_ref_sync_reg]
#set_property ASYNC_REG true [get_cells sys/eth/phy/transceiver_inst/gtwizard_inst/gt0_rx_recclk_mon_i/HW_circuitry.ref_clk_msb_meta_reg]
#set_property ASYNC_REG true [get_cells {sys/eth/phy/transceiver_inst/gtwizard_inst/gt0_rx_recclk_mon_i/HW_circuitry.ref_clk_msb_reg[1]}]
#create_clock -period 8.000 -name osc125_a_p -waveform {0.000 4.000} [get_ports osc125_a_p]
#create_clock -period 8.000 -name osc125_b_p -waveform {0.000 4.000} [get_ports osc125_b_p]
#]

create_clock -period 25.000 -name clk_out40 -waveform {0.000 12.500} [get_nets usr/mmcm_inst/clk_out40]
create_clock -period 3.125 -name clk_out320 -waveform {0.000 1.563} [get_nets usr/mmcm_inst/clk_out320]
