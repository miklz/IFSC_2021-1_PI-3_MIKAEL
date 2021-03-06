library ieee;
use std.textio.all;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.array_types.all;
use work.file_helpers.all;

entity mesh_array_interface_tb is
end entity;

architecture simul of mesh_array_interface_tb is

    constant T      : time := 20 ns;
    constant delay  : time := 5 ns;

    constant matrix_a_file  : string := "../values_a.txt";
    constant matrix_b_file  : string := "../values_b.txt";
    constant multip_result  : string := "../product.txt";

    file flptr_a, flptr_b, flptr_r : text;

    constant matrix_size : natural := 5;
    constant n_bits      : natural := 32;

    signal clk, rst : std_logic;
    
    -- Avalon signals
    signal beginburst_avm       : std_logic;
    signal burstcount_avm       : std_logic_vector(10 downto 0);
    signal write_avm            : std_logic;
    signal writedata_avm        : std_logic_vector(n_bits-1 downto 0);
    signal waitrequest_avs      : std_logic;
    signal read_avm             : std_logic;
    signal readdata_avs         : std_logic_vector(n_bits-1 downto 0);
    signal readdatavalid_avs    : std_logic;

    -- Matrix buffers
    signal matrix_a : vector_of_numbers(0 to matrix_size*matrix_size-1) := (others => (others => 'Z'));
    signal matrix_b : vector_of_numbers(0 to matrix_size*matrix_size-1) := (others => (others => 'Z'));
    signal matrix_c : vector_of_numbers(0 to matrix_size*matrix_size-1) := (others => (others => 'Z'));

    begin

        interface_avalon : entity work.matrix_mult_control(behave)
        generic map (
            N_dim   =>  matrix_size,
            N_bits  =>  n_bits
        )
        port map (
            clk, rst, beginburst_avm, burstcount_avm, write_avm, writedata_avm,
            waitrequest_avs, read_avm, readdata_avs, readdatavalid_avs
          );

        clock : process
        begin
            clk <= '0';
            wait for T/2;
            clk <= '1';
            wait for T/2;
        end process clock;

        interface_test : process
            variable line_a, line_b, line_r : line;
            variable file_status_a, file_status_b, file_status_r  : FILE_OPEN_STATUS;

        begin

            rst <= '1';
            write_avm <= '0';
            read_avm <= '0';
            beginburst_avm <= '0';
            writedata_avm <= (others => '0');
            burstcount_avm <= (others => '0');
            matrix_a <= (others => (others => '0'));
            matrix_b <= (others => (others => '0'));
            wait for 2*T;

            file_open(file_status_a, flptr_a, matrix_a_file, read_mode);
            file_open(file_status_b, flptr_b, matrix_b_file, read_mode);
            file_open(file_status_r, flptr_r, multip_result, write_mode);

            -- Check if files were opened
            assert ((file_status_a = open_ok) and (file_status_b = open_ok) and
            (file_status_r = open_ok)) report "FILE ERROR" severity error;

            rst <= '0';

            while(not endfile(flptr_a)) loop
                readline(flptr_a, line_a);
                readline(flptr_b, line_b);

                read_array_from_line(line_a, matrix_a, matrix_size);
                read_array_from_line(line_b, matrix_b, matrix_size);
                
                wait for T;

                -- Write to matrix mesh
                for i in 0 to matrix_size - 1 loop

                    burstcount_avm <= std_logic_vector(to_unsigned(2*matrix_size, burstcount_avm'length));
                    if (waitrequest_avs = '0') then
                        -- Signaling the begin of burst
                        beginburst_avm <= '1';
                        write_avm <= '1';

                        -- Load matrix A
                        for j in 0 to matrix_size - 1 loop
                            -- Column order
                            writedata_avm <= std_logic_vector(matrix_a(j*matrix_size + i));
                            wait for T;

                            beginburst_avm <= '0';
                            -- Check if matrix is ready to receive data
                            if (waitrequest_avs = '1') then
                            -- Wait until matrix is ready
                                wait until waitrequest_avs = '0';
                                wait for T;
                            end if;

                            burstcount_avm <= (others => '0');
                        end loop;

                        -- Load matrix B
                        for j in 0 to matrix_size - 1 loop
                            -- Row order
                            writedata_avm <= std_logic_vector(matrix_b(i*matrix_size + j));
                            wait for T;
                        end loop;
                    end if;
                end loop;

                write_avm <= '0';
                wait for T;
                
                -- Ask for data
                read_avm <= '1';
                -- Burst to read Result
                beginburst_avm <= '1';
                burstcount_avm <= std_logic_vector(to_unsigned(matrix_size*matrix_size, burstcount_avm'length));
                wait for T;

                -- Begin burst goes down no matter what
                beginburst_avm <= '0';
                if (waitrequest_avs = '1') then
                    -- Wait until matrix is ready
                    wait until waitrequest_avs = '0';
                    wait for T;
                end if;

                read_avm <= '0';
                burstcount_avm <= (others => '0');
                -- Read from matrix mesh
                if (readdatavalid_avs = '0') then
                    -- Only load if data is valid
                    wait until readdatavalid_avs = '1';
                    wait for T;
                end if;

                for i in 0 to matrix_size - 1 loop
                    for j in 0 to matrix_size - 1 loop
                        matrix_c(i*matrix_size + j) <= signed(readdata_avs);
                        wait for T;
                    end loop;
                end loop;
                

                write_array_to_line(line_r, matrix_c, matrix_size);
                writeline(flptr_r, line_r);
                wait for T;

            end loop;

            file_close(flptr_a);
            file_close(flptr_b);
            file_close(flptr_r);
            wait;

        end process interface_test;

end architecture simul;