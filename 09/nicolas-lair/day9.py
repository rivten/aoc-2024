from pathlib import Path
from itertools import accumulate

def update_free_space_idx(idx: int, compact_disk: list[str]) -> int:
    idx +=1
    while compact_disk[idx] != '.':
        idx+=1
    return idx

def update_last_file_idx(idx: int, compact_disk: list[str]) -> int:
    idx -= 1
    while compact_disk[idx] == '.':
        idx -= 1
    return idx

def checksum(disk) -> int:
    return sum(i*k for i, k in enumerate(disk) if isinstance(k, int))

def part1(input_data: str) -> int:
    disk = list(map(int, list(input_data.strip())))
    disk_size = sum(disk)
    full_size_disk = ['.'] * disk_size

    cum_sum_disk = 0
    for i, k in enumerate(disk):
        if i % 2 == 0:
            full_size_disk[cum_sum_disk:cum_sum_disk+k] = [i // 2] * k
        cum_sum_disk += k

    free_space_idx = disk[0]
    last_file_idx = len(full_size_disk) - 1
    compacted_disk = full_size_disk.copy()
    while last_file_idx >= free_space_idx:
        compacted_disk[free_space_idx] = compacted_disk[last_file_idx]
        compacted_disk[last_file_idx] = '.'
        free_space_idx = update_free_space_idx(free_space_idx, compacted_disk)
        last_file_idx = update_last_file_idx(last_file_idx, compacted_disk)

    return checksum(compacted_disk)

def get_file_pos_in_disk(file_pos: int, disk: list[int]) -> int:
    return sum(disk[:2*file_pos])

def part2(input_data: str) -> int:
    disk = list(map(int, list(input_data.strip())))
    disk_size = sum(disk)
    files = [block_len for i, block_len in enumerate(disk) if i % 2 == 0]
    free_space_len = [block_len for i, block_len in enumerate(disk) if i % 2 == 1]
    free_space_idx = [block_len for i, block_len in enumerate(accumulate(disk)) if i % 2 == 0]
    full_size_disk = ['.'] * disk_size
    cum_sum_disk = 0
    for i, k in enumerate(disk):
        if i % 2 == 0:
            full_size_disk[cum_sum_disk:cum_sum_disk+k] = [i // 2] * k
        cum_sum_disk += k

    compacted_disk = full_size_disk.copy()
    for f_idx, f_len in list(enumerate(files))[::-1]:
        pos_in_disk = get_file_pos_in_disk(f_idx, disk)
        s_idx = 0
        while free_space_idx[s_idx] < pos_in_disk:
            if f_len <= free_space_len[s_idx]:
                compacted_disk[free_space_idx[s_idx]:free_space_idx[s_idx]+f_len] = [f_idx]*f_len
                compacted_disk[pos_in_disk:pos_in_disk+f_len] = ['.']*f_len
                free_space_len[s_idx] -= f_len
                free_space_idx[s_idx] += f_len
                break
            s_idx+=1

    return checksum(compacted_disk)


if __name__ == '__main__':

    data_file = "day9.txt"
    data_path = Path("data") / data_file
    input_data = data_path.read_text()

    print(part1(input_data))
    print(part2(input_data))

