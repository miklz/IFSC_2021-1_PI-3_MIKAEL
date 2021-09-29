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
    
    type avalon_state is (START, LOAD, SEND);

    signal state_ctrl   :   avalon_state;

    signal double_buffer_matrix_row :   vector_of_numbers(0 to 4*N_dim - 1) := (others => (others => 'Z'));
    signal matrix_a_column          :   vector_of_numbers(0 to N_dim - 1)   := (others => (others => 'Z'));
    signal matrix_b_row             :   vector_of_numbers(0 to N_dim - 1)   := (others => (others => 'Z'));
    signal matrix_c                 :   vector_of_numbers(0 to N_dim*N_dim - 1) := (others => (others => 'Z'));
    signal ready, clk_mtx, rst_mtx  :   std_logic;
    signal switch_buffer, data_available  :   std_logic_vector(1 downto 0);

    begin

        avalon_burst   :   process(clock, reset, avs_write)
            variable    index_rcv, index_snd  :   natural :=  0;
            variable    burst_count           :   unsigned(10 downto 0);
        begin

            if (reset = '1') then
                index_rcv := 0;
                index_snd := 0;
                state_ctrl <= START;
                avs_waitrequest <= '0';
                avs_readdatavalid <= '0';
                avs_readdata <= (others => '0');
                data_available <= "00";
                rst_mtx <= '1';
                double_buffer_matrix_row <= (others => (others => '0'));
            elsif (rising_edge(clock)) then
                case state_ctrl is
                    when START =>
                        state_ctrl <= START;
                        rst_mtx <= '0';
                        if (avs_beginburst = '1') then
                            -- At the start of burst save how many bytes
                            -- We're going to receive or send
                            burst_count := unsigned(avs_burstcount);

                            -- Hold signals for one clock cycle
                            avs_waitrequest <= '1';

                            if (avs_write = '1') then
                                -- Prepare to receive data
                                state_ctrl <= LOAD;
                            else 
                                -- If wasn't write than send
                                state_ctrl <= SEND;
                            end if;
                        end if;
                    
                    when LOAD =>
                        state_ctrl <= LOAD;

                        -- Ready to receive burst
                        avs_waitrequest <= '0';

                        double_buffer_matrix_row(index_rcv) <= signed(avs_writedata);

                        -- In case data is not valid do nothing
                        if (avs_write = '1') then
                            index_rcv := index_rcv + 1;
                            burst_count := burst_count - 1;

                            if (burst_count = 0) then
                                state_ctrl <= START;
                            end if;
                        end if;

                        -- Double buffer control and buffer status
                        if (index_rcv < 2*N_dim - 1) then
                            data_available <= "00";
                        elsif ((index_rcv >= 2*N_dim - 1) and (index_rcv < 3*N_dim - 1)) then
                            data_available <= "01";
                        elsif ((index_rcv >= 3*N_dim - 1) and (index_rcv < 4*N_dim - 1)) then
                            data_available <= "10";
                        else
                            index_rcv := 0;
                            data_available <= "11";
                        end if;
                    
                    when SEND =>
                        state_ctrl <= SEND;
                        -- Prepared to send burst
                        avs_waitrequest <= '0';

                        -- If there's data to send
                        if (ready = '1') then
                            index_snd := index_snd + 1;
                            burst_count := burst_count - 1;
                            avs_readdatavalid <= '1';

                            if (burst_count = 0) then
                                -- End of burst
                                state_ctrl <= START;
                                index_snd := 0;
                                avs_readdatavalid <= '0';
                                -- Reset matrix for new computing
                                rst_mtx <= '1';
                            end if;
                        else
                            avs_readdatavalid <= '0';
                        end if;
                    end case;
                
                avs_readdata <= std_logic_vector(matrix_c(index_snd));
            end if;
        end process avalon_burst;

        matrix_clock    :   process(clock, reset)
            variable index, clk_flip        :   natural := 0;
            variable data_available_ctrl    :   std_logic_vector(1 downto 0);
        begin

            if (reset = '1') then
                index := 0;
                clk_flip := 0;
                clk_mtx <= '0';
                switch_buffer <= "11";
                data_available_ctrl := "00";
            elsif(rising_edge(clock)) then
                if (data_available_ctrl /= data_available) then
                    data_available_ctrl := data_available;
                    if (data_available = "01") then
                        index := index + 1;
                        clk_mtx <= '1';
                        if (index < N_dim) then
                            switch_buffer <= "00";
                        end if;
                    elsif (data_available = "11") then
                        index := index + 1;
                        clk_mtx <= '1';
                        if (index < N_dim) then
                            switch_buffer <= "11";
                        end if;
                    else
                        clk_mtx <= '0';
                    end if;
                end if;

                if (ready = '0') then
                    if (index >= N_dim) then
                        switch_buffer <= "01";
                        clk_mtx <= not clk_mtx;
                    end if;
                else
                    if (index >= N_dim) then
                        index := 0;
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
            clock => clk_mtx, reset => rst_mtx, matrix_a => matrix_a_column,
            matrix_b => matrix_b_row, matrix_c => matrix_c, ready => ready
        );

        matrix_a_column <=
            double_buffer_matrix_row(0 to N_dim-1)          when (switch_buffer = "00") else
            double_buffer_matrix_row(2*N_dim to 3*N_dim-1)  when (switch_buffer = "11") else
            (others => (others => '0'));
        matrix_b_row <=
            double_buffer_matrix_row(N_dim to 2*N_dim-1)    when (switch_buffer = "00") else
            double_buffer_matrix_row(3*N_dim to 4*N_dim-1)  when (switch_buffer = "11") else
            (others => (others => '0'));

end architecture behave;