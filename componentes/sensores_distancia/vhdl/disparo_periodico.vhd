library ieee;
use ieee.std_logic_1164.all;

-- Solicitud de un ciclo cada 100 ms; primera solicitud tras ese intervalo.
-- Para cuatro sensores se sustituira por un coordinador de turnos.
entity disparo_periodico is
    generic (CICLOS_PERIODO : positive := 5000000);
    port (clk : in std_logic; inicio : out std_logic := '0');
end entity;

architecture rtl of disparo_periodico is
    signal cuenta : natural range 0 to CICLOS_PERIODO - 1 := 0;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            inicio <= '0';
            if cuenta = CICLOS_PERIODO - 1 then
                cuenta <= 0;
                inicio <= '1';
            else
                cuenta <= cuenta + 1;
            end if;
        end if;
    end process;
end architecture;
