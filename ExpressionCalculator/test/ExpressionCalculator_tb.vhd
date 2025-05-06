library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use STD.TEXTIO.ALL;

entity ExpressionCalculator_tb is
end ExpressionCalculator_tb;

architecture Behavioral of ExpressionCalculator_tb is
    constant DATA_WIDTH  : integer := 8;
    constant CLK_PERIOD : time := 10 ns;

    -- Сигналы для DUT
    signal clk      : std_logic := '0';
    signal reset    : std_logic := '1';
    signal valid_in : std_logic := '0';
    signal a, b, c, d : signed(DATA_WIDTH-1 downto 0) := (others => '0');
    signal q        : signed(2*DATA_WIDTH-1 downto 0);
    signal valid_out : std_logic;
    signal overflow : std_logic;

    -- Компонент для тестирования
    component ExpressionCalculator is
        generic ( DATA_WIDTH : integer );
        port (
            clk, reset, valid_in : in  std_logic;
            a, b, c, d          : in  signed(DATA_WIDTH-1 downto 0);
            q                   : out signed(2*DATA_WIDTH-1 downto 0);
            valid_out, overflow : out std_logic
        );
    end component;

begin
    -- Генератор тактового сигнала
    clk <= not clk after CLK_PERIOD/2;

    -- Подключение DUT
    DUT: ExpressionCalculator
        generic map (DATA_WIDTH => DATA_WIDTH)
        port map (
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

    -- Основной процесс тестирования
    stimulus: process
        variable test_num : integer := 1;
        variable expected : integer;

        -- Функция для расчета ожидаемого значения
        function calculate_expected(
            a, b, c, d : integer
        ) return integer is
        begin
            return ((a - b) * (1 + 3*c) - 4*d) / 2;
        end function;

        -- Процедура проверки результата
        procedure check_result(
            a_val, b_val, c_val, d_val : in integer;
            test_num : in integer
        ) is
            variable actual : integer;
        begin
            -- Подача данных
            wait until rising_edge(clk);
            valid_in <= '1';
            a <= to_signed(a_val, DATA_WIDTH);
            b <= to_signed(b_val, DATA_WIDTH);
            c <= to_signed(c_val, DATA_WIDTH);
            d <= to_signed(d_val, DATA_WIDTH);
            wait until rising_edge(clk);
            valid_in <= '0';

            -- Ожидание результата (латентность = 2 такта)
            wait for 2*CLK_PERIOD;

            -- Проверка результата
            actual := to_integer(q);
            expected := calculate_expected(a_val, b_val, c_val, d_val);

            assert actual = expected
                report "Test " & integer'image(test_num) & 
                       " failed! Expected: " & integer'image(expected) & 
                       " Got: " & integer'image(actual)
                severity error;
        end procedure;

    begin
        -- Инициализация сброса
        reset <= '1';
        wait for CLK_PERIOD*2;
        reset <= '0';
        wait for CLK_PERIOD;

        -- Тест 1: Базовый случай
        check_result(10, 5, 2, 3, 1);  -- Ожидаемый результат: (5*7 - 12)/2 = 23

        -- Тест 2: Отрицательные значения
        check_result(-20, 15, -4, 5, 2);  -- (-35*(-11) - 20)/2 = 182

        -- Тест 3: Граничные значения для 8 бит
        check_result(127, -128, 42, -127, 3);  -- (255*127 - (-508))/2 = 17035

        -- Тест 4: Проверка переполнения
        check_result(100, 50, 30, 20, 4);  -- (50*91 - 80)/2 = 2235

        -- Завершение симуляции
        wait for CLK_PERIOD*5;
        report "All tests completed successfully!";
        wait;
    end process;

end Behavioral;