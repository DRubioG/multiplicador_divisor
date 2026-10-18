
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity tb_multiplier is
end;

architecture bench of tb_multiplier is
  -- Clock period
  constant C_CLK_PERIOD : time := 5 ns;
  -- Generics
  constant G_WA : integer := 9;
  constant G_WB : integer := 2;
  -- Ports
  signal CLK_I    : std_logic := '0';
  signal RST_N_I  : std_logic;
  signal EN_I     : std_logic;
  signal START_I  : std_logic;
  signal FINISH_O : std_logic;
  signal A_I      : std_logic_vector(G_WA - 1 downto 0);
  signal B_I      : std_logic_vector(G_WB - 1 downto 0);
  signal Y_O      : std_logic_vector(G_WA + G_WB - 1 downto 0);
begin

  multiplier_inst : entity work.multiplier
    generic map(
      G_WA => G_WA,
      G_WB => G_WB
    )
    port map
    (
      CLK_I    => CLK_I,
      RST_N_I  => RST_N_I,
      EN_I     => EN_I,
      START_I  => START_I,
      FINISH_O => FINISH_O,
      A_I      => A_I,
      B_I      => B_I,
      Y_O      => Y_O
    );
  CLK_I   <= not CLK_I after C_CLK_PERIOD/2;
  RST_N_I <= '0', '1' after 50 ns;
  EN_I    <= '1';

  process begin
    START_I <= '0';
    wait for 100 ns;
    START_I  <= '1';
    wait for C_CLK_PERIOD;
    START_I <= '0';
    wait for 100 ns;
    START_I  <= '1';
    wait for C_CLK_PERIOD;
    START_I <= '0';
    wait for 100 ns;
    START_I  <= '1';
    wait for C_CLK_PERIOD;
    START_I <= '0';
    wait ;
  end process;


  A_I <= std_logic_vector(to_unsigned(24, G_WA));
  B_I <= std_logic_vector(to_unsigned(3, G_WB));


  
end;