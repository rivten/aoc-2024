from pathlib import Path
import re
from itertools import combinations


def get_antenna_positions(lines, grid_shape):
    antenna_type = re.findall(r'[^\.]', ''.join(lines))
    antenna_positions = {k: [] for k in antenna_type}

    for antenna in re.finditer(r'[^\.]', ''.join(lines)):
        antenna_positions[antenna.group()].append((antenna.start() // grid_shape[0], antenna.start() % grid_shape[0]))
    return antenna_positions

def get_sym(pos1, pos2) -> tuple[int, int]:
    return 2 * pos1[0] - pos2[0], 2 * pos1[1] - pos2[1]

def in_map(position, map_shape) -> bool:
    return 0<=position[0]<map_shape[0] and 0<=position[1]<map_shape[1]

def get_anti_node(pos1, pos2) -> set[tuple[int, int]]:
    return {get_sym(pos1, pos2), get_sym(pos2, pos1)}

def part1(input_data: str) -> int:
    lines = input_data.splitlines()
    map_shape = len(lines), len(lines[0])
    antenna_positions = get_antenna_positions(lines, map_shape)

    anti_node_pos = set()
    for ant_type, ant_pos in antenna_positions.items():
        for ant_1, ant_2 in combinations(ant_pos, 2):
            anti_node_pos = anti_node_pos.union(get_anti_node(ant_1, ant_2))
    return len([posix for posix in anti_node_pos if in_map(posix, map_shape)])


def get_harmonic_antinode(pos1, pos2, map_shape) -> set[tuple[int, int]]:
    antinodes = [pos1, pos2]
    while in_map((next_node:= get_sym(antinodes[-1], antinodes[-2])), map_shape):
        antinodes.append(next_node)
    return set(antinodes)

def part2(input_data: str) -> int:
    lines = input_data.splitlines()
    map_shape = len(lines), len(lines[0])
    antenna_positions = get_antenna_positions(lines, map_shape)

    anti_node_pos = set()
    for ant_type, ant_pos in antenna_positions.items():
        for ant_1, ant_2 in combinations(ant_pos, 2):
            anti_node_pos = anti_node_pos.union(get_harmonic_antinode(ant_1, ant_2, map_shape))
            anti_node_pos = anti_node_pos.union(get_harmonic_antinode(ant_2, ant_1, map_shape))
    return len(anti_node_pos)

if __name__ == '__main__':

    data_file = "day8.txt"
    data_path = Path("data") / data_file
    input_data = data_path.read_text()

    print(part1(input_data))
    print(part2(input_data))

