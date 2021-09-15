library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.array_types.all;

entity matrix_mult_control is
    generic (
        N_dim   :=  5;
        N_bits  :=  32
    );

    port (
        clock                   :   in  std_logic;
        reset                   :   in  std_logic;
        avs_burstcount          :   in  std_logic_vector(10 downto 0);
        avs_write               :   in  std_logic;
        avs_writedata           :   in  std_logic_vector(N_bits - 1 downto 0);
        avs_read                :   in  std_logic;
        avs_readdata            :   out std_logic_vector(N_bits - 1 downto 0);
        avs_readdatavalid       :   out std_logic
    );
end entity matrix_mult_control;

architecture behave of matrix_mult_control is
    
    signal double_buffer_matrix_row :   vector_of_numbers(0 to 4*N_dim - 1);
    signal matrix_a_column          :   vector_of_numbers(0 to N_dim - 1);
    signal matrix_b_row             :   vector_of_numbers(0 to N_dim - 1);
    signal matrix_c                 :   vector_of_numbers(0 to N_dim*N_dim - 1);
    signal switch_buffer, ready     :   std_logic;

    begin

        receive_data   :   process(clock, reset, avs_write)
            variable    index   :   natural :=  0;
        begin

            if (reset = '1') then
                index := 0;
                switch_buffer <= '0';
                double_buffer_matrix_row <= (others => (others => '0'));
            elsif (rising_edge(clock)) then 
                if (avs_write = '1') then 
                    double_buffer_matrix_row(index) <= avs_writedata;
                    index := index + 1;
                end if;
            end if;

            if ((index = 0) and (index < N-1)) then 
                clk_mult <= '1';
                switch_buffer <= '0';
            elsif ((index >= N-1) and (index < 2*N-1)) then 
                clk_mult <= '0';
            elsif ((index >= 2*N-1) and (index < 3*N-1)) then 
                clk_mult <= '1';
                switch_buffer <= '1';
            else
                clk_mult <= '0';
            end if;

            if (index >= 4*N-1) then 
                index := 0;
            end if;

        end process receive_data;

        send_data   :   process(clock, reset, avs_read)
            variable    index   :   natural :=  0;
        begin

            if (reset = '1') then 
                index := 0;
                matrix_output <= (others => (others => '0'));
            elsif (rising_edge(clock)) then 
                if (avs_read = '1') then
                    if (ready = '0') then 
                        avs_readdatavalid <= '0';
                    else
                        index := index + 1;
                        avs_readdatavalid <= '1';
                    end if;
                    avs_readdata <= matrix_c(index);
                end if;
            end if;

        end process send_data;

        mult_matrix :   entity  work.mesh_array(behave)
        generic map(
            N => N_dim,
            M => N_dim
          );
        port map (
            clock => clk_mult, reset => reset, matrix_a => matrix_a_column,
            matrix_b => matrix_b_row, matrix_c => matrix_c, ready => ready
        );

        matrix_a_column <= 
            double_buffer_matrix_row(0 to N-1)      when ((switch_buffer = '0') and (ready='0')) else 
            double_buffer_matrix_row(2*N to 3*N-1)  when ((switch_buffer = '1') and (ready='0')) else
            (others => (others => '0'));
        matrix_b_row <= 
            double_buffer_matrix_row(N to 2*N-1)    when ((switch_buffer = '0') and (ready='0')) else 
            double_buffer_matrix_row(3*N to 4*N-1)  when ((switch_buffer = '1') and (ready='0')) else
            (others => (others => '0'));

end architecture behave;