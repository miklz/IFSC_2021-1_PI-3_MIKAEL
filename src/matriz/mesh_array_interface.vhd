library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.array_types.all;

entity matrix_mult_nxn is
    generic (
        N_dim   :=  5;
        N_bits  :=  32
    );

    port (
        clock               :   in  std_logic;
        reset               :   in  std_logic;
        beginbursttransfer  :   in  std_logic;
        burstcount          :   in  std_logic_vector(5 downto 0);
        write               :   in  std_logic;
        writedata           :   out std_logic_vector(N_bits - 1 downto 0);
        read                :   in  std_logic;
        readdata            :   in  std_logic_vector(N_bits - 1 downto 0)
    );
end entity matrix_mult_nxn;

architecture behave of matrix_mult_nxn is
    
    signal double_buffer_matrix_row :   vector_of_numbers(0 to 4*N_dim);
    signal matrix_output            :   vector_of_numbers(0 to N_dim);
    signal index                    :   natural;

    begin

        receive_data   :   process(clock, reset, write)

        begin

            if (reset = '1') then
                double_buffer_matrix_row <= (others => (others => '0'));
            elsif (rising_edge(clock)) then 

            end if;

        end process receive_data;

        send_data   :   process(clock, reset, read)

        begin


        end process send_data;

end architecture behave;