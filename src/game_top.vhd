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
    type StateType is (RESET, GUESSING, CHECKING, ANS); -- game states
    signal state : StateType; -- current game state
    
    -- Random Number Generator Signals
    signal seed_top : std_logic_vector(7 downto 0) := X"F6";
    signal rand_num : std_logic_vector(3 downto 0);
    
    -- Button Results
    signal rst_btn_result, enter_btn_result, show_btn_result : std_logic;

    -- Constants
    constant clk_freq : integer := 50_000_000;
    constant flash_speed : integer := 1_000_000;
    
    procedure ToggleLED(variable count : out integer;     
                        constant clk_freq : integer;
                        constant flash_speed :  integer;
                        variable toggle : out boolean) is
    begin
        count := count + 1;
        if count = clk_freq/flash_speed then
            toggle := not toggle;
            count := 0;
        end if;  
    end procedure;
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
            rst => rst,
            seed => seed_top,
            output => rand_num
        );

    process (clk, rst)
        variable count : integer := 0;
        variable toggle : boolean := true;
    begin
        if rst_btn_result = '0' then
            state <= GUESSING;
            blue_led <= '0';
            red_led <= '0';
            green_led <= '0';
            leds <= "0000";
        elsif rising_edge(clk) then
            case state is
                -- Guessing State
                when GUESSING =>
                if enter_btn_result = '1' then
                    state <= CHECKING;
                else
                    state <= GUESSING;
                end if;    
                
                -- Checking State
                when CHECKING =>
                if show_btn_result = '1' then
                    state <= ANS;
                else
                    if switches < rand_num then
                        -- turn on blue LED
                        blue_led <= '1';
                        red_led <= '0';
                        green_led <= '0';
                        state <= GUESSING;

                    elsif switches > rand_num then
                        -- turn on red LED
                        blue_led <= '0';
                        red_led <= '1';
                        green_led <= '0';
                        state <= GUESSING;
                        
                    else
                        -- flash green LED @ 1Hz
                        blue_led <= '0';
                        red_led <= '0';
                        if toggle then
                            green_led <= '1';
                            ToggleLED(count, clk_freq,flash_speed, toggle);
                        else
                            green_led <= '0';
                            ToggleLED(count, clk_freq,flash_speed, toggle);
                        end if;
                    end if;
                 end if;
                 
                -- Answer State
                when ANS =>
                    leds <= rand_num;
                
                -- Others State
                when others =>
                    state <= RESET; 
                end case;             
        end if;
    end process;
end Behavioral;