from pathlib import Path
from itertools import product

def check_MSAMS(sub_list):
    """
    M.S
    .A.
    M.S
    """
    return sub_list[1][1] == "A" and sub_list[0][0] == sub_list[2][0] == "M" and sub_list[0][2] == sub_list[2][2] == "S"

def check_SMASM(sub_list):
    """
    S.M
    .A.
    S.M
    """
    return sub_list[1][1] == "A" and sub_list[0][0] == sub_list[2][0] == "S" and sub_list[0][2] == sub_list[2][2] == "M"

def check_MMASS(sub_list):
    """
    M.M
    .A.
    S.S
    """
    return sub_list[1][1] == "A" and sub_list[2][0] == sub_list[2][2] == "S" and sub_list[0][0] == sub_list[0][2] == "M"

def check_SSAMM(sub_list):
    """
    S.S
    .A.
    M.M
    """
    return sub_list[1][1] == "A" and sub_list[2][0] == sub_list[2][2] == "M" and sub_list[0][0] == sub_list[0][2] == "S"

def part2(input_data: str):
    lines = input_data.splitlines()
    x_mas_count = 0
    for i, j in product(range(len(lines) - 2), range(len(lines[0]) -2)):
        sub_list = [l[j:j+3] for l in lines[i:(i+3)]]
        x_mas_count += int(check_MSAMS(sub_list) or check_SMASM(sub_list) or check_MMASS(sub_list) or check_SSAMM(sub_list))
    return x_mas_count

if __name__ == "__main__":
    file = "day4.txt"
    data_file = Path.cwd() / "data" / file
    input_data = data_file.read_text(encoding="utf-8")
    print(part2(input_data))
