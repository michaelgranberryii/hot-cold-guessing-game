LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE std.env.stop;

ENTITY single_pulse_detector_tb IS

END single_pulse_detector_tb;

ARCHITECTURE Behavioral OF single_pulse_detector_tb IS
    SIGNAL clk_tb : STD_LOGIC;
    SIGNAL rst_tb : STD_LOGIC;
    SIGNAL input_signal_tb : STD_LOGIC;
    SIGNAL output_pulse_tb : STD_LOGIC;
    CONSTANT CP : TIME := 10 ns;
BEGIN

    uut : ENTITY work.single_pulse_detector
        PORT MAP(
            clk => clk_tb,
            rst => rst_tb,
            input_signal => input_signal_tb,
            output_pulse => output_pulse_tb);

    PROCESS
    BEGIN
        clk_tb <= '0';
        WAIT FOR CP/2;
        clk_tb <= '1';
        WAIT FOR CP/2;
    END PROCESS;

    PROCESS
    BEGIN
        rst_tb <= '1';
        WAIT FOR CP;
        rst_tb <= '0';
        WAIT FOR 5 * CP;
        input_signal_tb <= '1';
        WAIT FOR 5 * CP;
        input_signal_tb <= '0';
        WAIT FOR 5 * CP;
        input_signal_tb <= '1';
        WAIT FOR CP;
        input_signal_tb <= '0';
        WAIT FOR CP;
        input_signal_tb <= '1';
        WAIT FOR CP;
        input_signal_tb <= '0';
        WAIT FOR 10 * CP;
        stop;
    END PROCESS;

END Behavioral;