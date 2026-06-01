--! DIVIDENDO_I / DIVISOR_I = COCIENTE_O @ RESTO_O
--!

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity divisor is
  generic (
    --! Tamaño de datos de dividendo
    G_TAM_DIVIDENDO : integer := 16;
    --! Tamaño de datos de divisor
    G_TAM_DIVISOR : integer := 8
  );
  port (
    --! Reloj del módulo
    CLK_I : in std_logic;
    --! Reset del módulo. Activo a nivel bajo.
    RST_N_I : in std_logic;
    --! Habilitación del módulo. Activo a nivel alto.
    EN_I : in std_logic;
    --! Señal de arranque de la división. Activa a nivel alto.
    START_I : in std_logic;
    --! Dividendo
    DIVIDENDO_I : in std_logic_vector(G_TAM_DIVIDENDO - 1 downto 0);
    --! Divisor
    DIVISOR_I : in std_logic_vector(G_TAM_DIVISOR - 1 downto 0);
    --! Cociente
    COCIENTE_O : out std_logic_vector(G_TAM_DIVIDENDO - 1 downto 0);
    --! Resto
    RESTO_O : out std_logic_vector(G_TAM_DIVISOR - 1 downto 0);
    --! Señal de finalización
    DONE_O : out std_logic
  );
end entity;

architecture rtl of divisor is
  --! Valor del dividendo 
  signal s_dividendo : unsigned(G_TAM_DIVIDENDO - 1 downto 0);
  --! Valor del divisor
  signal s_divisor : unsigned(G_TAM_DIVISOR - 1 downto 0);
  --! Valor del cociente
  signal s_cociente : unsigned(G_TAM_DIVIDENDO - 1 downto 0);
  --! Señal de entrada del dividendo
  signal s_DIVIDENDO_I : unsigned(DIVIDENDO_I'range);
  --! Señal de entrada del divisor
  signal s_DIVISOR_I : UNSIGNED(DIVISOR_I'range);
  --! Señal de salida del cociente
  signal s_COCIENTE_O : unsigned(DIVIDENDO_I'range);
  --! Señal de salida del resto
  signal s_RESTO_O : UNSIGNED(DIVISOR_I'range);
begin
  --! Asignación dividendo
  ASIGNACION_DIVIDENDO : s_DIVIDENDO_I <= unsigned(DIVIDENDO_I);
  --! Asignación del divisor
  ASIGNACION_DIVISOR : s_DIVISOR_I <= unsigned(DIVISOR_I);
  --! Asignación del resto
  ASIGNACION_RESTO : RESTO_O <= std_logic_vector(s_RESTO_O);
  --! Asignación del cociente
  ASIGNACION_COCIENTE : COCIENTE_O <= std_logic_vector(s_COCIENTE_O);
  --! Division
  DIVISION_PROCESS : process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_N_I = '0' then
        s_dividendo  <= (others => '0');
        s_divisor    <= (others => '0');
        s_cociente   <= (others => '0');
        s_COCIENTE_O <= (others => '0');
        s_RESTO_O    <= (others => '0');
        DONE_O       <= '0';
      elsif EN_I = '1' then
        if START_I = '1' then
          s_dividendo <= s_DIVIDENDO_I;
          s_divisor   <= s_DIVISOR_I;
          s_cociente  <= (others => '0');
          DONE_O      <= '0';
        elsif DONE_O = '0' then
          if s_dividendo >= resize(s_divisor, G_TAM_DIVIDENDO) then
            s_dividendo <= s_dividendo - resize(s_divisor, G_TAM_DIVIDENDO);
            s_cociente  <= s_cociente + 1;
          else
            s_RESTO_O    <= resize(s_dividendo, G_TAM_DIVISOR);
            s_COCIENTE_O <= s_cociente;
            DONE_O       <= '1';
          end if;
        end if;
      end if;
    end if;
  end process;
end architecture;
