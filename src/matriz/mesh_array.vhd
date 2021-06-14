library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.array_types.all;

entity mesh_array is
  generic (
    N : natural := 5
  );

  port (
    clock     : in  std_logic;
    reset     : in  std_logic;
    matrix_a  : in  matrix_array(0 to N-1, 0 to N-1);
    matrix_b  : in  matrix_array(0 to N-1, 0 to N-1);
    matrix_c  : out matrix_array(0 to N-1, 0 to N-1)
  );

end entity mesh_array;

architecture behave of mesh_array is

  signal connections :  matrix_array(0 to N, 0 to 2*N-1);

  begin

    matrix_rows : for i in 0 to N-1 generate
      matrix_columns : for j in 0 to N-1 generate

        left_bord_condition : if (j = 0) generate
            single_Element : entity work.PE(behave)
            port map (
              clock         => clock,
              reset         => reset,
              left_input    => connections(i, 2*j),
              right_input   => connections(i, 2*j+1),
              left_output   => connections(i+1, 2*j),
              right_output  => connections(i+1, 2*(j+1)),
              result        => matrix_c(i, j)
            );
        end generate left_bord_condition;

        right_bord_condition : if (j = N-1) generate
            single_Element : entity work.PE(behave)
            port map (
              clock         => clock,
              reset         => reset,
              left_input    => connections(i, 2*j),
              right_input   => connections(i, 2*j+1),
              left_output   => connections(i+1, 2*j-1),
              right_output  => connections(i+1, 2*j+1),
              result        => matrix_c(i, j)
            );
        end generate right_bord_condition;

        general_condition : if ((j > 0) and (j < N-1)) generate
            single_Element : entity work.PE(behave)
            port map (
              clock         => clock,
              reset         => reset,
              left_input    => connections(i, 2*j),
              right_input   => connections(i, 2*j+1),
              left_output   => connections(i+1, 2*j-1),
              right_output  => connections(i+1, 2*(j+1)),
              result        => matrix_c(i, j)
            );
          end generate general_condition;

      end generate matrix_columns;
    end generate matrix_rows;

    matrix_multiply : process(reset, clock)
      variable index : natural;
    begin

      if (reset = '1') then
        index := 0;
      elsif (rising_edge(clock)) then
        for j in 0 to N-1 loop
          if (j mod 2 = 0) then
            connections(0, 2*j) <= matrix_b(index, j);
            connections(0, 2*j + 1) <= matrix_a(j, index);
          else
            connections(0, 2*j) <= matrix_a(j, index);
            connections(0, 2*j + 1) <= matrix_b(index, j);
          end if;
        end loop;

        index := index + 1;
        if index >= N then
          index := 0;
        end if;

      end if;

    end process matrix_multiply;

end architecture behave;
