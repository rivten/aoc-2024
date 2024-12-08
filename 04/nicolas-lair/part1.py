from pathlib import Path
import re


def get_cols(lines):
    cols = [[lines[j][i] for j in range(len(lines))] for i in range(len(lines[0]))]
    cols = list(map(lambda x: "".join(x), cols))
    return cols


def get_diag_north_east(lines, cols):
    diag_up = []
    for n in range(len(lines) + len(cols) - 1):
        elt = ''
        for i in range(len(lines)):
            if n - i >= 0:
                try:
                    elt += lines[i][n-i]
                except IndexError:
                    continue
        diag_up.append(elt)
    return diag_up

def get_diag_south_east(lines, cols):
    diag_down = []
    for i in range(len(lines) - 1, 0 , -1):
        elt = ''
        for col_idx, line_idx in enumerate(range(i, len(lines))):
            elt += lines[line_idx][col_idx]
        diag_down.append(elt)
    for i in range(len(cols)):
        elt = ''
        for line_idx, col_idx in enumerate(range(i, len(cols))):
            elt += lines[line_idx][col_idx]
        diag_down.append(elt)
    return diag_down

def part1(input_data:str):
    lines = input_data.splitlines()
    cols = get_cols(lines)
    diag_down = get_diag_south_east(lines, cols)
    diag_up = get_diag_north_east(lines, cols)

    search_list = sum([lines, cols, diag_up, diag_down], [])
    xmas_count = 0
    xmas_count += sum(map(lambda l: len(re.findall(r'(XMAS)', l)), search_list))
    xmas_count += sum(map(lambda l: len(re.findall(r'(SAMX)', l)), search_list))
    return xmas_count

if __name__ == "__main__":
    file = "day4.txt"
    data_file = Path.cwd() / "data" / file
    input_data = data_file.read_text(encoding="utf-8")
    print(part1(input_data))
