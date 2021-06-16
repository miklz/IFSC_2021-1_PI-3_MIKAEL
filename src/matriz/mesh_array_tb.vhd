library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.array_types.all;

entity mesh_array_tb is
end entity;

architecture simul of mesh_array_tb is

  constant matrix_size : natural := 3;
  constant n_bits      : natural := 32;

  constant T      : time := 20 ns;
  constant delay  : time := 5 ns;

  signal clk, rst : std_logic;
  signal wires : matrix_array(0 to matrix_size, 0 to 2*matrix_size-1);
  signal matrix_a, matrix_b, matrix_c : matrix_array(0 to matrix_size-1, 0 to matrix_size-1);

begin

  --mesh_array : entity work.mesh_array(behave)
  --generic map(
  --  N => matrix_size
  --)
  --port map (
  --  clk, rst, matrix_a, matrix_b, matrix_c
  --);

  matrix_rows : for i in 0 to matrix_size-1 generate
    matrix_columns : for j in 0 to matrix_size-1 generate

      left_bord_condition : if (j = 0) generate
          single_Element : entity work.PE(behave)
          port map (
            clock         => clk,
            reset         => rst,
            left_input    => wires(i, 2*j),
            right_input   => wires(i, 2*j+1),
            left_output   => wires(i+1, 2*j),
            right_output  => wires(i+1, 2*(j+1)),
            result        => matrix_c(i, j)
          );
      end generate left_bord_condition;

      right_bord_condition : if (j = matrix_size-1) generate
          single_Element : entity work.PE(behave)
          port map (
            clock         => clk,
            reset         => rst,
            left_input    => wires(i, 2*j),
            right_input   => wires(i, 2*j+1),
            left_output   => wires(i+1, 2*j-1),
            right_output  => wires(i+1, 2*j+1),
            result        => matrix_c(i, j)
          );
      end generate right_bord_condition;

      general_condition : if ((j > 0) and (j < matrix_size-1)) generate
          single_Element : entity work.PE(behave)
          port map (
            clock         => clk,
            reset         => rst,
            left_input    => wires(i, 2*j),
            right_input   => wires(i, 2*j+1),
            left_output   => wires(i+1, 2*j-1),
            right_output  => wires(i+1, 2*(j+1)),
            result        => matrix_c(i, j)
          );
        end generate general_condition;

    end generate matrix_columns;
  end generate matrix_rows;

  clock : process
  begin
    clk <= '0';
    wait for T/2;
    clk <= '1';
    wait for T/2;
  end process clock;

  matrix_mult : process
  begin

    rst <= '1';
    wait for 2*T;

    for i in 0 to matrix_size-1 loop
      for j in 0 to matrix_size-1 loop
        matrix_a(i, j) <= to_signed(matrix_size*i + j, 32);
        matrix_b(i, j) <= to_signed((1 + i)*j + matrix_size, 32);
      end loop;
    end loop;

    rst <= '0';
    -- for loop não funciona
    --for i in 0 to matrix_size-1 loop
    --  for j in 0 to matrix_size-1 loop
    --    wires(0, 2*j) <= X"0000000A";--to_signed(matrix_size*i + j, 32);
    --    wires(0, 2*j+1) <= X"0000000B";--to_signed((1 + i)*j + matrix_size, 32);
    --  end loop;
    --  wait for T;
    --end loop;

    -- Passando 1 por 1 funciona
    wires(0, 0) <= X"00000000";
    wires(0, 1) <= X"00000001";
    wires(0, 2) <= X"00000002";
    wires(0, 3) <= X"00000003";
    wires(0, 4) <= X"00000004";
    wires(0, 5) <= X"00000005";
    wait for T;

    wires(0, 0) <= X"00000006";
    wires(0, 1) <= X"00000007";
    wires(0, 2) <= X"00000008";
    wires(0, 3) <= X"00000009";
    wires(0, 4) <= X"0000000A";
    wires(0, 5) <= X"0000000B";
    wait for T;

    wires(0, 0) <= X"0000000C";
    wires(0, 1) <= X"0000000D";
    wires(0, 2) <= X"0000000E";
    wires(0, 3) <= X"0000000F";
    wires(0, 4) <= X"00000010";
    wires(0, 5) <= X"00000011";
    wait for T;

    wires(0, 0) <= (others => '0');
    wires(0, 1) <= (others => '0');
    wires(0, 2) <= (others => '0');
    wires(0, 3) <= (others => '0');
    wires(0, 4) <= (others => '0');
    wires(0, 5) <= (others => '0');

    wait for 20*T;
    wait;
  end process matrix_mult;

end architecture;
