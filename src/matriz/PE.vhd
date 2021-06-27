library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.array_types.all;

entity PE is

  port (
    clock         : in  std_logic;
    reset         : in  std_logic;
    left_input    : in  number;
    right_input   : in  number;
    left_output   : out number;
    right_output  : out number;
    result        : out number
  );
end entity PE;


architecture behave of PE is
  signal memory : number;
  begin

    processing_element : process(reset, clock)

      variable temp    : signed(2*number'length-1 downto 0);

      begin

        if (reset = '1') then
          memory <= (others => '0');
          left_output <= (others => '0');
          right_output <= (others => '0');
        elsif (rising_edge(clock)) then
          temp := left_input*right_input;
          memory <= memory + temp(number'length-1 downto 0);
          left_output <= right_input;
          right_output <= left_input;
        end if;

    end process processing_element;

    result <= memory;

  end architecture behave;
