LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY number_guess IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        show : IN STD_LOGIC;
        enter : IN STD_LOGIC;
        switches : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        leds : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        red_led : OUT STD_LOGIC;
        blue_led : OUT STD_LOGIC;
        green_led : OUT STD_LOGIC
    );
END number_guess;

ARCHITECTURE Behavioral OF number_guess IS
    -- FSM States
    TYPE StateType IS (RESET, GUESSING, CHECKING, ANS); -- game states
    SIGNAL state : StateType; -- current game state

    -- Random Number Generator Signals
    SIGNAL seed_top : STD_LOGIC_VECTOR(7 DOWNTO 0) := X"F6";
    SIGNAL rand_num : STD_LOGIC_VECTOR(3 DOWNTO 0);

    -- Button Results
    SIGNAL rst_btn_result, enter_btn_result, show_btn_result : STD_LOGIC;

    -- Constants
    CONSTANT clk_freq : INTEGER := 50_000_000;
    CONSTANT flash_speed : INTEGER := 1_000_000;

    -- Procedures
    PROCEDURE ToggleLED(VARIABLE count : OUT INTEGER;
    CONSTANT clk_freq : INTEGER;
    CONSTANT flash_speed : INTEGER;
    VARIABLE toggle : OUT BOOLEAN) IS
BEGIN
    count := count + 1;
    IF count = clk_freq/flash_speed THEN
        toggle := NOT toggle;
        count := 0;
    END IF;
END PROCEDURE;
BEGIN

-- Reset Button
reset_button : ENTITY work.debounce
    GENERIC MAP(
        --clk_freq => 1000000,
        stable_time => 10)
    PORT MAP(
        clk => clk,
        rst => rst,
        button => rst,
        result => rst_btn_result
    );

-- Enter Button
enter_button : ENTITY work.debounce
    GENERIC MAP(
        --clk_freq => 1000000,
        stable_time => 10)
    PORT MAP(
        clk => clk,
        rst => rst,
        button => enter,
        result => enter_btn_result
    );

-- Show Button
show_button : ENTITY work.debounce
    GENERIC MAP(
        --clk_freq => 1000000,
        stable_time => 10)
    PORT MAP(
        clk => clk,
        rst => rst,
        button => show,
        result => show_btn_result
    );

-- Random Number Generator
random_number : ENTITY work.rand_gen
    PORT MAP(
        clk => clk,
        rst => rst,
        seed => seed_top,
        output => rand_num
    );

PROCESS (clk, rst)
    VARIABLE count : INTEGER := 0;
    VARIABLE toggle : BOOLEAN := true;
BEGIN
    IF rst_btn_result = '0' THEN
        state <= GUESSING;
        blue_led <= '0';
        red_led <= '0';
        green_led <= '0';
        leds <= "0000";
    ELSIF rising_edge(clk) THEN
        CASE state IS
                -- Guessing State
            WHEN GUESSING =>
                IF show_btn_result = '1' THEN
                    state <= ANS;
                ELSIF enter_btn_result = '1' THEN
                    state <= CHECKING;
                ELSE
                    state <= GUESSING;
                END IF;

                -- Checking State
            WHEN CHECKING =>
                IF show_btn_result = '1' THEN
                    state <= ANS;
                ELSE
                    IF switches < rand_num THEN
                        -- turn on blue LED
                        blue_led <= '1';
                        red_led <= '0';
                        green_led <= '0';
                        state <= GUESSING;

                    ELSIF switches > rand_num THEN
                        -- turn on red LED
                        blue_led <= '0';
                        red_led <= '1';
                        green_led <= '0';
                        state <= GUESSING;

                    ELSE
                        -- flash green LED @ 1Hz
                        blue_led <= '0';
                        red_led <= '0';
                        IF toggle THEN
                            green_led <= '1';
                            ToggleLED(count, clk_freq, flash_speed, toggle);
                        ELSE
                            green_led <= '0';
                            ToggleLED(count, clk_freq, flash_speed, toggle);
                        END IF;
                    END IF;
                END IF;

                -- Answer State
            WHEN ANS =>
                leds <= rand_num;
                blue_led <= '0';
                red_led <= '0';
                green_led <= '0';
                -- Others State
            WHEN OTHERS =>
                state <= RESET;
        END CASE;
    END IF;
END PROCESS;
END Behavioral;