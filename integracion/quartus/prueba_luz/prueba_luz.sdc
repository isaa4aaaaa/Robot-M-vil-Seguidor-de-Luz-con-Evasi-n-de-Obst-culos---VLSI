create_clock -name clk_50 -period 20.000 [get_ports {clk}]
derive_clock_uncertainty
# D0 es asincrona; solo se exceptua su llegada a la primera etapa.
set_false_path -from [get_ports {ldr_d0[*]}] -to [get_registers {*etapa_1[*]}]
# Los LED no son receptores sincronizados a un reloj externo.
set_false_path -to [get_ports {luz[*]}]
