library ieee;
use std.textio.all;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.array_types.all;

entity mesh_array_tb is
end entity;

architecture simul of mesh_array_tb is

  constant matrix_size : natural := 5;
  constant n_bits      : natural := 32;

  constant matrix_a_file  : string := "../values_a.txt";
  constant matrix_b_file  : string := "../values_b.txt";
  constant multip_result  : string := "../product.txt";


  type integer_vector is array (0 to matrix_size*matrix_size - 1) of integer;
  --type INTEGER_VECTOR_FILE is file of integer_vector;
  file flptr_a, flptr_b, flptr_r : text;--INTEGER_VECTOR_FILE;

  constant T      : time := 20 ns;
  constant delay  : time := 5 ns;

  signal clk, rst, ready : std_logic;
  signal wires : vector_of_numbers(0 to 2*(matrix_size+1)*matrix_size-1) := (others => (others => 'Z'));
  signal matrix_a, matrix_b : vector_of_numbers(0 to matrix_size - 1) := (others => (others => 'Z'));
  signal matrix_c : vector_of_numbers(0 to matrix_size*matrix_size-1) := (others => (others => 'Z'));

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

begin

  mesh_array : entity work.mesh_array(behave)
  generic map(
    N => matrix_size,
    M => matrix_size
  )
  port map (
    clk, rst, matrix_a, matrix_b, matrix_c, ready
  );

  clock : process
  begin
    clk <= '0';
    wait for T/2;
    clk <= '1';
    wait for T/2;
  end process clock;

  matrix_mult : process
    variable line_a, line_b, line_r : line;
    variable input_a, input_b       : integer_vector;
    variable file_status_a, file_status_b, file_status_r  : FILE_OPEN_STATUS;
  begin

    rst <= '1';
    matrix_a <= (others => (others => '0'));
    matrix_b <= (others => (others => '0'));
    wait for 2*T;

    file_open(file_status_a, flptr_a, matrix_a_file, read_mode);
    file_open(file_status_b, flptr_b, matrix_b_file, read_mode);
    file_open(file_status_r, flptr_r, multip_result, write_mode);

    assert ((file_status_a = open_ok) and (file_status_b = open_ok) and
    (file_status_r = open_ok)) report "FILE ERROR" severity error;

    while(not endfile(flptr_a)) loop
      readline(flptr_a, line_a);
      readline(flptr_b, line_b);

      rst <= '0';
      wait for T;

      load_array(line_a, input_a);
      load_array(line_b, input_b);

      for index in 0 to matrix_size - 1 loop
        read_column_from_line(input_a, matrix_a, index);
        read_row_from_line(input_b, matrix_b, index);

        wait for T;
      end loop;

      matrix_a <= (others => (others => '0'));
      matrix_b <= (others => (others => '0'));

      wait for matrix_size*T;
      
      write_array_to_line(line_r, matrix_c);
      writeline(flptr_r, line_r);

      rst <= '1';
      wait for T;
    end loop;

    file_close(flptr_a);
    file_close(flptr_b);
    file_close(flptr_r);
    wait;
  end process matrix_mult;

end architecture;
