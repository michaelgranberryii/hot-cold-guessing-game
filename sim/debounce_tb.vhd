library ieee;
use ieee.std_logic_1164.all;
use std.env.stop;


entity debounce_tb is
end debounce_tb;

architecture Behavioral of debounce_tb is
    signal clk_tb : std_logic := '0';
    signal rst_tb : std_logic;
    signal button_tb : std_logic;
    signal result_tb : std_logic;
    constant CP : time := 10 ns;
    constant bounce : time := 1 ns;
begin
uut: entity work.debounce 
    generic map (
        --clk_freq => 1000000,
        stable_time => 10)
    port map (
        clk => clk_tb,
        rst => rst_tb,
        button => button_tb,
        result => result_tb
    );

    clock: process
    begin
        clk_tb <= not clk_tb;
        wait for CP/2;
    end process;

    test: process
    begin
        rst_tb <= '0';
        wait for CP;
        rst_tb <= '1';
        wait for CP;
        
        button_tb <= '1';
        wait for 3*CP;
        button_tb <= '0';
        wait for 10*CP;
        button_tb <= '1';
        wait for 3*CP;
        button_tb <= '0';
        wait for 10*CP;
        button_tb <= '1';
        wait for 500 ms;
        button_tb <= '0';
        wait for 500 ms;
        
--        button_tb <= '1';
--        wait for 2*CP;
--        button_tb <= '0';
--        wait for 10*CP;

--        button_tb <= '1';
--        wait for 3*CP;
--        button_tb <= '0';
--        wait for 10*CP;
        
--        button_tb <= '1';
--        wait for 4*CP;
--        button_tb <= '0';
--        wait for 10*CP;
        stop;
    end process;

end Behavioral;