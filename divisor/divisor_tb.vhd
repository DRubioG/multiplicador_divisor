
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
  signal clk : std_logic:='0';
  constant NA : integer := 16;
  constant NB : integer := 8;
  
  
  signal start : std_logic;
  signal a : std_logic_vector(NA-1 downto 0);
  signal b : std_logic_vector(NB-1 downto 0);
  signal q : std_logic_vector(NA-1 downto 0);
  signal r : std_logic_vector(NB-1 downto 0);
  signal DONE : std_logic;
begin

  divisor_inst : entity work.divisor
    generic map (
        G_WA => NA,
        G_WB => NB
    )
  port map (
    CLK_I => clk,
    RST_N_I => '1',
    EN_I => '1',
    START_I => start,
    A_I => a,
    B_I => b,
    COCIENTE_O => q,
    RESTO_O => r,
    DONE_O => DONE
  );
clk <= not clk after clk_period/2;

process begin
  start <= '1';
  wait for 10 ns;
  start <= '0';
  wait until DONE='1';
  wait for 350 ns;
  
end process;

a <= x"0007", x"5050" after 30 ns;
b <= x"02";

end;