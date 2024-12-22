import re
from pathlib import Path

def part1(input_data: str) -> int:
    machines = input_data.split('\n\n')
    cost = 0
    for m in machines:
        Ax, Ay, Bx, By, Tx, Ty = map(int, re.findall(r"\d+", m))
        a_push = (Tx*By - Ty*Bx) / (Ax*By - Ay*Bx)
        b_push = (Tx - Ax * a_push) / Bx
        if a_push.is_integer() and b_push.is_integer():
            cost += int(a_push * 3 + b_push)
    return cost


def part2(input_data: str) -> int:
    machines = input_data.split('\n\n')
    cost = 0
    for m in machines:
        Ax, Ay, Bx, By, Tx, Ty = map(int, re.findall(r"\d+", m))
        Tx += 10000000000000
        Ty += 10000000000000
        a_push = (Tx * By - Ty * Bx) / (Ax * By - Ay * Bx)
        b_push = (Tx - Ax * a_push) / Bx
        if a_push.is_integer() and b_push.is_integer():
            cost += int(a_push * 3 + b_push)
    return cost

if __name__ == '__main__':

    data_file = "day13.txt"
    data_path = Path("data") / data_file
    input_data = data_path.read_text()

    print(part1(input_data))
    print(part2(input_data))

