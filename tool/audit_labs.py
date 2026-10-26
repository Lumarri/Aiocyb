"""Export the compiled lab data for a browser walkthrough and audit its sources."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]

def audit(dart):
    raw = subprocess.run([str(dart), str(ROOT / 'tool/export_labs.dart')], cwd=ROOT, check=True, capture_output=True)
    labs = json.loads(raw.stdout.decode('utf-8'))
    errors, lines = [], []
    if len(labs) != 4 or len({lab['id'] for lab in labs}) != 4:
        errors.append('Expected four unique labs')
    for lab in labs:
        lines.append(lab['closure'])
        if len(lab['stages']) != 3:
            errors.append(f'{lab["id"]}: three stages required')
        for stage in lab['stages']:
            if len(stage['options']) != 3 or len(set(stage['options'])) != 3 or stage['answer'] not in range(3) or len(stage['feedback']) != 3:
                errors.append(f'{lab["id"]}:{stage["title"]}: invalid decisions')
            lines.extend(stage[field] for field in ['intro', 'correct', 'soft', 'sharp'])
    if len(set(lines)) != len(lines) or not all(lines):
        errors.append('Missing or repeated tutor lines')
    paths = [ROOT / 'lib/src/data/offline_labs.dart', ROOT / 'tool/export_labs.dart']
    report = {'labs': len(labs), 'stages': sum(len(lab['stages']) for lab in labs),
        'authored_aoi_lines': len(lines), 'unique_aoi_lines': len(set(lines)),
        'data': labs, 'errors': errors,
        'files': [{'path': p.relative_to(ROOT).as_posix(), 'sha256': hashlib.sha256(p.read_bytes()).hexdigest()} for p in paths]}
    (ROOT / 'docs/LAB_CONTENT_AUDIT.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(json.dumps({key: value for key, value in report.items() if key != 'data'}, indent=2))
    return not errors

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dart', type=Path, required=True)
    args = parser.parse_args()
    raise SystemExit(0 if audit(args.dart) else 1)
