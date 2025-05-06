def calculate_q(a: int, b: int, c: int, d: int) -> int:
   
    term1 = a - b
    term2 = 1 + 3 * c
    term3 = term1 * term2
    term4 = 4 * d
    result = (term3 - term4) // 2
    return result


if __name__ == "__main__":
    
    test_cases = [
        (10, 5, 2, 3),
        (-20, 15, -4, 5),
        (127, -128, 42, -127),
        (100, 50, 30, 20)
    ]

    for idx, (a, b, c, d) in enumerate(test_cases, 1):
        q = calculate_q(a, b, c, d)
        print(f"Test {idx}: a={a}, b={b}, c={c}, d={d} -> Q={q}")

    try:
        a = int(input("\nВведите a: "))
        b = int(input("Введите b: "))
        c = int(input("Введите c: "))
        d = int(input("Введите d: "))
        q = calculate_q(a, b, c, d)
        print(f"Результат: Q = {q}")
    except ValueError:
        print("Ошибка: Введите целые числа!")