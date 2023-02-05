library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity rand_gen is
    port
    (
        clk, rst : in std_logic;
        seed     : in std_logic_vector(7 downto 0);
        output   : out std_logic_vector (3 downto 0)
    );
end rand_gen;

architecture Behavioral of rand_gen is

signal shift_reg : std_logic_vector(7 downto 0);
signal feedback : std_logic; 
begin

process(clk, rst)
begin
if rst = '1' then
    shift_reg <= seed;
elsif rising_edge(clk) then
    shift_reg <= shift_reg(6 downto 0) & feedback;
end if;
end process;

feedback <= shift_reg(3) xor shift_reg(4) xor shift_reg(5);
output <= shift_reg(7 downto 4);

end Behavioral;