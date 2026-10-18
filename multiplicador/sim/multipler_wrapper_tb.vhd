
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier_wraper_tb is
end;

architecture bench of multiplier_wraper_tb is
  -- Clock period
  constant clk_period : time := 5 ns;
  -- Generics
  constant G_WA : integer := 8;
  constant G_WB : integer := 8;
  -- Ports
  signal CLK_I    : std_logic := '0';
  signal RST_N_I  : std_logic;
  signal EN_I     : std_logic;
  signal START_I  : std_logic;
  signal FINISH_O : std_logic;
  -- signal A_I      : std_logic_vector(G_WA - 1 downto 0);
  -- signal B_I      : std_logic_vector(G_WB - 1 downto 0);
  signal Y_O      : std_logic_vector(G_WA + G_WB - 1 downto 0);
  signal data     : std_logic_vector(G_WA - 1 downto 0);
begin

  multiplier_inst : entity work.multiplier_wrapper
    generic map(
      G_WA => G_WA,
      G_WB => G_WB,
      G_TYPE => "SIGNED"
    )
    port map
    (
      CLK_I    => CLK_I,
      RST_N_I  => RST_N_I,
      EN_I     => EN_I,
      START_I  => START_I,
      FINISH_O => FINISH_O,
      A_I      => "11111110",
      B_I      => "00001010",
      Y_O      => Y_O
    );
  CLK_I   <= not CLK_I after clk_period/2;
  RST_N_I <= '0', '1' after 50 ns;
  EN_I    <= '1';

  process begin
    START_I <= '0';
    wait for 100 ns;
    START_I <= '1';
    wait for clk_period;
    START_I <= '0';
    wait;
  end process;
  data <= Y_O(G_WA + G_WB - 1 downto G_WB); --std_logic_vector(unsigned(not(Y_O (G_WA + G_WB - 1 downto G_WB)))+1);

end;