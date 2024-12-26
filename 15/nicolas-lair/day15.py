import re
from pathlib import Path
from collections import UserDict
from typing import Literal

PosType = tuple[int, int]
DirType = Literal['^', 'v', '>', '<']
WideBoxPosType = tuple[PosType, PosType]

class Warehouse(UserDict):
    def __init__(self, warehouse_str: list[str]):
        self.map_shape = len(warehouse_str), len(warehouse_str[0])
        warehouse_dict = {
            (i // self.map_shape[1], i % self.map_shape[1]): char for i, char in enumerate(''.join(warehouse_str))
        }
        super().__init__(warehouse_dict)

    def __repr__(self):
        """ Print warehouse as str for debugging """
        temp = [['-1']*self.map_shape[1] for _ in range(self.map_shape[0])]
        for pos, obj in self.items():
            temp[pos[0]][pos[1]] = obj
        return '\n'.join([''.join(t) for t in temp]) + '\n'

move_symbol: dict[DirType, PosType] = {
    "^": (-1, 0),
    "v": (1, 0),
    ">": (0, 1),
    "<": (0, -1),
}

def step(pos: PosType, direction: DirType) -> PosType:
    return pos[0] + move_symbol[direction][0], pos[1] + move_symbol[direction][1]

def move_part1(warehouse: Warehouse, pos: PosType, direction: DirType) -> (Warehouse, PosType):
    next_pos = step(pos, direction)
    if warehouse[next_pos] == '.':
        warehouse[pos] = '.'
        warehouse[next_pos] = '@'
        return warehouse, next_pos
    if warehouse[next_pos] == '#':
        return warehouse, pos
    
    # move objects if possible
    next_next_pos = next_pos
    while True:
        next_next_pos = step(next_next_pos, direction)
        if warehouse[next_next_pos] == '.':
            warehouse[pos] = '.'
            warehouse[next_pos] = '@'
            warehouse[next_next_pos] = 'O'
            return warehouse, next_pos
        if warehouse[next_next_pos] == '#':
            return warehouse, pos

def compute_gps_score(warehouse: Warehouse, char: str) -> int:
    return sum([100 * pos[0] + pos[1] for pos, obj in warehouse.items() if obj == char])

def expand_map(warehouse_str: str) -> str:
    warehouse_str = warehouse_str.replace('#', '##')
    warehouse_str = warehouse_str.replace('O', '[]')
    warehouse_str = warehouse_str.replace('.', '..')
    warehouse_str = warehouse_str.replace('@', '@.')
    return warehouse_str

def parse_input(input_data: str, expand: bool) -> (Warehouse, str, PosType):
    warehouse, directions = input_data.split('\n\n')
    if expand:
        warehouse = expand_map(warehouse)
    warehouse = warehouse.splitlines()
    warehouse_dict = Warehouse(warehouse)

    init_pos = re.search(r"@", ''.join(warehouse)).start()
    init_pos = (init_pos // len(warehouse[0]), init_pos % len(warehouse[0]))

    directions = ''.join(directions.split())
    return warehouse_dict, directions, init_pos

def part1(input_data: str) -> int:
    warehouse_dict, directions, pos = parse_input(input_data, expand=False)
    for d in directions:
        warehouse_dict, pos = move_part1(warehouse_dict, pos, d)
    return compute_gps_score(warehouse_dict)

def push_boxes_horizontally(warehouse: Warehouse, pos: PosType, direction: DirType) -> (Warehouse, PosType):
    next_pos = step(pos, direction)
    position_line = [next_pos]
    while True:
        position_line.append(step(position_line[-1], direction))
        next_next_pos = position_line[-1]
        if warehouse[next_next_pos] == '.':
            position_line = position_line[::-1]
            for pos1, pos2 in zip(position_line[1:], position_line[:-1]):
                warehouse[pos2] = warehouse[pos1]
            warehouse[pos] = '.'
            warehouse[next_pos] = '@'
            return warehouse, next_pos
        if warehouse[next_next_pos] == '#':
            return warehouse, pos
        assert warehouse[next_next_pos] in ['[', ']']

def move_box_vertically(warehouse: Warehouse, box_pos: WideBoxPosType, direction: DirType) -> (Warehouse, WideBoxPosType):
    next_pos = tuple(sorted((step(box_pos[0], direction), step(box_pos[1], direction))))

    left_side_move = (
            warehouse[next_pos[0]] == '.' or
            (warehouse[next_pos[0]] == '[' and move_box_vertically(warehouse, next_pos, direction)) or
            (warehouse[next_pos[0]] == ']' and move_box_vertically(warehouse, (step(next_pos[0], '<'), next_pos[0]), direction))
    )
    right_side_move = (
            warehouse[next_pos[1]] == '.' or
            (warehouse[next_pos[1]] == '[' and move_box_vertically(warehouse, (step(next_pos[1], '>'), next_pos[1]), direction))
    )

    if left_side_move and right_side_move:
        warehouse[next_pos[0]] = '['
        warehouse[next_pos[1]] = ']'
        warehouse[box_pos[0]] = '.'
        warehouse[box_pos[1]] = '.'
        return True
    return False

def push_boxes_vertically(warehouse: Warehouse, pos: PosType, direction: DirType) -> (Warehouse, PosType):
    next_pos = step(pos, direction)
    side = '<' if warehouse[next_pos] == ']' else '>'
    box_pos = next_pos, step(next_pos, side)
    warehouse_copy = warehouse.copy()
    if move_box_vertically(warehouse_copy, box_pos, direction):
        warehouse_copy[pos] = '.'
        warehouse_copy[next_pos] = '@'
        return warehouse_copy, next_pos
    else:
        return warehouse, pos

def move_part2(warehouse: Warehouse, pos: PosType, direction: DirType) -> (Warehouse, PosType):
    next_pos = step(pos, direction)
    if warehouse[next_pos] == '.':
        warehouse[pos] = '.'
        warehouse[next_pos] = '@'
        return warehouse, next_pos
    if warehouse[next_pos] == '#':
        return warehouse, pos
    if direction == "^" or direction == "v":
        return push_boxes_vertically(warehouse, pos, direction)
    if direction == "<" or direction == ">":
        return push_boxes_horizontally(warehouse, pos, direction)

def part2(input_data: str) -> int:
    warehouse_dict, directions, pos = parse_input(input_data, expand=True)
    for d in directions:
        warehouse_dict, pos = move_part2(warehouse_dict, pos, d)
    return compute_gps_score(warehouse_dict, char='[')

if __name__ == '__main__':

    data_file = "day15.txt"
    data_path = Path("data") / data_file
    input_data = data_path.read_text()
    
    print(part1(input_data))
    print(part2(input_data))

