from typing import Callable, Iterator
from pathlib import Path


def find_valid_equations(input_data: str, eval_func: Callable[[list[int]], list[int]]) -> Iterator[int]:
    lines = input_data.splitlines()
    valid_equations = []
    for l in lines:
        test_value, equations = l.split(":")
        equations = list(map(int, equations.strip().split()))
        outputs = eval_func(equations)
        if int(test_value) in outputs:
            valid_equations.append(test_value)
    return map(int, valid_equations)

def part1(input_data: str) -> int:
    def eval_equation(equation: list[int]) -> list[int]:
        if len(equation) == 1:
            return equation
        else:
            return [*eval_equation([equation[0] + equation[1]] + equation[2:]),
                    *eval_equation([equation[0] * equation[1]] + equation[2:])]

    valid_equations = find_valid_equations(input_data, eval_equation)
    return sum(valid_equations)

def part2(input_data: str) -> int:
    def eval_equation(equation: list[int]) -> list[int]:
        if len(equation) == 1:
            return equation
        else:
            return [
                *eval_equation([equation[0] + equation[1]] + equation[2:]),
                *eval_equation([equation[0] * equation[1]] + equation[2:]),
                *eval_equation([int(str(equation[0]) + str(equation[1]))] + equation[2:]),
            ]
        
    valid_equations = find_valid_equations(input_data, eval_equation)
    return sum(valid_equations)


if __name__ == "__main__":
    file = "day7.txt"
    data_file = Path.cwd() / "data" / file
    input_data = data_file.read_text(encoding="utf-8")

    print(part1(input_data))
    print(part2(input_data))
