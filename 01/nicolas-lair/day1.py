from pathlib import  Path
from collections import Counter

def _read_list():
    with open(data_file, "r") as f:
        input_data = [map(int, line.split()) for line in f]
        llist, rlist = list(zip(*input_data))
    return llist, rlist

def part1():
    llist, rlist = _read_list()
    llist = sorted(llist)
    rlist = sorted(rlist)

    res: int = 0
    for a, b in zip(llist, rlist):
        res += abs(a - b)
    return res
  
def part2():
    llist, rlist = _read_list()
    rlist_counter = Counter(rlist)
    rlist_counter.update({k: 0 for k in rlist_counter})

    res = 0
    for a in llist:
        res += a * rlist_counter[a]

    return res

if __name__ == "__main__":
    file = "day1.txt"
    data_file = Path.cwd() / "data" / file

    res = part1()
    print("Part 1:", res)

    res = part2()
    print("Part 2:", res)
