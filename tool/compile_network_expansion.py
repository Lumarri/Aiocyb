"""Audit authored network lessons and reinforcement decisions; export offline Dart.

The Markdown files are the editorial originals. This compiler parses, checks and
serializes them; it does not generate or pad theory, questions or tutor dialogue.
"""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re

from compile_courses import ROOT, dart, lesson_dart, normalized
from secure_editorial import parse_source, Q_KEYS

COURSE_IDS = ['ipv4-subnetting', 'ipv6-foundations', 'switching-routing',
              'network-diagnostics', 'network-defense', 'security-operations']
EXISTING_IDS = ['networks-basics', 'ip-dns', 'home-wifi', 'public-networks',
                'safe-browsing', 'web-privacy']
DIRECTORY = ROOT / 'assets/network_expansion'
LESSON_KEYS = {'intro', 'theory0', 'theory1', 'theory2', 'theory3',
               'case0', 'case1', 'pass', 'review'}


def question_from_record(value):
    fields = [part.strip() for part in value.split('|')]
    if len(fields) != 15:
        raise ValueError(f'Question must contain 15 fields, got {len(fields)}')
    return dict(prompt=fields[0], scenario=fields[1], options=fields[2:5],
                answer=int(fields[5]), explanation=fields[6],
                wrongExplanations=[None if text == '-' else text for text in fields[7:10]],
                aoi=dict(zip(Q_KEYS, fields[10:])))


def question_dart(question):
    return (f'Question({dart(question["prompt"])}, {dart(question["options"])}, '
            f'{question["answer"]}, {dart(question["explanation"])}, '
            f'wrongExplanations: {dart(question["wrongExplanations"])}, '
            f'scenario: {dart(question["scenario"])}, tutor: {dart(question["aoi"])})')


