library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use std.env.stop;


entity number_guess_tb is

end number_guess_tb;

architecture Behavioral of number_guess_tb is
    signal clk_tb       : std_logic := '0';
    signal rst_tb       : std_logic;
    signal show_tb      : std_logic;
    signal enter_tb     : std_logic;
    signal switches_tb  : std_logic_vector (3 downto 0);
    signal leds_tb      : std_logic_vector (3 downto 0);
    signal red_led_tb   : std_logic;
    signal blue_led_tb  : std_logic;
    signal green_led_tb : std_logic;
    constant CP : time := 10 ns;
begin

uut: entity work.number_guess 
    port map (
        clk => clk_tb,
        rst => rst_tb,
        show => show_tb,
        enter => enter_tb,
        switches => switches_tb,
        leds => leds_tb,
        red_led => red_led_tb,
        blue_led => blue_led_tb,
        green_led => green_led_tb
    );
    
clock: process
    begin
        clk_tb <= not clk_tb;
        wait for CP/2;
    end process;
    
test: process
    begin
        -- reset
        rst_tb <= '1';
        wait for 1*CP;
        rst_tb <= '0';
        wait for 2*CP;
        rst_tb <= '1';
        wait for 2*CP;
 
        switches_tb <= x"5";
        enter_tb <= '1';
        wait for 2*CP;
        enter_tb <= '0';
        wait for 10*CP;
        
        switches_tb <= x"f";
        enter_tb <= '1';
        wait for 2*CP;
        enter_tb <= '0';
        wait for 10*CP;
        
        switches_tb <= x"a";
        enter_tb <= '1';
        wait for 2*CP;
        enter_tb <= '0';
        wait for 10*CP;

        show_tb <= '1';
        wait for 2*CP;
        show_tb <= '0';
        wait for 30*CP;

        rst_tb <= '0';
        wait for 2*CP;
        rst_tb <= '1';
        wait for 30*CP;

        enter_tb <= '1';
        wait for 2*CP;
        enter_tb <= '0';
        wait for 30*CP;
        stop;
             
    end process;
    
end Behavioral;