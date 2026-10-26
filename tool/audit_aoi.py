"""Audit committed editorial content; this script never generates dialogue."""
import collections
import hashlib
import json
import re
from pathlib import Path
import unicodedata

ROOT = Path(__file__).resolve().parents[1]

def normalize(text):
    return ''.join(c for c in unicodedata.normalize('NFKD', text.lower()) if c.isalnum())

def audit():
    entries, files, errors = [], [], []
    for path in sorted((ROOT / 'assets/dialogues').glob('*.json')):
        raw = path.read_bytes()
        content = json.loads(raw.decode('utf-8'))['dialogues']
        entries.extend(content)
        files.append({'path': path.relative_to(ROOT).as_posix(), 'count': len(content), 'sha256': hashlib.sha256(raw).hexdigest()})
    for field in ['id', 'text', 'explanation']:
        groups = collections.defaultdict(list)
        for entry in entries:
            groups[normalize(entry[field])].append(entry['id'])
        for values in groups.values():
            if len(values) > 1:
                errors.append({'duplicate_field': field, 'ids': values})
    if len(entries) < 500:
        errors.append({'insufficient_count': len(entries)})
    for entry in entries:
        for field, minimum in [('text', 15), ('explanation', 25)]:
            if len(entry[field].split()) < minimum:
                errors.append({'short_field': field, 'id': entry['id']})
            if '\ufffd' in entry[field] or re.search(r'\w\?\w', re.sub(r'https?://\S+', '', entry[field])):
                errors.append({'invalid_encoding': field, 'id': entry['id']})
        if entry['expression'] not in ['smirk', 'explaining', 'skeptical', 'exasperated', 'disappointed', 'delighted', 'proud', 'thinking']:
            errors.append({'invalid_expression': entry['id']})
    report = {
        'total_dialogues': len(entries),
        'unique_dialogues': len({normalize(entry['text']) for entry in entries}),
        'unique_explanations': len({normalize(entry['explanation']) for entry in entries}),
        'total_words': sum(len(entry[field].split()) for entry in entries for field in ['text', 'explanation']),
        'lessons': dict(collections.Counter(entry['lessonId'] for entry in entries)),
        'stages': dict(collections.Counter(entry['stage'] for entry in entries)),
        'files': files,
        'errors': errors,
    }
    (ROOT / 'docs/AOI_BANK_AUDIT.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(report, ensure_ascii=True, indent=2))
    return not errors

if __name__ == '__main__':
    raise SystemExit(0 if audit() else 1)
