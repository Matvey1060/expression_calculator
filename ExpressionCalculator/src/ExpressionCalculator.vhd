
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ExpressionCalculator IS
    GENERIC (
        N : POSITIVE := 8
    );
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        valid_i : IN STD_LOGIC;
        a, b, c, d : IN signed(N - 1 DOWNTO 0);
        valid_o : OUT STD_LOGIC;
        q : OUT signed(N DOWNTO 0)
    );
END ENTITY ExpressionCalculator;

ARCHITECTURE Behavioral OF ExpressionCalculator IS
    SIGNAL sub_ab_reg : signed(N DOWNTO 0);
    SIGNAL mul_3c_reg : signed(N + 2 DOWNTO 0);
    SIGNAL mul_result_reg : signed(2 * N + 3 DOWNTO 0);
    SIGNAL sub_4d_reg : signed(2 * N + 3 DOWNTO 0);
    SIGNAL valid_reg1, valid_reg2, valid_reg3 : STD_LOGIC;
BEGIN
    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            sub_ab_reg <= (OTHERS => '0');
            mul_3c_reg <= (OTHERS => '0');
            mul_result_reg <= (OTHERS => '0');
            sub_4d_reg <= (OTHERS => '0');
            valid_reg1 <= '0';
            valid_reg2 <= '0';
            valid_reg3 <= '0';
        ELSIF rising_edge(clk) THEN
            
            IF valid_i = '1' THEN
                sub_ab_reg <= resize(a - b, N + 1);
                mul_3c_reg <= resize(1 + 3 * c, N + 3);
            END IF;
            valid_reg1 <= valid_i;

            IF valid_reg1 = '1' THEN
                mul_result_reg <= resize(sub_ab_reg * mul_3c_reg, 2 * N + 4);
            END IF;
            valid_reg2 <= valid_reg1;

            IF valid_reg2 = '1' THEN
                sub_4d_reg <= resize(mul_result_reg - shift_left(d, 2), 2 * N + 4);
            END IF;
            valid_reg3 <= valid_reg2;

            IF valid_reg3 = '1' THEN
                q <= sub_4d_reg(2 * N + 2 DOWNTO N + 2);
            END IF;
            valid_o <= valid_reg3;
        END IF;
    END PROCESS;
END ARCHITECTURE Behavioral;
