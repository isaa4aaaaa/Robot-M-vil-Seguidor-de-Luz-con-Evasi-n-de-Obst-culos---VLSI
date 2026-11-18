library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- HEX0: unidades, HEX1: decenas, HEX2: centenas. Segmentos activos en bajo.
-- Bit 7: punto decimal apagado. Bits 6..0: g,f,e,d,c,b,a.
entity distancia_displays is
    port (
        distancia_cm : in std_logic_vector(8 downto 0);
        valido : in std_logic;
        hex0, hex1, hex2 : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of distancia_displays is
    function digito(n : natural) return std_logic_vector is
    begin
        case n is
            when 0 => return "11000000";
            when 1 => return "11111001";
            when 2 => return "10100100";
            when 3 => return "10110000";
            when 4 => return "10011001";
            when 5 => return "10010010";
            when 6 => return "10000010";
            when 7 => return "11111000";
            when 8 => return "10000000";
            when 9 => return "10010000";
            when others => return "10111111";
        end case;
    end function;
begin
    process(distancia_cm, valido)
        variable cm : natural range 0 to 511;
    begin
        hex0 <= "10111111";
        hex1 <= "10111111";
        hex2 <= "10111111";
        if valido = '1' then
            cm := to_integer(unsigned(distancia_cm));
            if cm >= 2 and cm <= 400 then
                hex0 <= digito(cm mod 10);
                hex1 <= digito((cm / 10) mod 10);
                hex2 <= digito(cm / 100);
            end if;
        end if;
    end process;
end architecture;
