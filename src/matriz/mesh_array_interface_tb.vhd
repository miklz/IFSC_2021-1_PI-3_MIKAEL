library ieee;
use std.textio.all;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.array_types.all;
use work.file_helpers.all;

entity mesh_array_tb is
end entity;

architecture simul of mesh_array_tb is

    constant T      : time := 20 ns;
    constant delay  : time := 5 ns;

    constant matrix_size : natural := 5;
    constant n_bits      : natural := 32;

    signal clk, rst : std_logic;
    
    -- Avalon signals
    signal burstcount_avm       : std_logic_vector(10 downto 0);
    signal write_avm            : std_logic;
    signal writedata_avm        : std_logic_vector(n_bits-1 downto 0);
    signal read_avm             : std_logic;
    signal readdata_avs         : std_logic_vector(n_bits-1 downto 0);
    signal readdatavalid_avs    : std_logic;

    begin

        interface_avalon : entity work.matrix_mult_control(behave)
        generic map (
            N_dim   =>  matrix_size;
            N_bits  =>  n_bits
        )
        port map (
            clk, rst, burstcount_avm, write_avm, writedata_avm,
            read_avm, readdata_avs, readdatavalid_avs
          );

        clock : process
        begin
            clk <= '0';
            wait for T/2;
            clk <= '1';
            wait for T/2;
        end process clock;


        interface_test : process(clk)

        begin

            rst <= '1';

        end process interface_test;

end architecture;