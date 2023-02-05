library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity single_pulse_detector is
    port
    (
        clk          : in std_logic;
        rst          : in std_logic;
        input_signal : in std_logic;
        output_pulse : out std_logic);
end single_pulse_detector;

architecture Behavioral of single_pulse_detector is
    signal FF1 : std_logic;
    signal FF2 : std_logic;
begin

    process (clk, rst)
    begin
    if rst = '1' then
        FF1 <= '0';
        FF2 <= '0';
    elsif rising_edge(clk) then
        FF1 <= input_signal;
        FF2 <= FF1;
    end if;
    end process;

    output_pulse <= FF1 xor FF2;

end Behavioral;