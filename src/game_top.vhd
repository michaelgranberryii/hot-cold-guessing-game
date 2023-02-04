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
begin

end Behavioral;