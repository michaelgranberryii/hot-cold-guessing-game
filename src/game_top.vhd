library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity number_guess is
    port
    (
        clk       : in std_logic;
        rst       : in std_logic;
        show      : in std_logic;
        enter     : in std_logic;
        switches  : in std_logic_vector (3 downto 0);
        leds      : out std_logic_vector (3 downto 0);
        red_led   : out std_logic;
        blue_led  : out std_logic;
        green_led : out std_logic
    );
end number_guess;

architecture Behavioral of number_guess is
    -- FSM States
    type StateType is (RESET, ENTR, ANS); -- game states
    signal state : StateType; -- current game state
    
    -- Random Number Generator Signals
    signal seed_top : std_logic_vector(7 downto 0) := x"A5";
    signal rand_num : std_logic_vector(3 downto 0);
    
    -- Button Results
    signal rst_btn_result, enter_btn_result, show_btn_result : std_logic;
begin

    -- Reset Button
    reset_button: entity work.debounce 
        generic map (
            --clk_freq => 1000000,
            stable_time => 10)
        port map (
            clk => clk,
            rst => rst,
            button => rst,
            result => rst_btn_result
        );
    
    -- Enter Button
    enter_button: entity work.debounce 
        generic map (
            --clk_freq => 1000000,
            stable_time => 10)
        port map (
            clk => clk,
            rst => rst,
            button => enter,
            result => enter_btn_result
        );
        
    -- Show Button
    show_button: entity work.debounce 
        generic map (
            --clk_freq => 1000000,
            stable_time => 10)
        port map (
            clk => clk,
            rst => rst,
            button => show,
            result => show_btn_result
        );
        
    -- Random Number Generator
    random_number: entity work.rand_gen
        port map (
            clk => clk,
            rst => not rst,
            seed => seed_top,
            output => rand_num
        );

    process (clk, rst) 
    begin
        if rst_btn_result = '0' then
            state <= RESET;
            blue_led <= '0';
            red_led <= '0';
            green_led <= '0';
            --seed_top <= X"A6"; -- seed value
        elsif rising_edge(clk) then
            case state is
                when RESET =>
                if enter_btn_result = '1' then
                    state <= ENTR;
                else
                    state <= RESET;
                end if;             
                when ENTR =>
                if show_btn_result = '1' then
                    state <= ANS;
                else
                    if switches < rand_num then
                        -- turn on blue LED
                        blue_led <= '1';
                        red_led <= '0';
                        green_led <= '0';
                        

                    elsif switches > rand_num then
                        -- turn on red LED
                        blue_led <= '0';
                        red_led <= '1';
                        green_led <= '0';
                        
                    else
                        -- flash green LED @ 1Hz
                        blue_led <= '0';
                        red_led <= '0';
                        green_led <= '1';
                    end if;
                 end if;
                when ANS =>
                    leds <= rand_num;
                when others =>
                    state <= RESET; 
                end case;             
        end if;
    end process;
end Behavioral;