"""Read authored Markdown records; this parser never generates teaching prose."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
COURSE_IDS = ['crypto-foundations', 'keys-data', 'web-security', 'secure-coding']
AOI_KEYS = ['intro', 'theory0', 'theory1', 'theory2', 'theory3', 'case0', 'case1', 'pass', 'review']
Q_KEYS = ['question', 'hint', 'correct', 'soft', 'sharp']


def parse_source(path):
    course, lesson, section = None, None, None
    for number, raw in enumerate(path.read_text(encoding='utf-8').splitlines(), 1):
        line = raw.strip()
        if line.startswith('@course '):
            fields = [value.strip() for value in line[8:].split('|')]
            ident, title, description, symbol, color, closure, explanation = fields
            course = dict(id=ident, title=title, description=description, symbol=symbol,
                color=int(color, 0), category='Criptografía, web y código',
                closure=dict(text=closure, explanation=explanation), lessons=[])
        elif line.startswith('## '):
            slug, title = [value.strip() for value in line[3:].split('|', 1)]
            lesson = dict(id=course['id'] + '-' + slug, title=title, minutes=15,
                sections=[], questions=[], cases=[], diagram='defense')
            course['lessons'].append(lesson)
            section = None
        elif line.startswith('### '):
            section = dict(title=line[4:], body='')
            lesson['sections'].append(section)
        elif line.startswith('@'):
            section = None
            kind, value = line.split(' ', 1)
            fields = [item.strip() for item in value.split('|')]
            if kind == '@intro':
                lesson['intro'] = lesson['scenario'] = value
            elif kind == '@steps':
                lesson['steps'] = fields
            elif kind == '@sources':
                lesson['sourceIds'] = [item.strip() for item in value.split(',')]
            elif kind == '@aoi':
                if len(fields) != 9:
                    raise ValueError(f'{path.name}:{number}: expected 9 tutor lines, got {len(fields)}')
                lesson['aoi'] = dict(zip(AOI_KEYS, fields))
            elif kind == '@case':
                title, scenario, explanation = fields
                lesson['cases'].append(dict(title=title, scenario=scenario, explanation=explanation))
            elif kind == '@q':
                if len(fields) != 15:
                    raise ValueError(f'{path.name}:{number}: expected 15 question fields, got {len(fields)}')
                lesson['questions'].append(dict(prompt=fields[0], scenario=fields[1],
                    options=fields[2:5], answer=int(fields[5]), explanation=fields[6],
                    wrongExplanations=[None if item == '-' else item for item in fields[7:10]],
                    aoi=dict(zip(Q_KEYS, fields[10:]))))
            else:
                raise ValueError(f'{path.name}:{number}: unknown marker {kind}')
        elif line and not line.startswith(('# ', '<!--')):
            if section is None:
                raise ValueError(f'{path.name}:{number}: text outside a theory section')
            section['body'] += ('\n\n' if section['body'] else '') + line
    return course


def parse_secure_sources():
    for ident in COURSE_IDS:
        path = ROOT / 'assets/secure' / f'{ident}.md'
        if path.exists():
            course = parse_source(path)
            if course['id'] != ident:
                raise ValueError(f'{path.name}: incorrect course ID')
            path.with_suffix('.json').write_text(json.dumps(course, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
