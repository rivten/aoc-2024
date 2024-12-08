from pathlib import Path

def build_page_order_dict(page_order_list: list[str]) -> dict[int, set[int]]:
    page_order_dict = {}
    for page_order in page_order_list:
        p1, p2 = map(int, page_order.split("|"))
        if p1 not in page_order_dict:
            page_order_dict[p1] = {p2}
        else:
            page_order_dict[p1].add(p2)
    return page_order_dict

def extend_page_order_dict(page_order_dict: dict[int: set[int]]) -> dict[int, set[int]]:
    value_len_sum = sum(map(len, page_order_dict.values()))
    new_value_len_sum = sum(map(len, page_order_dict.values())) + 1
    while new_value_len_sum > value_len_sum:
        value_len_sum = new_value_len_sum
        for p, v  in page_order_dict.items():
            page_order_dict[p].union(*[page_order_dict.get(p_, {}) for p_ in v])
        new_value_len_sum = sum(map(len, page_order_dict.values()))
    return page_order_dict

def get_valid_update(
        str_updates: list[str], page_order_dict: dict[int, set[int]]
) -> (list[list[int]],list[list[int]]):
    valid_updates = []
    invalid_updates = []
    for update in str_updates:
        update =  list(map(int, update.split(",")))
        is_valid = True
        for i, p in enumerate(update[::-1]):
            if bool(page_order_dict.get(p, set()).intersection(update[:(len(update) - i - 1)])):
                is_valid = False
                invalid_updates.append(update)
                break
        if is_valid:
            valid_updates.append(update)
    return valid_updates, invalid_updates

def order_invalid_updates(invalid_updates: list[list[int]], page_order_dict: dict[int, set[int]]) -> list[list[int]]:
    extend_page_order_dict(page_order_dict)
    ordered_updates = []
    for update in invalid_updates:
        new_update = [update[0]]
        for p in update[1:]:
            inserted = False
            for i, p_ in enumerate(new_update):
                if p_ in page_order_dict.get(p, {}):
                    new_update.insert(i, p)
                    inserted = True
                    break
            if not inserted:
                new_update.append(p)
        ordered_updates.append(new_update)
    return ordered_updates

def part1(input_data: str) -> int:
    page_order, updates = map(lambda x: x.splitlines(), input_data.split('\n\n'))
    page_order_dict = build_page_order_dict(page_order)
    valid_updates, _ = get_valid_update(updates, page_order_dict)

    res = sum([update[len(update) // 2] for update in valid_updates])
    return res

def part2(input_data: str) -> int:
    page_order, updates = map(lambda x: x.splitlines(), input_data.split('\n\n'))
    page_order_dict = build_page_order_dict(page_order)
    _, invalid_updates = get_valid_update(updates, page_order_dict)

    ordered_invalid_updates = order_invalid_updates(invalid_updates, page_order_dict)
    res = sum([update[len(update) // 2] for update in ordered_invalid_updates])
    return res


if __name__ == "__main__":
    file = "day5.txt"
    data_file = Path.cwd() / "data" / file
    input_data = data_file.read_text(encoding="utf-8")

    print(part1(input_data))
    print(part2(input_data))
