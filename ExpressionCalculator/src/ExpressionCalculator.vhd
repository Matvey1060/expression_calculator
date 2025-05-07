LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ExpressionCalculator IS
    GENERIC (
        DATA_WIDTH : INTEGER := 8
    );
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        valid_in : IN STD_LOGIC;
        a : IN signed(DATA_WIDTH - 1 DOWNTO 0);
        b : IN signed(DATA_WIDTH - 1 DOWNTO 0);
        c : IN signed(DATA_WIDTH - 1 DOWNTO 0);
        d : IN signed(DATA_WIDTH - 1 DOWNTO 0);
        q : OUT signed(2 * DATA_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
        valid_out : OUT STD_LOGIC := '0';
        overflow : OUT STD_LOGIC := '0'
    );
END ExpressionCalculator;

ARCHITECTURE Behavioral OF ExpressionCalculator IS

    SIGNAL a_reg, b_reg, c_reg, d_reg : signed(DATA_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL valid_pipeline : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');

    SIGNAL sub_ab : signed(DATA_WIDTH DOWNTO 0) := (OTHERS => '0');
    SIGNAL mul_3c : signed(DATA_WIDTH + 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL add_1_3c : signed(DATA_WIDTH + 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mul_term : signed(39 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mul_4d : signed(DATA_WIDTH + 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL sub_result : signed(39 DOWNTO 0) := (OTHERS => '0');
    SIGNAL div_result : signed(39 DOWNTO 0) := (OTHERS => '0');
    SIGNAL overflow_reg : STD_LOGIC := '0';
BEGIN

    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                a_reg <= (OTHERS => '0');
                b_reg <= (OTHERS => '0');
                c_reg <= (OTHERS => '0');
                d_reg <= (OTHERS => '0');
                valid_pipeline <= (OTHERS => '0');
                overflow_reg <= '0';
            ELSE
                a_reg <= a;
                b_reg <= b;
                c_reg <= c;
                d_reg <= d;
                valid_pipeline <= valid_pipeline(0) & valid_in;
            END IF;
        END IF;
    END PROCESS;

    sub_ab <= resize(a_reg, DATA_WIDTH + 1) - resize(b_reg, DATA_WIDTH + 1);
    mul_3c <= resize(c_reg * 3, DATA_WIDTH + 2);
    add_1_3c <= resize(mul_3c + 1, DATA_WIDTH + 2);
    mul_term <= resize(sub_ab, 20) * resize(add_1_3c, 20);
    mul_4d <= resize(d_reg, DATA_WIDTH + 2) SLL 2;
    sub_result <= mul_term - resize(mul_4d, 40);
    div_result <= shift_right(sub_result, 1);

    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF div_result > to_signed(2 ** (2 * DATA_WIDTH - 1) - 1, div_result'length) OR
                div_result < to_signed(-2 ** (2 * DATA_WIDTH - 1), div_result'length) THEN
                overflow_reg <= '1';
            ELSE
                overflow_reg <= '0';
            END IF;
        END IF;
    END PROCESS;

    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                q <= (OTHERS => '0');
                valid_out <= '0';
                overflow <= '0';
            ELSE
                q <= resize(div_result, q'length);
                valid_out <= valid_pipeline(1);
                overflow <= overflow_reg;
            END IF;
        END IF;
    END PROCESS;

END Behavioral;