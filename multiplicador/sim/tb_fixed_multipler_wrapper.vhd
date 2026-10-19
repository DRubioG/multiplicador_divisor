
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fixed_multiplier_wrapper_tb is
end;

architecture bench of fixed_multiplier_wrapper_tb is
  -- Clock period
  constant clk_period : time := 5 ns;
  -- Generics
  constant G_WA_INT : integer := 5;
  constant G_WA_DEC : integer := 2;
  constant G_WB_INT : integer := 1;
  constant G_WB_DEC : integer := 3;
  -- constant G_WY_INT : integer := 6;
  -- constant G_WY_DEC : integer := 2;
  -- Ports
  signal CLK_I    : std_logic := '0';
  signal RST_N_I  : std_logic;
  signal EN_I     : std_logic;
  signal START_I  : std_logic;
  signal FINISH_O : std_logic;
  signal A_I      : std_logic_vector(G_WA_INT + G_WA_DEC - 1 downto 0);
  signal B_I      : std_logic_vector(G_WB_INT + G_WB_DEC - 1 downto 0);
  signal Y_O      : std_logic_vector(G_WA_INT + G_WB_INT + G_WA_DEC + G_WB_DEC - 1 downto 0);
begin

  fixed_multiplier_inst : entity work.multiplier_wrapper_fixed
    generic map(
      G_WA_INT => G_WA_INT,
      G_WA_DEC => G_WA_DEC,
      G_WB_INT => G_WB_INT,
      G_WB_DEC => G_WB_DEC,
      -- G_WY_INT => G_WY_INT,
      -- G_WY_DEC => G_WY_DEC,
      G_TYPE   => "SIGNED"
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
  CLK_I   <= not CLK_I after clk_period/2;
  RST_N_I <= '0', '1' after 50 ns;
  EN_I    <= '1';

  A_I <= "0001110";
  B_I <= "1110";

  process begin
    START_I <= '0';
    wait for 100 ns;
    START_I <= '1';
    wait for clk_period;
    START_I <= '0';
    wait;
  end process;

end;