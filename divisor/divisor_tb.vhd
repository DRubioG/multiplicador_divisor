
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity divisor_tb is
end;

architecture bench of divisor_tb is
  -- Clock period
  constant clk_period : time := 5 ns;
  -- Generics
  -- Ports
  signal CLK_I             : std_logic := '0';
  constant G_TAM_DIVIDENDO : integer   := 32;
  constant G_TAM_DIVISOR   : integer   := 8;
  signal START_I           : std_logic;
  signal DIVIDENDO_I       : std_logic_vector(G_TAM_DIVIDENDO - 1 downto 0);
  signal DIVISOR_I         : std_logic_vector(G_TAM_DIVISOR - 1 downto 0);
  signal COCIENTE_O        : std_logic_vector(G_TAM_DIVIDENDO - 1 downto 0);
  signal RESTO_O           : std_logic_vector(G_TAM_DIVISOR - 1 downto 0);
  signal DONE_O            : std_logic;
begin

  divisor_inst : entity work.divisor
    generic map(
      G_TAM_DIVIDENDO => G_TAM_DIVIDENDO,
      G_TAM_DIVISOR   => G_TAM_DIVISOR
    )
    port map
    (
      CLK_I       => CLK_I,
      RST_N_I     => '1',
      EN_I        => '1',
      START_I     => START_I,
      DIVIDENDO_I => DIVIDENDO_I,
      DIVISOR_I   => DIVISOR_I,
      COCIENTE_O  => COCIENTE_O,
      RESTO_O     => RESTO_O,
      DONE_O      => DONE_O
    );
  CLK_I <= not CLK_I after clk_period/2;

  process begin
    START_I <= '1';
    wait for 10 ns;
    START_I <= '0';
    wait until DONE_O = '1';
    wait for 350 ns;
    report "Terminamos primera parte";
    START_I <= '1';
    wait for 10 ns;
    START_I <= '0';
    wait until DONE_O = '1';
    wait for 350 ns;
    report "FIN" severity FAILURE;
  end process;

  DIVIDENDO_I <= x"00000007", x"00500000" after 30 ns;
  DIVISOR_I   <= x"0a";

end;