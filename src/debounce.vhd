library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity debounce is
    generic
    (
        clk_freq    : integer := 50_000_000; --system clock frequency in Hz
        stable_time : integer := 10);        --time button must remain stable in ms
    port
    (
        clk    : in std_logic;   --input clock
        rst    : in std_logic;   --asynchronous active low reset
        button : in std_logic;   --input signal to be debounced
        result : out std_logic); --debounced signal
end debounce;

architecture Behavioral of debounce is
    signal ffs : std_logic_vector(2 downto 0); 
    signal sclr, ena: std_logic;
    constant milliseconds : integer := 1/1000;
begin

    sclr <= ffs(0) xor ffs(1);

    process(clk, rst)
        variable count : integer := 0;
    begin
        if rst = '0' then
            ffs <= (others => '0');
        elsif rising_edge(clk) then
            ffs(0) <= button;
            ffs(1) <= ffs(0);
            if ena = '0' then
                if sclr = '1' then
                    count := 0;
                else
                    if count < (clk_freq*stable_time*milliseconds) then
                        count := count + 1;
                    else
                        ena <= '1';
                    end if;
                end if;
            else
                ffs(2) <= ffs(1);
                ena <= '0';
            end if;
        end if;
    end process;
    result <= ffs(2);
end Behavioral;