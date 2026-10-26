"""Reorder authored options and their feedback together, without changing prose.

Editorial operation only. Runtime questions always retain their fixed order.
"""
import argparse
from pathlib import Path
import random


def rebalance(path):
    lines = path.read_text(encoding='utf-8').splitlines()
    positions = [i for i, line in enumerate(lines) if line.startswith('@q ')]
    if len(positions) != 40:
        raise ValueError('Only complete forty-question courses can be rebalanced')
    targets = [0] * 14 + [1] * 13 + [2] * 13
    random.Random(path.stem).shuffle(targets)
    for index, target in zip(positions, targets):
        fields = [part.strip() for part in lines[index][3:].rstrip('|').split('|')]
        previous = int(fields[5])
        shift = (target - previous) % 3
        for start in [2, 7]:
            original = fields[start:start + 3]
            reordered = [None] * 3
            for old, value in enumerate(original):
                reordered[(old + shift) % 3] = value
            fields[start:start + 3] = reordered
        fields[5] = str(target)
        lines[index] = '@q ' + '|'.join(fields)
    path.write_text('\n'.join(lines) + '\n', encoding='utf-8')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('paths', type=Path, nargs='+')
    for source in parser.parse_args().paths:
        rebalance(source)
