library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

package array_types is

  constant N_BITS : natural := 32;

  type matrix_array is array (natural range <>, natural range <>) of signed(N_BITS-1 downto 0);

end package array_types;

package body array_types is

end package body array_types;
