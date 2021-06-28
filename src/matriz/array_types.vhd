library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

package array_types is

  constant N_BITS : natural := 32;

  subtype number is signed(N_BITS-1 downto 0);
  type vector_of_numbers is array (natural range <>) of number;

  -- Map elements of the mesh matrix to the standard position
  function map_row(columns, i, j : natural)
    return natural;
  function map_column(columns, i, j : natural)
    return natural;

end package array_types;

package body array_types is

  function map_row(columns, i, j : natural)
    return natural is
        variable row_pos  : natural;
      begin

        if((i+j) mod 2 = 1) then
          if (i <= j) then
            row_pos := j - i;
          else
            row_pos := i - j - 1;
          end if;
        else
          if (i + j <= columns - 1) then
            row_pos := i + j;
          else
            row_pos := 2*columns -i - j - 1;
          end if;
        end if;

        return row_pos;
      end function map_row;

  function map_column(columns, i, j : natural)
    return natural is
        variable col_pos  : natural;
      begin

        if((i+j) mod 2 = 1) then
          if (i + j <= columns - 1) then
            col_pos := i + j;
          else
            col_pos := 2*columns -i - j - 1;
          end if;
        else
          if (i <= j) then
            col_pos := j - i;
          else
            col_pos := i - j - 1;
          end if;
        end if;

        return col_pos;
      end function map_column;

end package body array_types;
