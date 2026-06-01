library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity divisor is
  generic (
    G_WA : integer := 16;
    G_WB : integer := 8
  );
  port (
    CLK_I      : in std_logic;
    RST_N_I    : in std_logic;
    EN_I       : in std_logic;
    START_I    : in std_logic;
    A_I        : in std_logic_vector(G_WA - 1 downto 0);
    B_I        : in std_logic_vector(G_WB - 1 downto 0);
    COCIENTE_O : out std_logic_vector(G_WA - 1 downto 0);
    RESTO_O    : out std_logic_vector(G_WB - 1 downto 0);
    DONE_O     : out std_logic
  );
end entity;

architecture rtl of divisor is
  signal s_dividend : unsigned(G_WA - 1 downto 0);
  signal s_divisor  : unsigned(G_WB - 1 downto 0);
  signal s_quotient : unsigned(G_WA - 1 downto 0);

  signal s_A_I        : unsigned(A_I'range);
  signal s_B_I        : UNSIGNED(B_I'range);
  signal s_COCIENTE_O : unsigned(A_I'range);
  signal s_RESTO_O    : UNSIGNED(B_I'range);
begin
  s_A_I <= unsigned(A_I);
  s_B_I <= unsigned(B_I);

  RESTO_O    <= std_logic_vector(s_RESTO_O);
  COCIENTE_O <= std_logic_vector(s_COCIENTE_O);
  process (CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_N_I = '0' then
        s_dividend <= (others => '0');
        s_divisor  <= (others => '0');
        s_quotient <= (others => '0');
        DONE_O     <= '0';
      elsif EN_I = '1' then
        if START_I = '1' then
          s_dividend <= s_A_I;
          s_divisor  <= s_B_I;
          s_quotient <= (others => '0');
          DONE_O     <= '0';
        elsif DONE_O = '0' then
          if s_dividend >= resize(s_divisor, G_WA) then
            s_dividend <= s_dividend - resize(s_divisor, G_WA);
            s_quotient <= s_quotient + 1;
          else
            s_RESTO_O    <= resize(s_dividend, G_WB);
            s_COCIENTE_O <= s_quotient;
            DONE_O       <= '1';
          end if;
        end if;
      end if;
    end if;
  end process;
end architecture;
