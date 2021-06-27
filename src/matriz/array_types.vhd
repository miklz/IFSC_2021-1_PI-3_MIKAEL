library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

package array_types is

  constant N_BITS : natural := 32;

  subtype number is signed(N_BITS-1 downto 0);
  type vector_of_numbers is array (natural range <>) of number;

  -- Map vector as a matrix nxm and return the element in the (n,m) position
  function vector_element(vector: vector_of_numbers; columns, i, j : natural)
    return number;

end package array_types;

package body array_types is

  function vector_element(vector: vector_of_numbers; columns, i, j : natural)
    return number is

      begin

        return vector(i*columns+j);
      end function vector_element;

end package body array_types;
