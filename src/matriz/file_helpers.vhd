library ieee;
use std.textio.all;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.array_types.all;

package file_helpers is

  constant N_BITS : natural := 32;

  subtype number is signed(N_BITS-1 downto 0);
  type vector_of_numbers is array (natural range <>) of number;

  procedure load_array (
    variable ln             : inout line; 
    variable integer_array  : out integer_vector
    );
  
  procedure read_array_from_line (
    variable ln   : inout line; 
    signal vector : out vector_of_numbers
    );

  procedure read_row_from_line (
    variable integer_array  : inout integer_vector; 
    signal vector           : out vector_of_numbers; 
    constant index          : in natural
    );

  procedure read_column_from_line (
    variable integer_array  : inout integer_vector; 
    signal vector           : out vector_of_numbers; 
    constant index          : in natural
    );
  
  procedure write_array_to_line (
    variable ln   : inout line; 
    signal vector : vector_of_numbers
    );

end package file_helpers;

package body file_helpers is

  procedure load_array(variable ln : inout line; variable integer_array : out integer_vector) is
    
  begin

    for k in integer_array'range loop
      read(ln, integer_array(k));
    end loop;

  end procedure load_array;

  procedure read_array_from_line(variable ln : inout line; signal vector : out vector_of_numbers) is
    variable integer_array  : integer_vector;
  begin
    for k in integer_array'range loop
      read(ln, integer_array(k));
    end loop;

    for i in 0 to matrix_size-1 loop
      for j in 0 to matrix_size-1 loop
        vector(matrix_size*i + j) <= to_signed(integer_array(matrix_size*i + j), n_bits);
      end loop;
    end loop;

  end procedure read_array_from_line;

  procedure read_row_from_line(variable integer_array : inout integer_vector; 
      signal vector : out vector_of_numbers; constant index : in natural) is
  begin
    
    for j in 0 to matrix_size-1 loop
      vector(j) <= to_signed(integer_array(matrix_size*index + j), n_bits);
    end loop;

  end procedure read_row_from_line;

  procedure read_column_from_line(variable integer_array : inout integer_vector; 
      signal vector : out vector_of_numbers; constant index : in natural) is
  begin

    for i in 0 to matrix_size-1 loop
      vector(i) <= to_signed(integer_array(matrix_size*i + index), n_bits);
    end loop;

  end procedure read_column_from_line;

  procedure write_array_to_line(variable ln : inout line; signal vector : vector_of_numbers) is
      variable integer_array  : integer_vector;
  begin

    for i in 0 to matrix_size-1 loop
      for j in 0 to matrix_size-1 loop
        integer_array(matrix_size*i + j) := to_integer(vector(matrix_size*i + j));
      end loop;
    end loop;

    for k in integer_array'range loop
      write(ln, integer_array(k));
      write(ln, ' ');
    end loop;

  end procedure write_array_to_line;

end package body file_helpers;