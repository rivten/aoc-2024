#! /usr/bin/python3
import re
from functools import reduce

mul_pattern = re.compile(r'mul\((\d+),(\d+)\)')

def find_mul_part1(content: str) -> [int]:
    pattern = re.compile(r'mul\((\d+),(\d+)\)')
    return [int(a) * int(b) for (a, b) in pattern.findall(content)]

def find_mul_part2(content: str) -> [int]:
    pattern = re.compile(r'(do\(\)|don\'t\(\)|mul\(\d+,\d+\))')
    enabled = True
    products = []
    for instr in pattern.findall(content):
        #instr = instr[0]
        print(f"instr is {instr}")
        match instr:
            case 'do()':
                enabled = True
            case 'don\'t()':
                enabled = False
            case _:
                if not enabled:
                    continue
                match = mul_pattern.match(instr)
                a, b = match.group(1), match.group(2)
                products.append(int(a) * int(b))

    return products

def main():
    with open('day3.txt', 'r') as file:
        content = file.read()

    print(sum(find_mul_part2(content)))
    


if __name__ == '__main__':
    main()
