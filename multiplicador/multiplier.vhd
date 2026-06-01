--! Este módulo hace la multiplicación del operando A y B
--!
--! Y_O = A_I * B_I
--!
--! Este módulo no está hecho con un operador multiplicador(*).
--! Este módulo tarda en hacer la múltiplicación:
--!
--! Tiempo = <Número de bits del operador A\> + 1 ciclo de reloj
--! { signal: [
--!   { name: "clk",            wave: "p......" },
--!   { name: "G_WA",           wave: "x3.....", data: ["3"] },
--!   { name: "G_WB",           wave: "x3.....", data: ["2"] },
--!   { name: "A_I",            wave: "x3.....", data: ["2"] },
--!   { name: "B_I",            wave: "x3.....", data: ["15"] },
--!   { name: "START_I",        wave: "0.10...", phase: 0.5 },
--!   { name: "Y_I",            wave: "x...3.x", data: ["30", "body", "tail", "data"] },
--!   { name: "FINISH_O",       wave: "0....10", phase: 0.5 },
--!   {},
--!   { name: "State",          wave: "3.4...3", data: ["idle", "multiplication", "idle"] }
--! ]}

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity multiplier is
    generic (
--! Tamaño de la entrada A
        G_WA : integer := 5;
--! Tamaño de la entrada B
        G_WB : integer := 5
    );
    Port ( 
--! Reloj del módulo.
        CLK_I : in std_logic;
--! Reset del módulo. Activo a nivel bajo.
        RST_N_I : in std_logic;
--! Habilitación del módulo. Activo a nivel alto.
        EN_I  : in std_logic;
        
        -- Control
--! Puerto de arranque de la multiplicación. Activo a nivel alto.
        START_I : in std_logic;
--! Puerto de finalización de la multiplicación. Activo a nivel alto.
        FINISH_O : out std_logic;

        -- Entradas
--! Puerto A de multiplicación.
        A_I : in std_logic_vector(G_WA-1 downto 0);
--! Puerto B de multiplicación.
        B_I : in std_logic_vector(G_WB-1 downto 0);

        -- Salida
--! Puerto de salida de la multiplicación.
        Y_O : out std_logic_vector(G_WA+G_WB-1 downto 0)
    );
end multiplier;


architecture Behavioral of multiplier is

-- Estados de la máquina de estados.
type fsm is (
--! Estado de espera para realizar la multiplicación.
    SM_IDLE, 
--! Estado de multiplicación.
    SM_MULTIPLICATION 
);

--! Este registro lleva el estado actual de la máquina de estados.
signal re_state : fsm;

--! Registro de multiplicando y producto para hacer desplazamientos.
signal r_producto, r_multiplicando : unsigned(G_WA+G_WB-1 downto 0);

--! Registo de multiplicador que se utiliza para hacer desplazamientos.
signal r_multiplicador : unsigned(G_WA-1 downto 0);

--! Contador de bits de la multiplicación.
signal r_cont : integer range 0 to G_WA;

--! Esta señal indica la finalización de la multiplicación.
signal r_finish_multiplication : std_logic;

--! Esta constante rellena los ceros del producto para resetear el valor.
constant C_ZEROS : UNSIGNED(G_WA-1 downto 0) := (others => '0') ;


begin


--! Declaración de la máquina de estados.
FSM_declaration : process(CLK_I)
    begin
        if rising_edge(CLK_I) then
            if RST_N_I = '0' then
                re_state <= SM_IDLE;
                
            elsif EN_I = '1' then
                case re_state is
                    when SM_IDLE =>
-- Espera a que la señal de START esté a '1'.
                        if START_I = '1' then
                            re_state <= SM_MULTIPLICATION;
                        end if;
                        
                        
                    when SM_MULTIPLICATION =>
-- Espera a finalización de la multiplicación.
                        if r_finish_multiplication = '1' then
                            re_state <= SM_IDLE;
                        end if;
                        
                    when others =>
                        re_state <= SM_IDLE;
                end case;
            end if;
        end if;        
    end process;


--! Asignación del indicador de salida de la multiplicación.
FINISH_OUTPUT : FINISH_O <= r_finish_multiplication;



--! Este process tiene dos funcionalidades enlazadas:
--! - contar el número de bits para hacer las multiplicaciones.
--! - generar la señal de finalización de la multiplicación.
CONT_FINISH : process (CLK_I)
    begin
        if rising_edge(CLK_I) then
            if RST_N_I = '0' then
                r_cont <= 0;
                r_finish_multiplication <= '0';
            elsif EN_I = '1' then
                r_cont <= 0;
                r_finish_multiplication <= '0';
                if re_state = SM_MULTIPLICATION then
                    r_cont <= r_cont +1;
                    if r_cont >= G_WA-1 then
                        r_cont <= 0;
                        r_finish_multiplication <= '1';
                    end if;
                end if;

            end if;
        end if;
    end process;


--! Este process se encarga de hacer un desplazamiento a izquierdas del multiplicando.
MULTIPLICANDO_PROCESS : process (CLK_I)
    begin
        if rising_edge(CLK_I) then
            if RST_N_I = '0' then
                r_multiplicando <= (others => '0');
            elsif EN_I = '1' then
                r_multiplicando <= C_ZEROS & unsigned(B_I);
                if re_state = SM_MULTIPLICATION then
                    r_multiplicando <= r_multiplicando(G_WA+G_WB-2 downto 0) & '0';
                end if;
            end if;
        end if;
    end process;


--! Este process se encarga de hacer un desplazamiento a derechas del multiplicador.
MULTIPLICADOR_PROCESS : process (CLK_I)
    begin
        if rising_edge(CLK_I) then
            if RST_N_I = '0' then
                r_multiplicador <= (others => '0');
            elsif EN_I = '1' then
                r_multiplicador <= unsigned(A_I);
                if re_state = SM_MULTIPLICATION then
                    r_multiplicador <= '0' & r_multiplicador(G_WA-1 downto 1);
                end if;
            end if;
        end if;
    end process;



--! Este process se encarga de generar el producto de la multiplicación.
--! Este producto se genera cada vez que el bit LSB del multiplicador (que se
--! desplaza a izquierdas) es '1', se suma el valor actual del multiplicador y el
--! multiplicando.
PRODUCTO_PROCESS : process (CLK_I)
    begin
        if rising_edge(CLK_I) then
            if RST_N_I = '0' then
                r_producto <= (others => '0');
            elsif EN_I = '1' then
                if re_state = SM_IDLE then
                    r_producto <= (others => '0');
                elsif re_state = SM_MULTIPLICATION then
                    if r_multiplicador(0) = '1' then
                        r_producto <= r_producto+r_multiplicando;
                    end if;
                end if;
            end if;
        end if;
    end process;



--! Asignación del valor de salida como el producto.
Y_OUTPUT : Y_O <= std_logic_vector(r_producto);

    

end architecture;
