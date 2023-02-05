library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use std.env.stop;

entity single_pulse_detector_tb is

end single_pulse_detector_tb;

architecture Behavioral of single_pulse_detector_tb is
    signal clk_tb : std_logic;
    signal rst_tb : std_logic;
    signal input_signal_tb : std_logic;
    signal output_pulse_tb : std_logic;
    constant CP : time := 10 ns;
begin

uut: entity work.single_pulse_detector 
    port map(
        clk => clk_tb,
        rst => rst_tb,
        input_signal => input_signal_tb,
        output_pulse => output_pulse_tb);

process
begin
clk_tb <= '0';
wait for CP/2;
clk_tb <= '1';
wait for CP/2;
end process;

process
begin
rst_tb <= '1';
wait for CP;
rst_tb <= '0';
wait for  5*CP;
input_signal_tb <= '1';
wait for  5*CP;
input_signal_tb <= '0';
wait for 5*CP;
input_signal_tb <= '1';
wait for CP;
input_signal_tb <= '0';
wait for CP;
input_signal_tb <= '1';
wait for CP;
input_signal_tb <= '0';
wait for 10*CP;
stop;
end process;
    
    

end Behavioral;