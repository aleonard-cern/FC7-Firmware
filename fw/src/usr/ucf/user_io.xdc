#set_property package_pin am17    [get_ports osc_sata_scl]
#set_property iostandard lvcmos25 [get_ports osc_sata_scl]

#set_property package_pin am18    [get_ports osc_sata_sda]
#set_property iostandard lvcmos25 [get_ports osc_sata_sda]

set_property PACKAGE_PIN AG17 [get_ports {amc_tx_n[12]}]
set_property IOSTANDARD LVCMOS25 [get_ports {amc_tx_n[12]}]
set_property PACKAGE_PIN AK21 [get_ports {amc_tx_n[13]}]
set_property IOSTANDARD LVCMOS25 [get_ports {amc_tx_n[13]}]
set_property PACKAGE_PIN AG21 [get_ports {amc_tx_n[14]}]
set_property IOSTANDARD LVCMOS25 [get_ports {amc_tx_n[14]}]
set_property PACKAGE_PIN AH23 [get_ports {amc_tx_n[15]}]
set_property IOSTANDARD LVCMOS25 [get_ports {amc_tx_n[15]}]

set_property PACKAGE_PIN AG16 [get_ports {amc_tx_p[12]}]
set_property IOSTANDARD LVCMOS25 [get_ports {amc_tx_p[12]}]
set_property PACKAGE_PIN AJ21 [get_ports {amc_tx_p[13]}]
set_property IOSTANDARD LVCMOS25 [get_ports {amc_tx_p[13]}]
set_property PACKAGE_PIN AG20 [get_ports {amc_tx_p[14]}]
set_property IOSTANDARD LVCMOS25 [get_ports {amc_tx_p[14]}]
set_property PACKAGE_PIN AG23 [get_ports {amc_tx_p[15]}]
set_property IOSTANDARD LVCMOS25 [get_ports {amc_tx_p[15]}]

set_property PACKAGE_PIN AH18 [get_ports {k7_amc_rx_n[12]}]
set_property IOSTANDARD LVCMOS25 [get_ports {k7_amc_rx_n[12]}]
set_property PACKAGE_PIN AK22 [get_ports {k7_amc_rx_n[13]}]
set_property IOSTANDARD LVCMOS25 [get_ports {k7_amc_rx_n[13]}]
set_property PACKAGE_PIN AJ20 [get_ports {k7_amc_rx_n[14]}]
set_property IOSTANDARD LVCMOS25 [get_ports {k7_amc_rx_n[14]}]
set_property PACKAGE_PIN AH22 [get_ports {k7_amc_rx_n[15]}]
set_property IOSTANDARD LVCMOS25 [get_ports {k7_amc_rx_n[15]}]

set_property PACKAGE_PIN AH17 [get_ports {k7_amc_rx_p[12]}]
set_property IOSTANDARD LVCMOS25 [get_ports {k7_amc_rx_p[12]}]
set_property PACKAGE_PIN AJ22 [get_ports {k7_amc_rx_p[13]}]
set_property IOSTANDARD LVCMOS25 [get_ports {k7_amc_rx_p[13]}]
set_property PACKAGE_PIN AH20 [get_ports {k7_amc_rx_p[14]}]
set_property IOSTANDARD LVCMOS25 [get_ports {k7_amc_rx_p[14]}]
set_property PACKAGE_PIN AG22 [get_ports {k7_amc_rx_p[15]}]
set_property IOSTANDARD LVCMOS25 [get_ports {k7_amc_rx_p[15]}]

set_property PACKAGE_PIN AL23 [get_ports k7_fabric_amc_rx_n03]
set_property IOSTANDARD LVCMOS25 [get_ports k7_fabric_amc_rx_n03]

set_property PACKAGE_PIN AK23 [get_ports k7_fabric_amc_rx_p03]
set_property IOSTANDARD LVCMOS25 [get_ports k7_fabric_amc_rx_p03]

set_property PACKAGE_PIN AN22 [get_ports k7_fabric_amc_tx_n03]
set_property IOSTANDARD LVCMOS25 [get_ports k7_fabric_amc_tx_n03]

set_property PACKAGE_PIN AM22 [get_ports k7_fabric_amc_tx_p03]
set_property IOSTANDARD LVCMOS25 [get_ports k7_fabric_amc_tx_p03]

set_property IOSTANDARD LVDS_25 [get_ports fpga_refclkout_n]

set_property PACKAGE_PIN AL20 [get_ports fpga_refclkout_p]
set_property PACKAGE_PIN AM20 [get_ports fpga_refclkout_n]
set_property IOSTANDARD LVDS_25 [get_ports fpga_refclkout_p]



