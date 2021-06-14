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
  signal matrix_a, matrix_b, matrix_c : matrix_array(0 to matrix_size-1, 0 to matrix_size-1);

begin

  mesh_array : entity work.mesh_array(behave)
  generic map(
    N => matrix_size
  )
  port map (
    clk, rst, matrix_a, matrix_b, matrix_c
  );

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

    wait for 20*T;
    wait;
  end process matrix_mult;

end architecture;
