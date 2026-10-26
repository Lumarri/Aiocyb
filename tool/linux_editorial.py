"""Parse authored Linux lessons without generating teaching text."""
import json
from secure_editorial import ROOT, parse_source

COURSE_IDS = ['linux-start', 'terminal-tools', 'linux-access', 'linux-operations', 'log-analysis', 'linux-investigation']


def parse_linux_sources():
    for ident in COURSE_IDS:
        path = ROOT / 'assets/linux' / f'{ident}.md'
        if path.exists():
            course = parse_source(path)
            if course['id'] != ident:
                raise ValueError(f'{path.name}: incorrect course ID')
            course['category'] = 'Linux, terminal y registros'
            path.with_suffix('.json').write_text(json.dumps(course, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
