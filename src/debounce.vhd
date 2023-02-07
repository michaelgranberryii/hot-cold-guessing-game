LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY debounce IS
    GENERIC (
        clk_freq : INTEGER := 50_000_000; --system clock frequency in Hz
        stable_time : INTEGER := 10); --time button must remain stable in ms
    PORT (
        clk : IN STD_LOGIC; --input clock
        rst : IN STD_LOGIC; --asynchronous active low reset
        button : IN STD_LOGIC; --input signal to be debounced
        result : OUT STD_LOGIC); --debounced signal
END debounce;

ARCHITECTURE Behavioral OF debounce IS
    SIGNAL ffs : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL sclr : STD_LOGIC;
    SIGNAL ena : STD_LOGIC := '0';
    CONSTANT milliseconds : INTEGER := 1/1000;
BEGIN

    sclr <= ffs(0) XOR ffs(1);

    PROCESS (clk, rst)
        VARIABLE count : INTEGER := 0;
    BEGIN
        IF rst = '0' THEN
            ffs <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            ffs(0) <= button;
            ffs(1) <= ffs(0);
            IF ena = '0' THEN
                IF sclr = '1' THEN
                    count := 0;
                ELSE
                    IF count < (clk_freq * stable_time * milliseconds) THEN
                        count := count + 1;
                    ELSE
                        ena <= '1';
                    END IF;
                END IF;
            ELSE
                ffs(2) <= ffs(1);
                --ena <= '0';
            END IF;
        END IF;
    END PROCESS;
    result <= ffs(2);
END Behavioral;