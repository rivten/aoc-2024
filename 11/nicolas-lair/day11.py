from pathlib import Path
from functools import cache

def blink(stone_line: list[int]) -> list[int]:
    new_stone_line = []
    for stone in stone_line:
        if stone == 0:
            new_stone_line.append(1)
        elif len(str(stone)) % 2 == 0:
            s = str(stone)
            new_stone_line += [int(s[len(s) // 2:]), int(s[:len(s) // 2])]
        else:
            new_stone_line.append(stone * 2024)
    return new_stone_line

def part1(input_data: str) -> int:
    stone_line = list(map(int, input_data.split(" ")))
    for _ in range(25):
        stone_line = blink(stone_line)
    return len(stone_line)

@cache
def process_stone(stone: int, k = 1) -> int:
    if k == 0:
        return 1
    if stone == 0:
        return process_stone(1, k - 1)
    if len(str(stone)) % 2 == 0:
        s = str(stone)
        return process_stone(int(s[len(s) // 2:]), k - 1) + process_stone(int(s[:len(s) // 2]), k - 1)
    return process_stone(stone * 2024, k - 1)

def part2(input_data: str, k=75) -> int:
    stone_line = list(map(int, input_data.split(" ")))
    return sum([process_stone(stone, k=k) for stone in stone_line])


if __name__ == '__main__':

    data_file = "day11.txt"
    data_path = Path("data") / data_file
    input_data = data_path.read_text()

    print(part1(input_data))
    print(part2(input_data, k=25))
    print(part2(input_data))

