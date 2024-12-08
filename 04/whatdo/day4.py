#! /usr/bin/env python3

def search_direction(word: str, content: [str], start: (int, int), x_dir: int, y_dir: int) -> bool:
    length = len(word)
    start_x, start_y = start
    for i in range(length):
        x = start_x + x_dir * i
        y = start_y + y_dir * i
        if y < 0 or y >= len(content):
            return False

        line = content[y]
        if x < 0 or x >= len(line):
            return False
        
        if line[x] != word[i]:
            return False

    return True

def search_cross(word: str, content: [str], start: (int, int), x_dir: int, y_dir: int) -> bool:
    length = len(word)
    half = int(length / 2)
    first = start[0] + -x_dir * half, start[1] + -y_dir * half
    start_x, start_y = first

    for i in range(length):
        x = start_x + x_dir * i
        y = start_y + y_dir * i
        if y < 0 or y >= len(content):
            return False

        line = content[y]
        if x < 0 or x >= len(line):
            return False
        
        if line[x] != word[i]:
            return False

    return True

def part1(content: [str]) -> int:
    count = 0
    directions = [
            (1, 0),
            (1, 1),
            (1, -1),
            (-1, 0),
            (-1, 1),
            (-1, -1),
            (0, 1),
            (0, -1)
    ]

    for y, line in enumerate(content):
        for x, _ in enumerate(line):
            for x_dir, y_dir in directions:
                if search_direction('XMAS', content, (x, y), x_dir, y_dir):
                    count += 1
    
    return count


def part2(content: [str]) -> int:
    count = 0
    directions = [
            (1, 1),
            (1, -1),
            (-1, 1),
            (-1, -1),
    ]

    for y, line in enumerate(content):
        for x, _ in enumerate(line):
            direction_count = 0
            for x_dir, y_dir in directions:
                if search_cross('MAS', content, (x, y), x_dir, y_dir):
                    direction_count += 1

                if direction_count == 2:
                    count += 1
                    break
    
    return count


def main():
    with open('day4.txt', 'r') as file:
        content = file.readlines()
    
    count = part2(content)
    print(count)


if __name__ == '__main__':
    main()
