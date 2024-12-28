#! /usr/bin/env python3
from dataclasses import dataclass

@dataclass(frozen=True)
class Input:
    result: int
    factors: list[int]

def part1(input: list[Input]) -> int:
    return sum(map(lambda i: recurse(i.result, i.factors), input))

def recurse(result: int, factors: list[int]) -> int:
    if len(factors) == 1:
        return factors[0]
    
    sum = factors[0] + factors[1]
    prod = factors[0] * factors[1]
    concat = int(str(factors[0]) + str(factors[1]))

    if recurse(result, [sum] + factors[2:]) == result:
        return result

    if recurse(result, [prod] + factors[2:]) == result:
        return result

    if recurse(result, [concat] + factors[2:]) == result:
        return result

    return 0


def main():
    with open('day07.txt', 'r') as file:
        content = map(lambda l: l.split(':'), file.readlines())
        interize = lambda l: list(map(int, l.strip().split(' ')))
        content = map(lambda l: Input(result=int(l[0]), factors=interize(l[1])), content)
        content = list(content)
    
    count = part1(content)
    print(count)


if __name__ == '__main__':
    main()
