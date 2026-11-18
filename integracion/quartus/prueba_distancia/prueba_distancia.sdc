create_clock -name clk_50 -period 20.000 [get_ports {clk}]
derive_clock_uncertainty
# Solo la llegada asincrona a la primera etapa, no la cadena completa.
set_false_path -from [get_ports {echo}] -to [get_registers {*echo_1}]
# Salidas sin reloj receptor: sensor y displays.
set_false_path -to [get_ports {trig hex0[*] hex1[*] hex2[*]}]
