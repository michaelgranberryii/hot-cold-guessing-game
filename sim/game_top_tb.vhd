LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE std.env.stop;
ENTITY number_guess_tb IS

END number_guess_tb;

ARCHITECTURE Behavioral OF number_guess_tb IS
    SIGNAL clk_tb : STD_LOGIC := '0';
    SIGNAL rst_tb : STD_LOGIC;
    SIGNAL show_tb : STD_LOGIC;
    SIGNAL enter_tb : STD_LOGIC;
    SIGNAL switches_tb : STD_LOGIC_VECTOR (3 DOWNTO 0);
    SIGNAL leds_tb : STD_LOGIC_VECTOR (3 DOWNTO 0);
    SIGNAL red_led_tb : STD_LOGIC;
    SIGNAL blue_led_tb : STD_LOGIC;
    SIGNAL green_led_tb : STD_LOGIC;
    CONSTANT CP : TIME := 10 ns;
BEGIN

    uut : ENTITY work.number_guess
        PORT MAP(
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

    clock : PROCESS
    BEGIN
        clk_tb <= NOT clk_tb;
        WAIT FOR CP/2;
    END PROCESS;

    test : PROCESS
    BEGIN
        rst_tb <= '1';
        WAIT FOR 1 * CP;
        rst_tb <= '0';
        WAIT FOR 2 * CP;
        rst_tb <= '1';
        WAIT FOR 2 * CP;

        switches_tb <= x"5";
        enter_tb <= '1';
        WAIT FOR 1 ms;
        enter_tb <= '0';
        WAIT FOR 1 ms;

        switches_tb <= x"b";
        enter_tb <= '1';
        WAIT FOR 1 ms;
        enter_tb <= '0';
        WAIT FOR 2 ms;

        switches_tb <= x"f";
        enter_tb <= '1';
        WAIT FOR 1 ms;
        enter_tb <= '0';
        WAIT FOR 2 ms;

        show_tb <= '1';
        WAIT FOR 1 ms;
        show_tb <= '0';
        WAIT FOR 2 ms;

        rst_tb <= '0';
        WAIT FOR 1 ms;
        rst_tb <= '1';
        WAIT FOR 1 ms;

        enter_tb <= '1';
        WAIT FOR 1 ms;
        enter_tb <= '0';
        WAIT FOR 1 ms;
        stop;

    END PROCESS;

END Behavioral;