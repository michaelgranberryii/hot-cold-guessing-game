LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY rand_gen IS
    PORT (
        clk, rst : IN STD_LOGIC;
        seed : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        output : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
    );
END rand_gen;

ARCHITECTURE Behavioral OF rand_gen IS

    -- SIGNAL shift_reg : STD_LOGIC_VECTOR(7 DOWNTO 0);
    -- SIGNAL feedback : STD_LOGIC;
    -- SIGNAL is_seeding : BOOLEAN := true;

    -- BEGIN

    -- PROCESS (clk, rst)
    --     --VARIABLE is_seeding : BOOLEAN := true;
    -- BEGIN
    --     IF rst = '1' THEN -- async active low reset
    --         IF is_seeding = true THEN -- if is_seed is true then... 
    --             shift_reg <= seed; -- set seed
    --             is_seeding <= false; -- set is_seed to false
    --         ELSE
    --             shift_reg <= shift_reg(6 DOWNTO 0) & feedback; -- while reset = 0, generate randon number
    --         END IF;
    --     ELSIF rising_edge(clk) THEN
    --     is_seeding <= true; -- while reset = 1, set is_seed to true
    --     END IF;
    -- END PROCESS;

    -- feedback <= shift_reg(3) XOR shift_reg(4) XOR shift_reg(5); -- feedback bit
    -- output <= shift_reg(7 DOWNTO 4); -- saved random number

    SIGNAL currstate : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL nextstate : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL feedback : STD_LOGIC;
BEGIN

    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            currstate <= seed;
        ELSIF rising_edge(clk) THEN
            currstate <= nextstate;
        END IF;
    END PROCESS;

    feedback <= currstate(4) XOR currstate(3) XOR currstate(2) XOR currstate(0);
    nextstate <= feedback & currstate(7 DOWNTO 1);
    output <= currstate(7 DOWNTO 4);

END Behavioral;