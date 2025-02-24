set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports clk_125]
create_clock -period 8.000 -name clk_125 -waveform {0.000 4.000} -add [get_ports clk_125]

set_property -dict {PACKAGE_PIN L16 IOSTANDARD TMDS_33} [get_ports tmds_tx_clk_p]
set_property -dict {PACKAGE_PIN L17 IOSTANDARD TMDS_33} [get_ports tmds_tx_clk_n]

set_property -dict {PACKAGE_PIN K17 IOSTANDARD TMDS_33} [get_ports {tmds_tx_data_p[0]}]
set_property -dict {PACKAGE_PIN K18 IOSTANDARD TMDS_33} [get_ports {tmds_tx_data_n[0]}]

set_property -dict {PACKAGE_PIN K19 IOSTANDARD TMDS_33} [get_ports {tmds_tx_data_p[1]}]
set_property -dict {PACKAGE_PIN J19 IOSTANDARD TMDS_33} [get_ports {tmds_tx_data_n[1]}]

set_property -dict {PACKAGE_PIN J18 IOSTANDARD TMDS_33} [get_ports {tmds_tx_data_p[2]}]
set_property -dict {PACKAGE_PIN H18 IOSTANDARD TMDS_33} [get_ports {tmds_tx_data_n[2]}]

set_property -dict {PACKAGE_PIN R19 IOSTANDARD LVCMOS33} [get_ports {hdmi_hpd}]