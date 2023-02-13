LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY number_guess IS
    GENERIC (
        CLK_FREQ : INTEGER := 125_000_000; -- clock frequncy
        FLASH_SPEED : INTEGER := 2; -- number of flashes per second
        LED_SHIFT_SPEED : INTEGER := 13 -- shift speed of LEDs when rst btn is pressed
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
    TYPE StateType IS (GUESSING, CHECKING, CORRECT); -- game states
    SIGNAL state : StateType; -- current game state

    -- Random Number Generator Signals
    SIGNAL seed_top : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL random_number_top : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL secret_number : STD_LOGIC_VECTOR(3 DOWNTO 0);

    -- Button Signals
    SIGNAL rst_btn_result, enter_btn_result, show_btn_result : STD_LOGIC;
    SIGNAL enter_pulse_out : STD_LOGIC;
    
    -- Other Signals
    SIGNAL toggle : STD_LOGIC;
    SIGNAL count : INTEGER;
    SIGNAL count_rst : INTEGER;
    SIGNAL is_captured : BOOLEAN;
    SIGNAL is_reset : BOOLEAN;
    
    -- LED Signal
    SIGNAL led_reset_shift: std_logic_vector(3 downto 0);

BEGIN

    -- Reset Button
    reset_button : ENTITY work.debounce
        GENERIC MAP(
            clk_freq => CLK_FREQ, --system clock frequency in Hz
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
            clk_freq => CLK_FREQ, --system clock frequency in Hz
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
            clk_freq => CLK_FREQ, --system clock frequency in Hz
            stable_time => 10) --time button must remain stable in ms
        PORT MAP(
            clk => clk,
            rst => rst,
            button => show,
            result => show_btn_result
        );
     
    -- Enter Pulse Detector
    enter_pulse_dect : entity work.single_pulse_detector
        generic map (detect_type => "00")
        port map (
            clk => clk,
            rst => rst,
            input_signal => enter_btn_result,
            output_pulse => enter_pulse_out
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
    Capture_p: PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            seed_top <= x"a3";
            is_captured <= false;
        ELSIF enter_pulse_out = '1' THEN
            IF is_captured = false THEN
                secret_number <= random_number_top;
                is_captured <= true;
            END IF;
        END IF;
    END PROCESS;
    
    Show_p: process (clk, rst)  
    begin
    if rising_edge(clk) then
        if rst = '1' then
            if is_reset then
                led_reset_shift<= "0001";
                is_reset <= false;
            end if;
            leds <= led_reset_shift;
            count_rst  <= count_rst  + 1;
            IF count_rst  = (CLK_FREQ/LED_SHIFT_SPEED) - 1 THEN
                led_reset_shift<= led_reset_shift(2 downto 0) & led_reset_shift(3);
                count_rst  <= 0;
            END IF;
        elsif rst = '0' then
            count_rst  <= 0;
            leds <= "0000";
            is_reset <= true;
        end if;
        if is_captured then
            if show_btn_result = '1' then
                leds <= secret_number;
            else
                leds <= "0000";
            end if;
        end if;
    end if;
    end process;
    
    -- FSM Process
    FSM : PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            state <= GUESSING;
        ELSIF rising_edge(clk) THEN
            CASE state IS

                    -- GUESSING
                WHEN GUESSING =>
                    IF enter_pulse_out = '1' THEN
                        state <= CHECKING;
                    END IF;

                    -- CHECKING
                WHEN CHECKING =>
                    IF unsigned(switches) < unsigned(secret_number) THEN
                        state <= GUESSING;
                    ELSIF unsigned(switches) > unsigned(secret_number) THEN
                        state <= GUESSING;
                    ELSIF unsigned(switches) = unsigned(secret_number) THEN
                        state <= CORRECT;
                    END IF;

                    -- CORRECT
                WHEN CORRECT =>
                    state <= CORRECT;

                    -- OTHERS
                WHEN OTHERS =>
                    state <= GUESSING;
            END CASE;
        END IF;
    END PROCESS;

    -- State Output
    state_output : PROCESS (rst, clk, count)
    BEGIN
        IF rising_edge(clk) THEN
            IF rst = '1' THEN
                blue_led <= '0';
                red_led <= '0';
                green_led <= '0';
                toggle <= '1';
                count <= 0;
            end if;
            
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
                    IF count = (CLK_FREQ/FLASH_SPEED) - 1 THEN
                        toggle <= NOT toggle;
                        count <= 0;
                    END IF;

                    -- OTHERS OUTPUT
                WHEN OTHERS =>
                    blue_led <= '0';
                    red_led <= '0';
                    green_led <= '0';
            END CASE;
        END IF;
    END PROCESS;
END Behavioral;