library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use std.env.stop;

entity rand_gen_tb is

end rand_gen_tb;

architecture Behavioral of rand_gen_tb is
        signal clk_tb           : std_logic := '0';
        signal rst_tb           : std_logic;
        signal seed_tb          : std_logic_vector(7 downto 0);
        signal output_tb        : std_logic_vector (3 downto 0);
        constant CP : time      := 10 ns;
begin

uut: entity work.rand_gen 
    port map (
        clk => clk_tb,
        rst => rst_tb,
        seed => seed_tb,
        output => output_tb
    );
    
    clock: process
    begin
        clk_tb <= not clk_tb;
        wait for CP/2;
    end process;
    
    seed: process
    begin
    seed_tb <= x"A5";
    rst_tb <= '1';
    wait for CP;
    rst_tb <= '0';
    wait for 10*CP;
    seed_tb <= x"AA";
    rst_tb <= '1';
    wait for CP;
    rst_tb <= '0';
    wait for 10*CP;
    stop;
    end process;
    
end Behavioral;