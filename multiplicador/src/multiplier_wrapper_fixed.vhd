library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier_wrapper_fixed is
  generic (
    --! Valor entero del dato A.
    G_WA_INT : integer range 1 to integer'right := 1;
    --! Valor decimal del dato A.
    G_WA_DEC : integer range 0 to integer'right := 7;
    --! Valor entero del dato B.
    G_WB_INT : integer range 1 to integer'right := 1;
    --! Valor decimal del dato B.
    G_WB_DEC : integer range 0 to integer'right := 7;
    --! Este genérico define el tipo de multiplicador que se aplica.
    --! Tiene dos opciones:
    --! - "UNSIGNED"
    --! - "SIGNED"
    G_TYPE : string := "SIGNED"
  );
  port (
    --! Reloj del módulo.
    CLK_I : in std_logic;
    --! Reset del módulo. Activo a nivel bajo.
    RST_N_I : in std_logic;
    --! Habilitación del módulo. Activo a nivel alto.
    EN_I : in std_logic;

    -- Control
    --! Puerto de arranque de la multiplicación. Activo a nivel alto.
    START_I : in std_logic;
    --! Puerto de finalización de la multiplicación. Activo a nivel alto.
    FINISH_O : out std_logic;

    -- Entradas
    --! Puerto A de multiplicación.
    A_I : in std_logic_vector(G_WA_INT + G_WA_DEC - 1 downto 0);
    --! Puerto B de multiplicación.
    B_I : in std_logic_vector(G_WB_INT + G_WB_DEC - 1 downto 0);

    -- Salida
    --! Puerto de salida de la multiplicación.
    Y_O : out std_logic_vector(G_WA_INT + G_WB_INT + G_WA_DEC + G_WB_DEC - 1 downto 0)
  );
end entity multiplier_wrapper_fixed;

architecture rtl of multiplier_wrapper_fixed is

  --! Esta función calcula el complemento a 2 del valor introducido.
  function f_c2 (input_value : std_logic_vector) return std_logic_vector is
    --! Definición de la variable para el cálculo.
    variable complemento_2 : unsigned(input_value'range);
  begin
    --! Cálculo del complemento a 2.
    complemento_2 := unsigned(not(input_value)) + 1;
    --! Retorno del valor del complemento a 2.
    return std_logic_vector(complemento_2);
  end function;

  --! Valor total del número de bits.
  constant G_TOTAL : integer := G_WA_INT + G_WA_DEC + G_WB_INT + G_WB_DEC;
  --! Valor entero de todos los datos.
  constant G_INT : integer := G_WA_INT + G_WB_INT;
  --! Valor decimal de todos los datos.
  constant G_DEC : integer := G_WA_DEC + G_WB_DEC;
  --! Señal de salida de la multiplicación.

  --! Señal encapsulada de entrada A.
  signal s_A : std_logic_vector(A_I'range);
  --! Señal encapsulada de entrada B.
  signal s_B : std_logic_vector(B_I'range);
  --! Señal de encapsulada de retorno.
  signal s_y : std_logic_vector(G_TOTAL - 1 downto 0);

  --! Valor total después analizar si va con signo o sin él.
  signal s_y_total : std_logic_vector(G_TOTAL - 1 downto 0);
  --! Valor entero de salida.
  signal s_y_int : std_logic_vector(G_INT - 1 downto 0);
  --! Valor decimal de salida.
  signal s_y_dec : std_logic_vector(G_DEC - 1 downto 0);

begin
  --Gestión de la salida
  --! Valor de salida combinando la parte entera con la parte decimal.
  SALIDA : Y_O <= s_y_int & s_y_dec;

  --! Valor entero recortado.
  INT : s_y_int <= s_y_total(G_TOTAL - 1 downto G_TOTAL - G_INT);
  --! Valor decimal recortado
  DEC : s_y_dec <= s_y_total(G_TOTAL - G_INT - 1 downto 0);

  --! Este generate ejecuta el multiplicador en modo normal. Esto es debido
  --! a que esta parte del generate solo encapsula las señales de entrada
  --! y salida del multiplicador.
  UNSIGNED_PROCESS : if G_TYPE = "UNSIGNED" generate
    --! Esto cambia el nombre al puerto de entrada A.
    A_WRAPPER : s_A <= A_I;
    --! Esto cambia el nombre al puerto de entrada B.
    B_WRAPPER : s_B <= B_I;
    --! Esto asigna la salida del multiplicador al puerto.
    Y_WRAPPER : s_y_total <= s_y;

    --! Este generate hace que el multiplicador pueda operar con valor 
    --! con signo.
  elsif G_TYPE = "SIGNED" generate
    begin
      --! Esto cambia el valor del puerto A. Si el valor de A es negativo
      --! lo transforma en positivo para poder operar.
      A_WRAPPER : s_A <= f_c2(A_I) when A_I(A_I'left - 1) = '1' else
      A_I;

      --! Esto cambia el valor del puerto B. Si el valor de B es negativo
      --! lo transforma en positivo para poder operar.
      B_WRAPPER : s_B <= f_c2(B_I) when B_I(B_I'left - 1) = '1' else
      B_I;

      --! En caso de que uno de los operandos es negativo convierte el valor de retorno a
      --! negativo. Si los dos son negativos se mantiene el valor de salida del multiplicador.
      Y_WRAPPER : s_y_total <= f_c2(s_y) when A_I(A_I'left - 1) xor B_I(B_I'left - 1) else
      s_y;

    end generate;

    --! Esta es la instanciación del multiplicador. 
    --! Los operandos de entrada son siempre positivos.
    multiplier_inst : entity work.multiplier
      generic map(
        G_WA => A_I'length,
        G_WB => B_I'length
      )
      port map
      (
        CLK_I    => CLK_I,
        RST_N_I  => RST_N_I,
        EN_I     => EN_I,
        START_I  => START_I,
        FINISH_O => FINISH_O,
        A_I      => s_A,
        B_I      => s_B,
        Y_O      => s_y
      );

  end architecture;