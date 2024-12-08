from typing import Callable
from pathlib import Path
import numpy as np
from enum import StrEnum
import re

import tqdm

class Direction(StrEnum):
    Up= "up"
    Down= "down"
    Right= "right"
    Left= "left"

def get_starting_position(lines: list[str], grid_shape: (int, int)) -> (int, int):
    guard_char = re.search(r'\^', ''.join(lines))
    return guard_char.start() // grid_shape[0], guard_char.start() % grid_shape[0]

def inventory_obstacles(lines: list[str], grid_shape: (int, int)) -> list[(int, int)]:
    obstacles = re.finditer(r'#', ''.join(lines))
    obs_pos = []
    for obs in obstacles:
        obs_pos.append((obs.start() // grid_shape[0], obs.start() % grid_shape[0]))
    return obs_pos

def vertical_move(down: bool) -> Callable[[tuple[int, int]], tuple[int, int]]:
    def move(position: (int, int)) -> (int, int):
        mv = 1 if down else -1
        return position[0] + mv, position[1]
    return move

def horizontal_move(right: bool) -> Callable[[tuple[int, int]], tuple[int, int]]:
    def move(position: (int, int)) -> (int, int):
        mv = 1 if right else -1
        return position[0], position[1] + mv
    return move

move_dict = {
    Direction.Up: vertical_move(down=False),
    Direction.Down: vertical_move(down=True),
    Direction.Left: horizontal_move(right=False),
    Direction.Right: horizontal_move(right=True),
}

def get_position_ahead(position: (int, int), direction: Direction) -> (int, int):
    return move_dict[direction](position)

def in_map(position, map_shape):
    return 0<=position[0]<map_shape[0] and 0<=position[1]<map_shape[1]

def turn_right(direction: Direction) -> Direction:
    if direction == Direction.Right:
        return Direction.Down
    if direction == Direction.Down:
        return Direction.Left
    if direction == Direction.Left:
        return Direction.Up
    if direction == Direction.Up:
        return Direction.Right

def move(direction: Direction, position: (int, int), obstacles: list[(int, int)]) -> ((int, int), Direction):
    pos_ahead = get_position_ahead(position, direction)
    if pos_ahead in obstacles:
        return position, turn_right(direction)
    return pos_ahead, direction

def part1(input_data: str) -> int:
    lines = input_data.splitlines()
    grid_shape = (len(lines), len(lines[0]))
    visited_positions = np.zeros(grid_shape, dtype=bool)
    obstacles_positions = inventory_obstacles(lines, grid_shape)
    position = get_starting_position(lines, grid_shape)
    direction = Direction.Up
    while in_map(position, grid_shape):
        visited_positions[position] = True
        position, direction = move(direction, position, obstacles_positions)
    print(visited_positions)
    return int(visited_positions.sum())


def in_loop(position: (int, int), direction: Direction, pos_history: list[((int, int), Direction)]) -> bool:
    return (position, direction) in pos_history

def get_trajectory(position: (int, int), direction: Direction, grid_shape: (int, int), obstacles_positions: list[(int, int)]) -> (list[((int, int), Direction)], bool):
    pos_history = [(position, direction)]
    loop = False
    while in_map(position, grid_shape) and not loop:
        position, direction = move(direction, position, obstacles_positions)
        loop = in_loop(position, direction, pos_history)
        pos_history.append((position, direction))
    return pos_history, loop


def part2(input_data: str) -> int:
    lines = input_data.splitlines()
    grid_shape = (len(lines), len(lines[0]))
    obstacles_pos = inventory_obstacles(lines, grid_shape)
    start_pos = get_starting_position(lines, grid_shape)
    start_dir = Direction.Up

    default_traj, _ = get_trajectory(start_pos, start_dir, grid_shape, obstacles_pos)
    obs_candidate = set([t[0] for t in default_traj])
    obs_candidate.remove(start_pos)
    valid_obstacles = []
    for pos in tqdm.tqdm(obs_candidate):
        _, loop_traj = get_trajectory(start_pos, start_dir, grid_shape, obstacles_pos + [pos])
        if loop_traj:
            valid_obstacles.append(pos)
    print(valid_obstacles)
    return len(valid_obstacles)

if __name__ == "__main__":
    file = "day6.txt"
    data_file = Path.cwd() / "data" / file
    input_data = data_file.read_text(encoding="utf-8")

    print(part1(input_data))
    print(part2(input_data))
