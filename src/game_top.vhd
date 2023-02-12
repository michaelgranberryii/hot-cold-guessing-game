LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY number_guess IS
    GENERIC (
        clk_freq_const : INTEGER := 125_000_000; -- clock frequncy
        flash_speed : INTEGER := 2 -- number of flashes per second
    );
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
    SIGNAL seed_top : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL random_number_top : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL secret_number : STD_LOGIC_VECTOR(3 DOWNTO 0);

    -- Signal
    SIGNAL rst_btn_result, enter_btn_result, show_btn_result : STD_LOGIC; -- Button Results
    SIGNAL toggle : STD_LOGIC;
    SIGNAL count : INTEGER;

BEGIN

    -- Reset Button
    reset_button : ENTITY work.debounce
        GENERIC MAP(
            clk_freq => clk_freq_const, --system clock frequency in Hz
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
            clk_freq => clk_freq_const, --system clock frequency in Hz
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
            clk_freq => clk_freq_const, --system clock frequency in Hz
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
            output => random_number_top
        );

    -- Capture Secret Number
    PROCESS (clk, rst)
        VARIABLE capture : STD_LOGIC;
    BEGIN
        IF rst = '1' THEN
            seed_top <= x"a3";
            capture := '1';
        ELSIF enter_btn_result = '1' OR show_btn_result = '1' THEN
            IF capture = '1' THEN
                secret_number <= random_number_top;
                capture := '0';
            END IF;
        END IF;
    END PROCESS;
    
    -- FSM Process
    FSM : PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            state <= GUESSING;
        ELSIF rising_edge(clk) THEN
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
                    state <= GUESSING;

                    -- OTHERS
                WHEN OTHERS =>
                    state <= GUESSING;
            END CASE;
        END IF;
    END PROCESS;

    -- State Output
    state_output : PROCESS (rst, clk, count)
    BEGIN
        IF rst = '1' THEN
            blue_led <= '0';
            red_led <= '0';
            green_led <= '0';
            leds <= "0000";
            toggle <= '1';
            count <= 0;
        ELSIF rising_edge(clk) THEN
            CASE state IS
                -- GUESSING OUTPUT
                WHEN GUESSING => 
                    -- Do nothing
                
                    -- CHECKING OUTPUT
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

                    -- CORRECT OUTPUT
                WHEN CORRECT =>
                    blue_led <= '0';
                    red_led <= '0';
                    -- flash green LED
                    green_led <= toggle;
                    count <= count + 1;
                    IF count = (clk_freq_const/flash_speed) - 1 THEN
                        toggle <= NOT toggle;
                        count <= 0;
                    END IF;

                    -- ANSWER OUTPUT
                WHEN ANS =>
                    leds <= secret_number;
                    blue_led <= '0';
                    red_led <= '0';
                    green_led <= '0';

                    -- OTHERS OUTPUT
                WHEN OTHERS =>
                    blue_led <= '0';
                    red_led <= '0';
                    green_led <= '0';
                    leds <= "0000";
            END CASE;
        END IF;
    END PROCESS;
END Behavioral;