LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY single_pulse_detector IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        input_signal : IN STD_LOGIC;
        output_pulse : OUT STD_LOGIC);
END single_pulse_detector;

ARCHITECTURE Behavioral OF single_pulse_detector IS
    SIGNAL FF1 : STD_LOGIC;
    SIGNAL FF2 : STD_LOGIC;
BEGIN

    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            FF1 <= '0';
            FF2 <= '0';
        ELSIF rising_edge(clk) THEN
            FF1 <= input_signal;
            FF2 <= FF1;
        END IF;
    END PROCESS;

    output_pulse <= FF1 XOR FF2;

END Behavioral;