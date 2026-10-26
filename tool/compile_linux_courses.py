"""Validate original long-form lessons and export offline Dart constants.

No text is generated or padded here. All theory, cases and Aoi lines must be
authored in assets/linux before this compiler can produce a complete release.
"""
from collections import Counter
import argparse
import hashlib
import json
import re

from compile_courses import ROOT, SOURCE_IDS, dart, lesson_dart, normalized
from linux_editorial import COURSE_IDS, parse_linux_sources as parse_secure_sources

LESSON_AOI = {'intro', 'theory0', 'theory1', 'theory2', 'theory3', 'case0', 'case1', 'pass', 'review'}
QUESTION_AOI = {'question', 'hint', 'correct', 'soft', 'sharp'}
KINDS = ['lesson ID', 'theory', 'question', 'case', 'case explanation', 'Aoi line', 'answer explanation']


def compile_linux_courses(partial=False):
    parse_secure_sources()
    errors, courses, files, lesson_stats = [], [], [], []
    content = {kind: [] for kind in KINDS}
    previous = {kind: set() for kind in KINDS}
    for directory in ['courses', 'practice', 'malware', 'secure']:
        for path in (ROOT / 'assets' / directory).glob('*.json'):
            for lesson in json.loads(path.read_text(encoding='utf-8-sig'))['lessons']:
                previous['lesson ID'].add(normalized(lesson['id']))
                previous['theory'].update(normalized(section['body']) for section in lesson['sections'])
                previous['case'].add(normalized(lesson['scenario']))
                for study_case in lesson.get('cases', []):
                    previous['case'].add(normalized(study_case['scenario']))
                    previous['case explanation'].add(normalized(study_case['explanation']))
                previous['Aoi line'].update(normalized(value) for value in lesson['aoi'].values())
                for question in lesson['questions']:
                    previous['question'].add(normalized(question['prompt']))
                    if question.get('scenario'):
                        previous['case'].add(normalized(question['scenario']))
                    previous['Aoi line'].update(normalized(value) for value in question.get('aoi', {}).values())
                    previous['answer explanation'].update(normalized(value) for value in [question['explanation'], *question['wrongExplanations']] if value)
    for path in (ROOT / 'assets/dialogues').glob('*.json'):
        for entry in json.loads(path.read_text(encoding='utf-8-sig'))['dialogues']:
            previous['Aoi line'].add(normalized(entry['text']))
            previous['answer explanation'].add(normalized(entry['explanation']))

    def check_encoding(value, ident):
        if isinstance(value, str):
            if '\ufffd' in value or re.search(r'\w\?\w', re.sub(r'https?://\S+', '', value)):
                errors.append(f'{ident}: broken text encoding')
        elif isinstance(value, list):
            for item in value:
                check_encoding(item, ident)
        elif isinstance(value, dict):
            for item in value.values():
                check_encoding(item, ident)

    def text(value, ident, kind, minimum=1, maximum=None):
        if not isinstance(value, str) or not value.strip():
            errors.append(f'{ident}: missing {kind}')
            return
        count = len(value.split())
        if count < minimum or (maximum is not None and count > maximum):
            errors.append(f'{ident}: {kind} has {count} words; expected {minimum}..{maximum or "unlimited"}')
        if kind in content:
            content[kind].append(value)

    def script(value, expected, ident):
        if set(value) != expected:
            errors.append(f'{ident}: incorrect Aoi fields {sorted(set(value) ^ expected)}')
        for key, line in value.items():
            text(line, f'{ident}:{key}', 'Aoi line', 8, 30)

    for course_id in COURSE_IDS:
        path = ROOT / 'assets/linux' / f'{course_id}.json'
        if not path.exists():
            if not partial:
                errors.append(f'Missing editorial source: {path.name}')
            continue
        raw = path.read_bytes()
        try:
            course = json.loads(raw.decode('utf-8-sig'))
        except (UnicodeDecodeError, json.JSONDecodeError) as error:
            errors.append(f'{course_id}: invalid JSON: {error}')
            continue
        lesson_count = len(course.get('lessons', []))
        valid_count = 1 <= lesson_count <= 10 if partial else lesson_count == 10
        if course.get('id') != course_id or not valid_count:
            errors.append(f'{course_id}: expected own ID and ten complete lessons')
            continue
        courses.append(course)
        check_encoding(course, course_id)
        files.append({'path': path.relative_to(ROOT).as_posix(), 'sha256': hashlib.sha256(raw).hexdigest(), 'lessons': lesson_count, 'exercises': sum(len(lesson['questions']) for lesson in course['lessons'])})
        text(course['closure']['text'], course_id, 'Aoi line', 15, 35)
        text(course['closure']['explanation'], course_id, 'course closure', 25)
        answers = []
        for lesson in course['lessons']:
            ident = lesson['id']
            content['lesson ID'].append(ident)
            if not ident.startswith(course_id + '-'):
                errors.append(f'{ident}: missing course prefix')
            if len(lesson['sections']) != 4 or len(lesson['questions']) != 4 or len(lesson['cases']) != 2 or len(lesson['steps']) < 3:
                errors.append(f'{ident}: expected four concepts, two explained cases, three steps and four exercises')
            if len(set(lesson['sourceIds'])) < 2 or not set(lesson['sourceIds']).issubset(SOURCE_IDS):
                errors.append(f'{ident}: two valid sources required')
            if lesson['minutes'] < 1 or lesson['diagram'] != 'defense':
                errors.append(f'{ident}: invalid duration or diagram')
            text(lesson['intro'], ident, 'introduction', 15)
            text(lesson['scenario'], ident, 'case', 15)
            theory_words = sum(len(section['body'].split()) for section in lesson['sections'])
            if not 600 <= theory_words <= 900:
                errors.append(f'{ident}: theory has {theory_words} words, expected 600..900 excluding cases and dialogue')
            lesson_stats.append({'id': ident, 'theory_words': theory_words, 'concepts': len(lesson['sections']), 'explained_cases': len(lesson['cases']), 'exercises': len(lesson['questions'])})
            for section in lesson['sections']:
                text(section['title'], ident, 'section title')
                text(section['body'], ident, 'theory', 120)
            script(lesson['aoi'], LESSON_AOI, ident)
            for case in lesson['cases']:
                text(case['title'], ident, 'case title')
                text(case['scenario'], ident, 'case', 15)
                text(case['explanation'], ident, 'case explanation', 35)
            for index, question in enumerate(lesson['questions']):
                anchor = f'{ident}:{index}'
                text(question['prompt'], anchor, 'question', 3)
                text(question['scenario'], anchor, 'case', 15)
                options, answer = question['options'], question['answer']
                if len(options) != 3 or len({normalized(option) for option in options}) != 3 or type(answer) is not int or answer not in range(3):
                    errors.append(f'{anchor}: invalid choices or answer')
                    continue
                answers.append(answer)
                wrong = question['wrongExplanations']
                if len(wrong) != 3 or wrong[answer] is not None:
                    errors.append(f'{anchor}: invalid distractor layout')
                    continue
                text(question['explanation'], anchor, 'answer explanation', 12)
                for choice, explanation in enumerate(wrong):
                    if choice != answer:
                        text(explanation, f'{anchor}:{choice}', 'answer explanation', 12)
                script(question['aoi'], QUESTION_AOI, anchor)
        distribution = Counter(answers)
        if len(answers) != lesson_count * 4 or (lesson_count == 10 and any(distribution[index] < 11 for index in range(3))):
            errors.append(f'{course_id}: expected forty exercises with balanced answer positions, got {dict(distribution)}')
    for course_id in COURSE_IDS:
        source_path = ROOT / 'assets/linux' / f'{course_id}.md'
        if source_path.exists():
            files.append({'path': source_path.relative_to(ROOT).as_posix(), 'sha256': hashlib.sha256(source_path.read_bytes()).hexdigest()})
    for kind, texts in content.items():
        for value, count in Counter(normalized(value) for value in texts).items():
            if count > 1 or value in previous[kind]:
                errors.append(f'Duplicate {kind}: {value[:100]}')
    report = {
        'partial_check': partial, 'courses': len(courses), 'lessons': len(lesson_stats),
        'exercises': len(content['question']), 'explained_cases': len(content['case explanation']),
        'theory_words': sum(row['theory_words'] for row in lesson_stats),
        'minimum_theory_words_per_lesson': min((row['theory_words'] for row in lesson_stats), default=0),
        'maximum_theory_words_per_lesson': max((row['theory_words'] for row in lesson_stats), default=0),
        'authored_aoi_lines': len(content['Aoi line']),
        'unique_aoi_lines': len({normalized(value) for value in content['Aoi line']}),
        'answer_explanations': len(content['answer explanation']),
        'academy_courses': 25, 'academy_lessons': 430, 'academy_exercises': 930,
        'lesson_details': lesson_stats, 'files': files, 'errors': errors,
    }
    report_name = 'LINUX_CONTENT_PROGRESS.json' if partial else 'LINUX_CONTENT_AUDIT.json'
    (ROOT / 'docs' / report_name).write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(json.dumps({key: value for key, value in report.items() if key != 'lesson_details'}, ensure_ascii=True, indent=2))
    if errors:
        return False
    if partial:
        return True
    (ROOT / 'docs/LINUX_CONTENT_PROGRESS.json').unlink(missing_ok=True)
    lines = ['// Generated by tool/compile_linux_courses.py. Do not edit this file by hand.', "import '../models/course.dart';", '', 'const List<Course> linuxCourses = [']
    syllabus = ['# Linux, terminal y análisis de registros', '', 'Seis cursos, diez lecciones y cuarenta ejercicios por curso. Cada lección incluye 600–900 palabras de teoría, dos casos resueltos y cuatro ejercicios. Se aprueba con tres aciertos. Cada lección aporta 29 intervenciones propias de Aoi. Los originales Markdown se transcriben a JSON y constantes Dart sin generar ni rellenar contenido.', '']
    for course in courses:
        args = ', '.join(f'{field}: {dart(course[field])}' for field in ['id', 'title', 'description', 'category', 'symbol', 'color'])
        lines.append(f'  Course({args}, completionTutor: {dart(course["closure"]["text"])}, completionExplanation: {dart(course["closure"]["explanation"])}, lessons: [')
        syllabus.extend([f'## {course["title"]}', '', course['description'], '', '| Lección | Tema | Palabras de teoría | Casos resueltos | Ejercicios |', '| ---: | --- | ---: | ---: | ---: |'])
        for number, lesson in enumerate(course['lessons'], 1):
            lines.append(f'    {lesson_dart(lesson)},')
            words = sum(len(section['body'].split()) for section in lesson['sections'])
            syllabus.append(f'| {number} | {lesson["title"]} | {words} | 2 | 4 |')
        syllabus.append('')
        lines.append('  ]),')
    lines.append('];')
    syllabus.extend(['## Auditoría', '', f'Total: {report["theory_words"]:,} palabras de teoría original, 120 casos explicados, 240 ejercicios, 720 explicaciones de respuesta y {report["authored_aoi_lines"]} intervenciones editoriales de Aoi. Los mensajes se seleccionan por situación, sin alternancia manual.', '', 'Originales: assets/linux/*.md y *.json (transcripción estructurada). Validación y compilación: python tool/compile_linux_courses.py. Informe por lección y huellas: [LINUX_CONTENT_AUDIT.json](LINUX_CONTENT_AUDIT.json).', ''])
    (ROOT / 'lib/src/data/linux_curriculum.g.dart').write_text('\n'.join(lines) + '\n', encoding='utf-8')
    (ROOT / 'docs/LINUX_CURSOS.md').write_text('\n'.join(syllabus), encoding='utf-8')
    return True


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check-partial', action='store_true', help='Audit authored lessons without generating a partial release')
    arguments = parser.parse_args()
    raise SystemExit(0 if compile_linux_courses(partial=arguments.check_partial) else 1)
