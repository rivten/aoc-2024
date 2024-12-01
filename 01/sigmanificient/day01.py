from collections import Counter
from pathlib import Path

lines = Path("input").read_text().splitlines()

split_cols = lambda cols: (int(c) for c in cols.split(' ') if c)
data = [sorted(col) for col in zip(*map(split_cols, lines))]

print(sum(abs(a - b) for (a, b) in zip(*data)))

counts = Counter(data.pop())
print(sum(counts[e] * e for e in data.pop()))
