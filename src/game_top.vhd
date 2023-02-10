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
    TYPE StateType IS (GUESSING, CHECKING, CORRECT, ANS); -- game states
    SIGNAL state : StateType; -- current game state

    -- Random Number Generator Signals
    SIGNAL seed_top : STD_LOGIC_VECTOR(7 DOWNTO 0) := X"A3";
    SIGNAL secret_number : STD_LOGIC_VECTOR(3 DOWNTO 0);

    -- Signal
    SIGNAL rst_btn_result, enter_btn_result, show_btn_result : STD_LOGIC; -- Button Results
    SIGNAL toggle : STD_LOGIC := '0';

    -- Constants
    CONSTANT clk_freq_const : INTEGER := 50_000_000; -- clock frequncy
    CONSTANT flash_speed : INTEGER := 100000; -- number of flashes per second

BEGIN

    -- Reset Button
    reset_button : ENTITY work.debounce
        GENERIC MAP(
            clk_freq => 50_000_000, --system clock frequency in Hz
            stable_time => 10) --time button must remain stable in ms
        PORT MAP(
            clk => clk,
            rst => '0',
            button => rst,
            result => rst_btn_result
        );

    -- Enter Button
    enter_button : ENTITY work.debounce
        GENERIC MAP(
            clk_freq => 50_000_000, --system clock frequency in Hz
            stable_time => 10) --time button must remain stable in ms
        PORT MAP(
            clk => clk,
            rst => rst,
            button => enter,
            result => enter_btn_result
        );

    -- Show Button
    show_button : ENTITY work.debounce
        GENERIC MAP(
            clk_freq => 50_000_000, --system clock frequency in Hz
            stable_time => 10) --time button must remain stable in ms
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
            output => secret_number
        );

    -- FSM Process
    PROCESS (clk, rst)
        VARIABLE count : INTEGER := 0;
        VARIABLE is_seeded : BOOLEAN := true;
    BEGIN
        IF rst = '1' THEN
            state <= GUESSING;
            blue_led <= '0';
            red_led <= '0';
            green_led <= '0';
            leds <= "0000";
        ELSIF rising_edge(clk) THEN

            -- States
            CASE state IS
                    -- GUESSING
                WHEN GUESSING =>
                    IF enter_btn_result = '1' THEN
                        state <= CHECKING;
                    ELSIF show_btn_result = '1' THEN
                        state <= ANS;
                    END IF;

                    -- CHECKING
                WHEN CHECKING =>
                    IF switches < secret_number THEN
                        state <= GUESSING;
                    ELSIF switches > secret_number THEN
                        state <= GUESSING;
                    ELSIF switches = secret_number THEN
                        state <= CORRECT;
                    END IF;
                    -- CORRECT
                WHEN CORRECT =>
                    state <= CORRECT;

                    -- ANSWER
                WHEN ANS =>
                    state <= ANS;

                    -- OTHERS
                WHEN OTHERS =>
                    state <= GUESSING;
            END CASE;
        END IF;

        -- State Ouput
        CASE state IS
            WHEN GUESSING =>
                -- Do nothing
            WHEN CHECKING =>
                IF switches < secret_number THEN
                    -- turn on blue LED
                    blue_led <= '1';
                    red_led <= '0';
                    green_led <= '0';
                ELSIF switches > secret_number THEN
                    -- turn on red LED
                    blue_led <= '0';
                    red_led <= '1';
                    green_led <= '0';
                END IF;

                -- CORRECT
            WHEN CORRECT =>
                blue_led <= '0';
                red_led <= '0';
                -- flash green LED
                green_led <= toggle;
                count := count + 1;
                IF count < clk_freq_const/flash_speed THEN
                    toggle <= NOT toggle;
                    count := 0;
                END IF;

                -- ANSWER
            WHEN ANS =>
                leds <= secret_number;
                blue_led <= '0';
                red_led <= '0';
                green_led <= '0';

                -- OTHERS
            WHEN OTHERS =>
                blue_led <= '0';
                red_led <= '0';
                green_led <= '0';
                leds <= "0000";
        END CASE;
    END PROCESS;
END Behavioral;