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
    SIGNAL FF : STD_LOGIC;
BEGIN

    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            FF <= '0';
        ELSIF rising_edge(clk) THEN
            FF <= input_signal;
        END IF;
    END PROCESS;

    output_pulse <= NOT FF AND input_signal;

END Behavioral;