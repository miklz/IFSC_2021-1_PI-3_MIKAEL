library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.array_types.all;

entity matrix_mult_control is
    generic (
        N_dim  : natural :=  5;
        N_bits : natural :=  32
    );

    port (
        clock                   :   in  std_logic;
        reset                   :   in  std_logic;
        avs_beginburst          :   in  std_logic;
        avs_burstcount          :   in  std_logic_vector(10 downto 0);
        avs_write               :   in  std_logic;
        avs_writedata           :   in  std_logic_vector(N_bits - 1 downto 0);
        avs_waitrequest         :   out std_logic;
        avs_read                :   in  std_logic;
        avs_readdata            :   out std_logic_vector(N_bits - 1 downto 0);
        avs_readdatavalid       :   out std_logic
    );
end entity matrix_mult_control;

architecture behave of matrix_mult_control is
    
    type receive_state is (START_RCV, LOAD);
    type send_state    is (START_SND, SEND);

    signal state_rcv    :   receive_state;
    signal state_snd    :   send_state;

    signal double_buffer_matrix_row :   vector_of_numbers(0 to 4*N_dim - 1) := (others => (others => 'Z'));
    signal matrix_a_column          :   vector_of_numbers(0 to N_dim - 1);
    signal matrix_b_row             :   vector_of_numbers(0 to N_dim - 1);
    signal matrix_c                 :   vector_of_numbers(0 to N_dim*N_dim - 1);
    signal switch_buffer, ready, clk_mult, data_available   :   std_logic;

    begin

        receive_data   :   process(clock, reset, avs_write)
            variable    index       :   natural :=  0;
            variable    burst_count :   unsigned(10 downto 0);
        begin

            if (reset = '1') then
                index := 0;
                switch_buffer <= '0';
                avs_waitrequest <= '0';
                data_available <= '0';
                state_rcv <= START_RCV;
                double_buffer_matrix_row <= (others => (others => '0'));
            elsif (rising_edge(clock)) then
                case state_rcv is
                    when START_RCV =>
                        state_rcv <= START_RCV;
                        if (avs_beginburst = '1') then
                            -- At the start of burst save how many bytes
                            -- We're going to receive
                            burst_count := unsigned(avs_burstcount);
                        end if;

                        if (avs_write = '1') then
                            state_rcv <= LOAD;
                            -- Hold data for one clock cycle
                            avs_waitrequest <= '1';
                        end if;
                    
                    when LOAD =>
                        state_rcv <= LOAD;
                        -- Ready to receive burst
                        avs_waitrequest <= '0';

                        double_buffer_matrix_row(index) <= signed(avs_writedata);

                        -- In case data is not valid wait
                        if (avs_write = '0') then
                            state_rcv <= START_RCV;
                        else
                            index := index + 1;
                            burst_count := burst_count - 1;

                            if (burst_count = 0) then
                                state_rcv <= START_RCV;
                                -- Inform that there're data available in buffer
                                data_available <= '1';
                            end if;
                        end if;

                        -- Double buffer control
                        if (index > 4*N_dim-1) then
                            index := 0;
                        end if;
                    end case;
            end if;

        end process receive_data;

        send_data   :   process(clock, reset, avs_read)
            variable    index   :   natural :=  0;
        begin

            if (reset = '1') then
                index := 0;
                avs_readdatavalid <= '0';
                avs_readdata <= (others => '0');
                matrix_c <= (others => (others => '0'));
            elsif (rising_edge(clock)) then
                if (avs_read = '1') then
                    if (ready = '0') then
                        avs_readdatavalid <= '0';
                    else
                        index := index + 1;
                        avs_readdatavalid <= '1';
                    end if;
                    avs_readdata <= std_logic_vector(matrix_c(index));
                else
                    avs_readdata <= (others => '0');
                end if;
            end if;

            if (index >= N_dim*N_dim - 1) then
                index := 0;
            end if;

        end process send_data;

        matrix_clock    :   process(clock, reset)
            variable index      :   natural := 0;
        begin

            if (reset = '1') then
                index := 0;
                clk_mult <= '0';
            elsif(rising_edge(clock)) then
                index := index + 1;
                if (data_available = '1') then
                    if (index >= 2*N_dim-1) then
                        index := 0;
                        clk_mult <= not clk_mult;
                    end if;

                    -- FIX ME
                    if (index <= 2*N_dim) then
                        switch_buffer <= '0';
                    else
                        switch_buffer <= '1';
                    end if;
                end if;
            end if;

        end process matrix_clock;

        mult_matrix :   entity  work.mesh_array(behave)
        generic map(
            N => N_dim,
            M => N_dim
          )
        port map (
            clock => clk_mult, reset => reset, matrix_a => matrix_a_column,
            matrix_b => matrix_b_row, matrix_c => matrix_c, ready => ready
        );

        matrix_a_column <=
            double_buffer_matrix_row(0 to N_dim-1)          when (switch_buffer = '0') else 
            double_buffer_matrix_row(2*N_dim to 3*N_dim-1)  when (switch_buffer = '1') else
            (others => (others => '0'));
        matrix_b_row <=
            double_buffer_matrix_row(N_dim to 2*N_dim-1)    when (switch_buffer = '0') else 
            double_buffer_matrix_row(3*N_dim to 4*N_dim-1)  when (switch_buffer = '1') else
            (others => (others => '0'));

end architecture behave;