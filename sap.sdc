# Define o clock de entrada do FPGA (50 MHz, pino P11 no DE10-Lite)
create_clock -name clk_fpga -period 20.000 [get_ports {clock_fpga}]