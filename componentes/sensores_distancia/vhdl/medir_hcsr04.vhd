library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Una solicitud inicia una medida. Todos los tiempos usan el mismo reloj.
entity medir_hcsr04 is
    generic (RELOJ_HZ : positive := 50000000);
    port (
        clk          : in  std_logic;
        inicio       : in  std_logic;
        echo         : in  std_logic; -- Adaptado externamente a 3.3 V.
        trig         : out std_logic := '0';
        ocupado      : out std_logic := '0';
        listo        : out std_logic := '0'; -- Pulso al terminar, incluso con error.
        valido       : out std_logic := '0'; -- Validez del ultimo resultado.
        distancia_cm : out std_logic_vector(8 downto 0) := (others => '0')
    );
end entity;

architecture rtl of medir_hcsr04 is
    constant CICLOS_US : positive := RELOJ_HZ / 1000000;
    constant CICLOS_TRIG : positive := 10 * CICLOS_US;
    constant LIMITE : positive := 30000 * CICLOS_US;
    constant CICLOS_CM : positive := 58 * CICLOS_US;
    type estado_t is (espera, disparo, espera_echo, mide_echo, convierte);
    signal estado : estado_t := espera;
    signal echo_1, echo_2 : std_logic := '0';
    signal inicio_anterior : std_logic := '0';
    signal tiempo : natural range 0 to LIMITE := 0;
    signal ancho : natural range 0 to LIMITE := 0;
    signal resto : natural range 0 to LIMITE + CICLOS_CM / 2 := 0;
    signal centimetros : natural range 0 to 511 := 0;
begin
    assert RELOJ_HZ mod 1000000 = 0
        report "RELOJ_HZ debe ser multiplo de 1 MHz" severity failure;

    -- No usar echo ni echo_1 en la maquina de estados.
    process(clk)
    begin
        if rising_edge(clk) then
            echo_1 <= echo;
            echo_2 <= echo_1;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            inicio_anterior <= inicio;
            listo <= '0';
            case estado is
                when espera =>
                    trig <= '0';
                    ocupado <= '0';
                    if inicio = '1' and inicio_anterior = '0' then
                        if echo_2 = '1' then
                            -- No iniciar un disparo con ECHO ya atascado en alto.
                            valido <= '0';
                            distancia_cm <= (others => '0');
                            listo <= '1';
                        else
                            ocupado <= '1';
                            trig <= '1';
                            tiempo <= 0;
                            ancho <= 0;
                            estado <= disparo;
                        end if;
                    end if;
                when disparo =>
                    if tiempo = CICLOS_TRIG - 1 then
                        trig <= '0';
                        tiempo <= 0;
                        estado <= espera_echo;
                    else
                        tiempo <= tiempo + 1;
                    end if;
                when espera_echo | mide_echo =>
                    -- Limite conjunto: espera del flanco mas duracion de ECHO.
                    if tiempo = LIMITE - 1 then
                        valido <= '0';
                        distancia_cm <= (others => '0');
                        ocupado <= '0';
                        listo <= '1';
                        estado <= espera;
                    else
                        tiempo <= tiempo + 1;
                        if estado = espera_echo then
                            if echo_2 = '1' then
                                ancho <= 1;
                                estado <= mide_echo;
                            end if;
                        elsif echo_2 = '1' then
                            ancho <= ancho + 1;
                        else
                            resto <= ancho + CICLOS_CM / 2;
                            centimetros <= 0;
                            estado <= convierte;
                        end if;
                    end if;
                when convierte =>
                    -- Division por restas: una por ciclo, sin divisor combinacional.
                    -- El medio centimetro sumado a resto permite redondear.
                    if ancho < 2 * CICLOS_CM or ancho > 400 * CICLOS_CM then
                        distancia_cm <= (others => '0');
                        valido <= '0';
                        ocupado <= '0';
                        listo <= '1';
                        estado <= espera;
                    elsif resto >= CICLOS_CM then
                        resto <= resto - CICLOS_CM;
                        centimetros <= centimetros + 1;
                    else
                        distancia_cm <= std_logic_vector(to_unsigned(centimetros, 9));
                        valido <= '1';
                        ocupado <= '0';
                        listo <= '1';
                        estado <= espera;
                    end if;
            end case;
        end if;
    end process;
end architecture;
