from pathlib import Path
from itertools import product

def get_lvl_pos(topo_map: list[list[int]], lvl: int) -> set[tuple[int, int]]:
    pos =set((i,j) for i, j in product(range(len(topo_map)), range(len(topo_map[0]))) if topo_map[i][j] == lvl)
    return pos

def get_neighboring_tile(pos: tuple[int, int], map_shape: tuple[int, int]) -> list[tuple[int, int]]:
    neighboring_pos = [
        (pos[0], pos[1] + 1),
        (pos[0], pos[1] - 1),
        (pos[0] - 1, pos[1]),
        (pos[0] + 1, pos[1]),
    ]
    return [p for p in neighboring_pos if 0 <= p[0] < map_shape[0] and 0 <= p[1] < map_shape[1]]

def find_trail_ends(start: tuple[int, int], topo_map: list[list[int]]) -> set[tuple[int, int]]:
    # print(start)
    if topo_map[start[0]][start[1]] == 9:
        return {start}

    neighboring_pos = get_neighboring_tile(start, (len(topo_map), len(topo_map[0])))
    next_pos = [pos for pos in neighboring_pos if topo_map[pos[0]][pos[1]] - topo_map[start[0]][start[1]] == 1]
    return set().union(*[find_trail_ends(pos, topo_map) for pos in next_pos])

def find_trails(start: tuple[int, int], topo_map: list[list[int]]) -> list[list[tuple[int, int]]]:
    current_trail = [start]
    if topo_map[start[0]][start[1]] == 9:
        return [current_trail]

    neighboring_pos = get_neighboring_tile(start, (len(topo_map), len(topo_map[0])))
    next_pos = [pos for pos in neighboring_pos if topo_map[pos[0]][pos[1]] - topo_map[start[0]][start[1]] == 1]
    return sum([[current_trail + end_trail for end_trail in find_trails(pos, topo_map)] for pos in next_pos], [])


def part1(input_data: str) -> int:
    topo_map = list(map(lambda l: list(map(int, l)), map(list, input_data.splitlines())))
    start_points = get_lvl_pos(topo_map, lvl=0)
    return sum([len(find_trail_ends(s, topo_map)) for s in start_points])

def part2(input_data: str) -> int:
    topo_map = list(map(lambda l: list(map(int, l)), map(list, input_data.splitlines())))
    start_points = get_lvl_pos(topo_map, lvl=0)
    return sum([len(find_trails(s, topo_map)) for s in start_points])


if __name__ == '__main__':

    data_file = "day10.txt"
    data_path = Path("data") / data_file
    input_data = data_path.read_text()

    print(part1(input_data))
    print(part2(input_data))

