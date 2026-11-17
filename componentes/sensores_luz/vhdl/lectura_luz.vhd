library ieee;
use ieee.std_logic_1164.all;

entity lectura_luz is
    generic (
        -- '0': D0 baja al detectar luz; '1': D0 sube al detectar luz.
        NIVEL_ACTIVO : std_logic := '0'
    );
    port (
        clk    : in  std_logic;
        ldr_d0 : in  std_logic_vector(3 downto 0);
        luz    : out std_logic_vector(3 downto 0)
    );
end entity lectura_luz;

architecture rtl of lectura_luz is
    -- Al configurar la FPGA se parte de ninguna deteccion.
    signal etapa_1 : std_logic_vector(3 downto 0) := (others => not NIVEL_ACTIVO);
    signal etapa_2 : std_logic_vector(3 downto 0) := (others => not NIVEL_ACTIVO);
begin
    -- Las entradas son independientes y externas al reloj de la FPGA.
    -- No usar etapa_1 fuera de esta cadena de sincronizacion.
    process (clk)
    begin
        if rising_edge(clk) then
            etapa_1 <= ldr_d0;
            etapa_2 <= etapa_1;
        end if;
    end process;

    -- La salida siempre usa 1 para indicar luz detectada.
    luz <= not etapa_2 when NIVEL_ACTIVO = '0' else etapa_2;
end architecture rtl;
