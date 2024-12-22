from pathlib import Path
from itertools import product
from collections import Counter

def identify_regions(plant_map: list[list[str]]) -> (dict[str, list[tuple[int, int]]], list[list[str]]):
    map_shape = (len(plant_map), len(plant_map[0]))
    pos2region = [
        [plant_map[i][j] + str(len(plant_map) * i + j) for j in range(map_shape[1])]
        for i in range(map_shape[0])
    ]
    id2regions = {pos2region[i][j]: [(i, j)] for (i, j) in product(range(map_shape[0]), range(map_shape[1]))}

    n_regions = map_shape[0] * map_shape[1] + 1
    while n_regions != len(id2regions):
        n_regions = len(id2regions)
        for i, j in product(range(len(plant_map)), range(len(plant_map[0]))):
            neighbors = get_neighbors_in_map((i, j), map_shape)
            l = [(u, v) for (u,v) in neighbors if plant_map[u][v] == plant_map[i][j] and pos2region[u][v] != pos2region[i][j]]
            for u, v in l:
                pos_to_update = id2regions.pop(pos2region[u][v])
                id2regions[pos2region[i][j]] += pos_to_update
                for p in pos_to_update:
                    pos2region[p[0]][p[1]] = pos2region[i][j]
    return id2regions, pos2region


def get_neighbors_in_map(pos: tuple[int, int], map_shape: tuple[int, int]) -> list[tuple[int, int]]:
    neighboring_pos = [
        (pos[0], pos[1] + 1),
        (pos[0], pos[1] - 1),
        (pos[0] - 1, pos[1]),
        (pos[0] + 1, pos[1]),
    ]
    return [p for p in neighboring_pos if 0 <= p[0] < map_shape[0] and 0 <= p[1] < map_shape[1]]

def compute_perimeter(r: list[tuple[int, int]], pos2region: list[list[str]]) -> int:
    map_shape = (len(pos2region), len(pos2region[0]))
    p = 0
    for (i,j) in r:
        p += (i == 0) + (i == map_shape[0] - 1) + (j == 0) + (j ==map_shape[1] - 1)
        neighbors = get_neighbors_in_map((i, j), map_shape)
        p += sum(1 for u,v in neighbors if pos2region[i][j] != pos2region[u][v])
    return p

def part1(input_data: str) -> int:
    plant_map = list(map(list, input_data.splitlines()))
    regions2pos, pos2region = identify_regions(plant_map)
    price = sum(len(r_pos) * compute_perimeter(r_pos, pos2region) for r_pos in regions2pos.values())
    return price

def get_adjacent_plot(pos: tuple[int, int], pos2regions: list[list[str]]) -> list[str]:
    adj_pos = [
        (pos[0] - 1, pos[1] - 1),
        (pos[0] - 1, pos[1]),
        (pos[0], pos[1] - 1),
        (pos[0], pos[1]),
    ]
    adj_regions = []
    for p in adj_pos:
        if 0 <= p[0] < len(pos2regions) and 0 <= p[1] < len(pos2regions[0]):
            adj_regions.append(pos2regions[p[0]][p[1]])
        else:
            adj_regions.append(-len(adj_regions))
    return adj_regions

def compute_sides(
    plant_map: list[list[str]],
    regions2pos: dict[str, list[tuple[int, int]]],
    pos2region: list[list[str]]
) -> dict[str, int]:
    """
    The idea is to compute the number of edges by iterating over intersections.
    Count the number of timse a regions is represented around a given intersection:
        - 4 : Not an edge
        - 1 or 3 : the intersection is an edge for the region
        - 2 : if the regions are in diagonal around the intersection, this is a double edge
    """
    side_by_region = {reg: 0 for reg in regions2pos.keys()}
    for pos in product(range(len(plant_map) + 1), range(len(plant_map[0]) + 1)):
        adj_plot = get_adjacent_plot(pos, pos2region)
        reg_counter = Counter([r for r in adj_plot if r in side_by_region])
        for reg, c in reg_counter.items():
            if c == 1 or c == 3:
                side_by_region[reg] += 1
            elif c == 2 and (adj_plot[0] == adj_plot[3] or adj_plot[1] == adj_plot[2]):
                    side_by_region[reg] += 2
    return side_by_region

def part2(input_data: str) -> int:
    plant_map = list(map(list, input_data.splitlines()))
    regions2pos, pos2region = identify_regions(plant_map)
    side_by_region = compute_sides(plant_map, regions2pos, pos2region)
    price = sum([len(r_pos) * side_by_region[r_id] for r_id, r_pos in regions2pos.items()])
    return price

if __name__ == '__main__':

    data_file = "day12.txt"
    data_path = Path("data") / data_file
    input_data = data_path.read_text()

    print(part1(input_data))
    print(part2(input_data))
