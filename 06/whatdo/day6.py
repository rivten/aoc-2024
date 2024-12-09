#! /usr/bin/env python3
from dataclasses import dataclass

@dataclass(frozen=True)
class Vector:
    x: int
    y: int

    def __add__(self, vector):
        return Vector(self.x + vector.x, self.y + vector.y)

    def rotate90(self):
        return Vector(-self.y, self.x)
    
    def is_in_bounds(self, graph) -> bool:
        return self.y >= 0 and self.y < len(graph) and self.x >= 0 and self.x < len(graph[0])

@dataclass(frozen=True)
class Position:
    position: Vector
    direction: Vector

def step(graph: list[str], current: Position, visited: set[Vector], positions: set[Vector], extra: Vector=None) -> (Position, bool):
    visited.add(current)
    positions.add(current.position)

    position, direction = current.position, current.direction
    next = position + direction
    
    if not next.is_in_bounds(graph):
        return current, False

    if graph[next.y][next.x] == '#' or next == extra:
        direction = direction.rotate90()
        next = position + direction
    
    if not next.is_in_bounds(graph):
        return current, False

    return Position(next, direction), True


def part1(graph: list[str]) -> (Vector, set[Vector]):
    for y, row in enumerate(graph):
        for x, c in enumerate(row):
            if c == '^':
                start = Vector(x, y)
    
    direction = Vector(0, -1)
    current = Position(start, direction)
    visited = set()
    positions = set()
    while True:
        current, can_continue = step(graph, current, visited, positions)
        if not can_continue:
            break

    return start, positions

def part2(graph: list[str]) -> int:
    start, original_route = part1(graph)
    print(f'checking {len(original_route) - 1} positions')
    count = 0
    for position in original_route - { start }:
        current = Position(start, Vector(0, -1))
        visited = set()
        positions = set()

        while True:
            if current in visited:
                print(f'can place obstacle at {position}')
                count += 1
                break
            current, can_continue = step(graph, current, visited, positions, position)
            if not can_continue:
                print(f'can not place obstacle at {position}')
                break

    return count

def main():
    with open('day6.txt', 'r') as file:
        content = list(map(lambda line: line[:-1], file.readlines()))
    
    print(content[0])
    count = part2(content)
    print(count)


if __name__ == '__main__':
    main()
