"""Inspect PNG metadata and alpha without editing generated artwork."""
import hashlib
import json
from pathlib import Path
import re
import struct
import zlib

ROOT = Path(__file__).resolve().parents[1]


def inspect_png(raw):
    if raw[:8] != b'\x89PNG\r\n\x1a\n':
        raise ValueError('Invalid PNG signature')
    offset, compressed = 8, bytearray()
    while offset < len(raw):
        length = struct.unpack('>I', raw[offset:offset + 4])[0]
        kind, chunk = raw[offset + 4:offset + 8], raw[offset + 8:offset + 8 + length]
        if kind == b'IHDR':
            width, height, depth, color, compression, filtering, interlace = struct.unpack('>IIBBBBB', chunk)
            if (depth, color, compression, filtering, interlace) != (8, 6, 0, 0, 0):
                raise ValueError('Expected noninterlaced 8-bit RGBA PNG')
        if kind == b'IDAT':
            compressed.extend(chunk)
        offset += length + 12
    pixels = zlib.decompress(compressed)
    stride, previous, cursor = width * 4, bytearray(width * 4), 0
    low, high = 255, 0
    for _ in range(height):
        method = pixels[cursor]
        row = bytearray(pixels[cursor + 1:cursor + 1 + stride])
        for x in range(stride):
            left, above = row[x - 4] if x >= 4 else 0, previous[x]
            corner = previous[x - 4] if x >= 4 else 0
            if method == 1:
                predictor = left
            elif method == 2:
                predictor = above
            elif method == 3:
                predictor = (left + above) // 2
            elif method == 4:
                estimate = left + above - corner
                distances = [abs(estimate - value) for value in [left, above, corner]]
                predictor = [left, above, corner][distances.index(min(distances))]
            elif method == 0:
                predictor = 0
            else:
                raise ValueError('Unknown PNG row filter')
            row[x] = (row[x] + predictor) & 255
        alpha = row[3::4]
        low, high = min(low, min(alpha)), max(high, max(alpha))
        if low == 0 and high == 255:
            break
        previous, cursor = row, cursor + stride + 1
    return width, height, [low, high]


def audit():
    widget = (ROOT / 'lib/src/widgets/aoi_portrait.dart').read_text(encoding='utf-8')
    paths = re.findall(r"'assets/aoi/[^']+\.png'", widget)
    expected = {path.strip("'") for path in paths}
    actual = {path.relative_to(ROOT).as_posix() for path in (ROOT / 'assets/aoi').glob('*.png')}
    errors, files = [], []
    new_names = {f'assets/aoi/aoi-{name}-v1.png' for name in ['curious', 'focused', 'surprised', 'relieved', 'playful', 'pouting', 'blushing', 'celebrating']}
    if len(expected) != 16 or expected != actual:
        errors.append('Sixteen mapped PNG portraits required')
    for name in sorted(actual):
        path = ROOT / name
        raw = path.read_bytes()
        width, height, alpha = inspect_png(raw)
        if name in new_names and alpha != [0, 255]:
            errors.append(f'{name}: expected visible artwork and real transparent alpha')
        if min(width, height) < 512:
            errors.append(f'{name}: portrait resolution below 512 pixels')
        files.append(dict(path=name, sha256=hashlib.sha256(raw).hexdigest(), bytes=len(raw), width=width, height=height, mode='RGBA', alpha_extrema=alpha))
    if len({row['sha256'] for row in files}) != len(files):
        errors.append('Portrait files must contain distinct artwork')
    report = dict(portraits=len(files), newly_added=8, files=files, errors=errors)
    (ROOT / 'docs/AOI_VISUAL_AUDIT.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(dict(portraits=len(files), newly_added=8, errors=errors)))
    return not errors


if __name__ == '__main__':
    raise SystemExit(0 if audit() else 1)
