#! /usr/bin/env python3
import re
from dataclasses import dataclass
from itertools import takewhile, dropwhile, islice

@dataclass(frozen=True)
class Rule:
    x: int
    y: int

    def applies_to(self, n) -> bool:
        return n == self.x or n == self.y

    def is_correct(self, pages: [int]):
        try:
            first = pages.index(self.x)
            second = pages.index(self.y)
            return first < second
        except ValueError:
            return True

@dataclass
class Input:
    rules: [Rule]
    pages: [[int]]

def drop(count: int, iterable):
    return list(islice(iterable, 1, None))

def parse(content: [str]) -> Input:
    rules = takewhile(lambda x: x != '\n', content)
    page_list = filter(lambda x: x != '\n', (drop(1, dropwhile(lambda x: x != '\n', content))))

    return Input(
        rules=[Rule(int(match.group(1)), int(match.group(2))) for match in filter(lambda x: x != None, map(lambda x: re.match(r'(\d+)\|(\d+)', x), rules))],
        pages=[list(map(lambda n: int(n), page_str)) for page_str in map(lambda string: string.split(','), page_list)]
    )

def part1(input: Input) -> int:
    total = 0
    for pages in input.pages:
        active_rules = set()
        for page in pages:
            for rule in input.rules:
                if rule.applies_to(page):
                    #print(f'rule {rule} applies to {pages}')
                    active_rules.add(rule)
        
        if all([rule.is_correct(pages) for rule in active_rules]):
            middle = int(len(pages) / 2) 
            total += pages[middle]
    
    return total


def part2(content: Input):
    pass

def main():
    with open('day5.txt', 'r') as file:
        content = file.readlines()
    
    input = parse(content)
    print(part1(input))


if __name__ == '__main__':
    main()
