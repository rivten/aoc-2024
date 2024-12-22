import re
from pathlib import Path
from functools import reduce
import numpy as np
from PIL import Image

def move(pos: tuple[int, int], v: tuple[int, int], map_shape: tuple[int, int], seconds: int = 1) -> tuple[int, int]:
    new_pos = pos[0] + v[0] * seconds, pos[1] + v[1] * seconds
    new_pos = new_pos[0] % map_shape[0], new_pos[1] % map_shape[1]
    return new_pos

def move_all_robots(
        robots: list[tuple[tuple[int, int], tuple[int, int]]],
        map_shape: tuple[int, int],
        seconds: int
) -> list[tuple[tuple[int, int], tuple[int, int]]]:
    return [(move(pos, v, map_shape, seconds), v) for pos, v in robots]

def safety_factor(robot_pos_list: list[tuple[int, int]], map_shape: tuple[int, int]) -> int:
    quadrants = {i: [] for i in range(4)}
    for pos in robot_pos_list:
        if pos[0] < (map_shape[0] - 1) / 2:
            if pos[1] < (map_shape[1] - 1) / 2:
                quadrants[0].append(pos)
            elif pos[1] > (map_shape[1] - 1) / 2:
                quadrants[1].append(pos)
        elif pos[0] > (map_shape[0] - 1) / 2:
            if pos[1] < (map_shape[1] - 1) / 2:
                quadrants[2].append(pos)
            elif pos[1] > (map_shape[1] - 1) / 2:
                quadrants[3].append(pos)
    return reduce(lambda x, y: x*y, [len(q) for q in quadrants.values()], 1)

def part1(input_data: str, map_shape: tuple[int, int]) -> int:
    robots = input_data.splitlines()
    robots = [map(int, re.findall(r"(-*\d+)", r)) for r in robots]
    robots = [((x, y), (vx, vy)) for x, y, vx, vy in robots]
    final_robots = move_all_robots(robots, map_shape, 100)
    return safety_factor([pos for pos, v in final_robots], map_shape)

def part2(input_data: str, map_shape: tuple[int, int]) -> int:
    robots = input_data.splitlines()
    robots = [map(int, re.findall(r"(-*\d+)", r)) for r in robots]
    robots = [((x, y), (vx, vy)) for x, y, vx, vy in robots]
    robots = move_all_robots(robots, map_shape, 19)
    # 76 determine by looking at generated images
    for i in range(76):
        robots = move_all_robots(robots, map_shape, 103)
        schema = np.zeros(map_shape, dtype=np.uint8)
        for pos, _ in robots: schema[pos] = 255
        Image.fromarray(schema, mode='L').save(Path(__file__).parent / "data" / "out" / f"schema{i+1}.jpg")
    return  19 + 76 * 103

if __name__ == '__main__':

    data_file = "day14.txt"
    data_path = Path("data") / data_file
    input_data = data_path.read_text()

    map_shape = (101, 103)
    print(part1(input_data, map_shape = map_shape))
    print(part2(input_data, map_shape = map_shape))

