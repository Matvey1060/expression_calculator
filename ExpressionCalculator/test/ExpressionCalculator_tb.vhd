LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;

ENTITY ExpressionCalculator_tb IS
END ExpressionCalculator_tb;

ARCHITECTURE Behavioral OF ExpressionCalculator_tb IS
    CONSTANT DATA_WIDTH : INTEGER := 8;
    CONSTANT CLK_PERIOD : TIME := 10 ns;

    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL reset : STD_LOGIC := '1';
    SIGNAL valid_in : STD_LOGIC := '0';
    SIGNAL a, b, c, d : signed(DATA_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL q : signed(2 * DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL valid_out : STD_LOGIC;
    SIGNAL overflow : STD_LOGIC;

    COMPONENT ExpressionCalculator IS
        GENERIC (DATA_WIDTH : INTEGER);
        PORT (
            clk, reset, valid_in : IN STD_LOGIC;
            a, b, c, d : IN signed(DATA_WIDTH - 1 DOWNTO 0);
            q : OUT signed(2 * DATA_WIDTH - 1 DOWNTO 0);
            valid_out, overflow : OUT STD_LOGIC
        );
    END COMPONENT;

BEGIN
    clk <= NOT clk AFTER CLK_PERIOD/2;

    DUT : ExpressionCalculator
    GENERIC MAP(DATA_WIDTH => DATA_WIDTH)
    PORT MAP(
        clk => clk,
        reset => reset,
        valid_in => valid_in,
        a => a,
        b => b,
        c => c,
        d => d,
        q => q,
        valid_out => valid_out,
        overflow => overflow
    );

    stimulus : PROCESS
        VARIABLE test_num : INTEGER := 1;
        VARIABLE expected : INTEGER;

        FUNCTION calculate_expected(
            a, b, c, d : INTEGER
        ) RETURN INTEGER IS
        BEGIN
            RETURN ((a - b) * (1 + 3 * c) - 4 * d) / 2;
        END FUNCTION;

        PROCEDURE check_result(
            a_val, b_val, c_val, d_val : IN INTEGER;
            test_num : IN INTEGER
        ) IS
            VARIABLE actual : INTEGER;
        BEGIN

            WAIT UNTIL rising_edge(clk);
            valid_in <= '1';
            a <= to_signed(a_val, DATA_WIDTH);
            b <= to_signed(b_val, DATA_WIDTH);
            c <= to_signed(c_val, DATA_WIDTH);
            d <= to_signed(d_val, DATA_WIDTH);
            WAIT UNTIL rising_edge(clk);
            valid_in <= '0';

            WAIT FOR 2 * CLK_PERIOD;

            actual := to_integer(q);
            expected := calculate_expected(a_val, b_val, c_val, d_val);

            ASSERT actual = expected
            REPORT "Test " & INTEGER'image(test_num) &
                " failed! Expected: " & INTEGER'image(expected) &
                " Got: " & INTEGER'image(actual)
                SEVERITY error;
        END PROCEDURE;

    BEGIN
        reset <= '1';
        WAIT FOR CLK_PERIOD * 2;
        reset <= '0';
        WAIT FOR CLK_PERIOD;

        -- Тест 1: 
        check_result(10, 5, 2, 3, 1);

        -- Тест 2: 
        check_result(-20, 15, -4, 5, 2);

        -- Тест 3: 
        check_result(127, -128, 42, -127, 3);

        -- Тест 4: 
        check_result(100, 50, 30, 20, 4);

        WAIT FOR CLK_PERIOD * 5;
        REPORT "All tests completed successfully!";
        WAIT;
    END PROCESS;

END Behavioral;
