library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ExpressionCalculator is
    generic (
        DATA_WIDTH : integer := 8
    );
    port (
        clk        : in  std_logic;
        reset      : in  std_logic;
        valid_in   : in  std_logic;
        a          : in  signed(DATA_WIDTH-1 downto 0);
        b          : in  signed(DATA_WIDTH-1 downto 0);
        c          : in  signed(DATA_WIDTH-1 downto 0);
        d          : in  signed(DATA_WIDTH-1 downto 0);
        q          : out signed(2*DATA_WIDTH-1 downto 0);
        valid_out  : out std_logic;
        overflow   : out std_logic
    );
end ExpressionCalculator;

architecture Behavioral of ExpressionCalculator is
    -- Регистры входных данных
    signal a_reg, b_reg, c_reg, d_reg : signed(DATA_WIDTH-1 downto 0) := (others => '0');
    signal valid_pipeline             : std_logic_vector(1 downto 0) := "00";
    
    -- Промежуточные сигналы с корректной разрядностью
    signal sub_ab      : signed(DATA_WIDTH downto 0);                  -- 9 бит (8+1)
    signal mul_3c      : signed(DATA_WIDTH+1 downto 0);               -- 10 бит (8+2)
    signal add_1_3c    : signed(DATA_WIDTH+1 downto 0);               -- 10 бит
    signal mul_term    : signed(39 downto 0);                         -- 40 бит (20*20)
    signal mul_4d      : signed(DATA_WIDTH+1 downto 0);               -- 10 бит
    signal sub_result  : signed(39 downto 0);                         -- 40 бит
    signal div_result  : signed(39 downto 0);                         -- 40 бит
    signal overflow_reg: std_logic := '0';
begin

    -- Регистрация входных данных
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                a_reg <= (others => '0');
                b_reg <= (others => '0');
                c_reg <= (others => '0');
                d_reg <= (others => '0');
                valid_pipeline <= (others => '0');
                overflow_reg <= '0';
            else
                a_reg <= a;
                b_reg <= b;
                c_reg <= c;
                d_reg <= d;
                valid_pipeline <= valid_pipeline(0) & valid_in;
            end if;
        end if;
    end process;

    -- Вычислительный конвейер
    sub_ab   <= resize(a_reg, DATA_WIDTH+1) - resize(b_reg, DATA_WIDTH+1);
    mul_3c   <= resize(c_reg * 3, DATA_WIDTH+2);
    add_1_3c <= resize(mul_3c + 1, DATA_WIDTH+2);
    mul_term <= resize(sub_ab, 20) * resize(add_1_3c, 20);  -- 20 бит * 20 бит = 40 бит
    mul_4d   <= resize(d_reg, DATA_WIDTH+2) sll 2;
    sub_result <= mul_term - resize(mul_4d, 40);            -- 40 бит - 40 бит
    div_result <= shift_right(sub_result, 1);                -- 40 бит >> 1 = 40 бит

    -- Проверка переполнения
    process(clk)
    begin
        if rising_edge(clk) then
            if div_result > to_signed(2**(2*DATA_WIDTH-1)-1, div_result'length) or 
               div_result < to_signed(-2**(2*DATA_WIDTH-1), div_result'length) then
                overflow_reg <= '1';
            else
                overflow_reg <= '0';
            end if;
        end if;
    end process;

    -- Выходные регистры
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                q <= (others => '0');
                valid_out <= '0';
                overflow <= '0';
            else
                q <= resize(div_result, q'length);  -- Обрезание до 16 бит
                valid_out <= valid_pipeline(1);
                overflow <= overflow_reg;
            end if;
        end if;
    end process;

end Behavioral;