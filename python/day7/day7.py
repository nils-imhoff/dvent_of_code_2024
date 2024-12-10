import sys
from itertools import product

def concatenate(a: int, b: int) -> int:
    return int(f"{a}{b}")

def create_equation(line: str) -> tuple[list[int], int]:
    result, *numbers = line.split()
    numbers = [int(x) for x in numbers]

    return numbers, int(result[:-1])

def evaluate(numbers: list[int], operators: tuple[str, ...], solution: int) -> int:
    result = numbers[0]

    for i, operator in enumerate(operators):
        if operator == "+":
            result += numbers[i + 1]
        elif operator == "*":
            result *= numbers[i + 1]
        elif operator == "||":
            result = concatenate(result, numbers[i + 1])

        if result > solution:
            return -1

    return result

def total_calibration_result(equations, operators_set):
    total = 0
    for numbers, result in equations:
        for operators in product(operators_set, repeat=len(numbers) - 1):
            if evaluate(numbers, operators, result) == result:
                total += result
                break

    return total

def read_input_file(file_path):
    with open(file_path, 'r') as file:
        lines = file.read().splitlines()
    return list(map(create_equation, lines))

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <input_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    equations = read_input_file(input_file)

    # Part 1: Using only "+" and "*"
    result_part_1 = total_calibration_result(equations, ["+", "*"])
    print("Part 1:", result_part_1)

    # Part 2: Using "+", "*", and "||"
    result_part_2 = total_calibration_result(equations, ["+", "*", "||"])
    print("Part 2:", result_part_2)
