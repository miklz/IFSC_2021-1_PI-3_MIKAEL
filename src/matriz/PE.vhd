library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity PE is
  generic (
    N : natural := 32
  );

  port (
    clock         : in  std_logic;
    reset         : in  std_logic;
    left_input    : in  signed(N-1 downto 0);
    right_input   : in  signed(N-1 downto 0);
    left_output   : out signed(N-1 downto 0);
    right_output  : out signed(N-1 downto 0);
    result        : out signed(N-1 downto 0)
  );
end entity PE;


architecture behave of PE is
  signal memory : signed(N-1 downto 0);
  begin

    processing_element : process(reset, clock)

      variable temp    : signed(2*N-1 downto 0);

      begin

        result <= memory;

        if (reset = '1') then
          memory <= (others => '0');
          left_output <= (others => '0');
          right_output <= (others => '0');
        elsif (rising_edge(clock)) then
          temp := left_input*right_input;
          memory <= memory + temp(N-1 downto 0);
          left_output <= right_input;
          right_output <= left_input;
        end if;

    end process processing_element;

  end architecture behave;