def compile_expansion(partial=False):
    errors, files, courses, practice, details = [], [], [], {}, []
    pools = {kind: [] for kind in ['theory', 'question', 'case', 'explanation', 'aoi']}
    previous = {kind: set() for kind in pools}
    for folder in ['courses', 'practice', 'malware', 'secure', 'linux']:
        for old_path in (ROOT / 'assets' / folder).glob('*.json'):
            old_course = json.loads(old_path.read_text(encoding='utf-8-sig'))
            for old_lesson in old_course['lessons']:
                previous['theory'].update(normalized(item['body']) for item in old_lesson['sections'])
                previous['case'].add(normalized(old_lesson['scenario']))
                previous['aoi'].update(map(normalized, old_lesson.get('aoi', {}).values()))
                for old_case in old_lesson.get('cases', []):
                    previous['case'].add(normalized(old_case['scenario']))
                    previous['explanation'].add(normalized(old_case['explanation']))
                for old_question in old_lesson['questions']:
                    previous['question'].add(normalized(old_question['prompt']))
                    if old_question.get('scenario'): previous['case'].add(normalized(old_question['scenario']))
                    previous['aoi'].update(map(normalized, old_question.get('aoi', {}).values()))
                    previous['explanation'].update(normalized(text) for text in
                        [old_question['explanation'], *old_question['wrongExplanations']] if text)
    for old_path in (ROOT / 'assets/dialogues').glob('*.json'):
        for entry in json.loads(old_path.read_text(encoding='utf-8-sig'))['dialogues']:
            previous['aoi'].add(normalized(entry['text']))
            previous['explanation'].add(normalized(entry['explanation']))
    source_text = (ROOT / 'lib/src/data/network_sources.dart').read_text(encoding='utf-8')
    source_ids = set(re.findall(r"LearningSource\(\s*'([^']+)'", source_text))

    def remember(path):
        files.append(dict(path=path.relative_to(ROOT).as_posix(),
                          sha256=hashlib.sha256(path.read_bytes()).hexdigest()))

    def check_text(value, ident, kind, minimum=1):
        if not isinstance(value, str) or len(value.split()) < minimum:
            errors.append(f'{ident}: {kind} needs at least {minimum} words')
            return
        # Query separators inside a literal URL are valid authored content.
        prose = re.sub(r'https?://\S+', '', value)
        if '\ufffd' in value or re.search(r'\w\?\w', prose):
            errors.append(f'{ident}: broken Unicode')
        if kind in pools:
            pools[kind].append(value)

    def check_question(question, ident, extra=False):
        check_text(question['prompt'], ident, 'question', 4)
        check_text(question['scenario'], ident, 'case', 8)
        check_text(question['explanation'], ident, 'explanation', 12)
        options, answer = question['options'], question['answer']
        assert len(options) == 3 and answer in range(3), ident
        assert len(set(map(normalized, options))) == 3, ident
        wrong = question['wrongExplanations']
        assert len(wrong) == 3 and wrong[answer] is None, ident
        for index, text in enumerate(wrong):
            if index != answer:
                check_text(text, f'{ident}:{index}', 'explanation', 12)
        expected = set(Q_KEYS) | ({'pass', 'review'} if extra else set())
        assert set(question['aoi']) == expected, ident
        for key, text in question['aoi'].items():
            check_text(text, f'{ident}:{key}', 'aoi', 7)

    for course_id in COURSE_IDS:
        path = DIRECTORY / f'{course_id}.md'
        if not path.exists():
            if not partial: errors.append(f'Missing {path.name}')
            continue
        remember(path)
        fragments = sorted((DIRECTORY / course_id).glob('*.md'))
        for fragment in fragments: remember(fragment)
        combined = ROOT / 'build/editorial/network_expansion' / path.name
        combined.parent.mkdir(parents=True, exist_ok=True)
        combined.write_text('\n\n'.join(item.read_text(encoding='utf-8')
                                      for item in [path, *fragments]), encoding='utf-8')
        course = parse_source(combined)
        course['category'] = 'Redes prácticas y ciberdefensa'
        assert course['id'] == course_id
        if not partial and len(course['lessons']) != 10:
            errors.append(f'{course_id}: expected ten lessons')
        answers = []
        check_text(course['closure']['text'], course_id, 'aoi', 12)
        for lesson in course['lessons']:
            lesson['diagram'] = 'network' if course_id in COURSE_IDS[:4] else 'defense'
            ident = lesson['id']
            words = sum(len(section['body'].split()) for section in lesson['sections'])
            details.append(dict(id=ident, theory_words=words, questions=len(lesson['questions'])))
            if not 600 <= words <= 900: errors.append(f'{ident}: {words} theory words, expected 600..900')
            if len(lesson['sections']) != 4 or len(lesson['cases']) != 2 or len(lesson['questions']) != 6:
                errors.append(f'{ident}: expected four sections, two cases, six questions')
            assert len(lesson['steps']) >= 3 and set(lesson['aoi']) == LESSON_KEYS, ident
            assert len(set(lesson['sourceIds'])) >= 2 and set(lesson['sourceIds']) <= source_ids, ident
            for section in lesson['sections']: check_text(section['body'], ident, 'theory', 100)
            for case in lesson['cases']:
                check_text(case['scenario'], ident, 'case', 12)
                check_text(case['explanation'], ident, 'explanation', 25)
            for key, line in lesson['aoi'].items(): check_text(line, f'{ident}:{key}', 'aoi', 7)
            for index, question in enumerate(lesson['questions']):
                check_question(question, f'{ident}:{index}')
                answers.append(question['answer'])
        if len(course['lessons']) == 10 and Counter(answers) != Counter({0:20,1:20,2:20}):
            errors.append(f'{course_id}: answer positions must be balanced 20/20/20')
        courses.append(course)
        output = path.with_suffix('.json')
        output.write_text(json.dumps(course, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
        remember(output)

    for course_id in EXISTING_IDS:
        path = DIRECTORY / f'{course_id}.practice.md'
        if not path.exists():
            if not partial: errors.append(f'Missing {path.name}')
            continue
        remember(path)
        expected = {lesson['id'] for lesson in json.loads((ROOT/'assets/courses'/f'{course_id}.json').read_text(encoding='utf-8-sig'))['lessons']}
        current = None
        found = set()
        for raw in path.read_text(encoding='utf-8').splitlines():
            line = raw.strip()
            if line.startswith('@practice '):
                current, passed, review = [part.strip() for part in line[10:].split('|')]
                assert current in expected and current not in practice, current
            elif line.startswith('@q '):
                assert current is not None
                question = question_from_record(line[3:])
                question['aoi'].update({'pass': passed, 'review': review})
                check_question(question, current, extra=True)
                practice[current] = question
                found.add(current)
                current = None
            elif line and not line.startswith('#'):
                raise ValueError(f'{path.name}: unexpected record {line[:60]}')
        if not partial and found != expected: errors.append(f'{course_id}: expected one extra decision for each original lesson')

    for kind, values in pools.items():
        for value, count in Counter(map(normalized, values)).items():
            if count > 1 or value in previous[kind]: errors.append(f'Duplicate {kind}: {value[:100]}')
    ids = [lesson['id'] for course in courses for lesson in course['lessons']]
    assert len(ids) == len(set(ids))
    report = dict(partial=partial, courses=len(courses), lessons=len(details),
                  course_exercises=sum(row['questions'] for row in details),
                  reinforcement_exercises=len(practice),
                  theory_words=sum(row['theory_words'] for row in details),
                  explained_cases=sum(len(lesson['cases']) for course in courses for lesson in course['lessons']),
                  authored_aoi_lines=len(pools['aoi']), lesson_details=details,
                  files=files, errors=errors)
    name = 'NETWORK_EXPANSION_PROGRESS.json' if partial else 'NETWORK_EXPANSION_AUDIT.json'
    (ROOT/'docs'/name).write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({key:value for key,value in report.items() if key not in ['files','lesson_details']},ensure_ascii=True,indent=2))
    if errors or partial: return not errors
    lines = ['// Generated by tool/compile_network_expansion.py; edit the Markdown originals.', "import '../models/course.dart';", '', 'const List<Course> advancedNetworkCourses = [']
    for course in courses:
        args = ', '.join(f'{field}: {dart(course[field])}' for field in ['id','title','description','category','symbol','color'])
        lines.append(f'  Course({args}, completionTutor: {dart(course["closure"]["text"])}, completionExplanation: {dart(course["closure"]["explanation"])}, lessons: [')
        lines.extend(f'    {lesson_dart(lesson)},' for lesson in course['lessons'])
        lines.append('  ]),')
    lines.extend(['];','','const Map<String, Question> networkReinforcementQuestions = {'])
    lines.extend(f'  {dart(ident)}: {question_dart(question)},' for ident,question in practice.items())
    lines.append('};')
    (ROOT/'lib/src/data/network_expansion.g.dart').write_text('\n'.join(lines)+'\n',encoding='utf-8')
    return True


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check-partial',action='store_true')
    args = parser.parse_args()
    raise SystemExit(0 if compile_expansion(args.check_partial) else 1)
