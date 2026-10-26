"""Validate and compile the 72 authored starter-course practice exercises.

The source is editorial JSON. This tool serializes it; it never generates prose.
Run after editing assets/practice/*.json, then format the resulting Dart file.
"""
from collections import Counter
import hashlib
import json
import re

from compile_courses import ROOT, SOURCE_IDS, dart, lesson_dart, normalized

COURSE_NAMES = {
    'foundations': 'Tu primera línea de defensa',
    'identity': 'Tus cuentas, bajo llave',
    'phishing': 'Que no te pesquen',
}
LESSON_FIELDS = {'intro', 'theory', 'pass', 'review'}
QUESTION_FIELDS = {'question', 'hint', 'correct', 'soft', 'sharp'}


def compile_practice():
    courses, files, errors = [], [], []
    values = {key: [] for key in ['lesson ID', 'theory', 'question', 'case', 'Aoi line', 'answer explanation']}
    previous = {key: set() for key in values}
    for path in (ROOT / 'assets/courses').glob('*.json'):
        for lesson in json.loads(path.read_text(encoding='utf-8-sig'))['lessons']:
            previous['lesson ID'].add(normalized(lesson['id']))
            previous['theory'].update(normalized(s['body']) for s in lesson['sections'])
            previous['Aoi line'].update(normalized(v) for v in lesson['aoi'].values())
            previous['case'].add(normalized(lesson['scenario']))
            for question in lesson['questions']:
                previous['question'].add(normalized(question['prompt']))
                previous['answer explanation'].update(normalized(v) for v in [question['explanation'], *question['wrongExplanations']] if v)
    for path in (ROOT / 'assets/dialogues').glob('*.json'):
        for entry in json.loads(path.read_text(encoding='utf-8-sig'))['dialogues']:
            previous['Aoi line'].add(normalized(entry['text']))
            previous['answer explanation'].add(normalized(entry['explanation']))

    def check_encoding(value, ident):
        if isinstance(value, str):
            if '\ufffd' in value or re.search(r'\w\?\w', re.sub(r'https?://\S+', '', value)):
                errors.append(f'{ident}: invalid text encoding')
        elif isinstance(value, dict):
            for item in value.values():
                check_encoding(item, ident)
        elif isinstance(value, list):
            for item in value:
                check_encoding(item, ident)

    def text(value, kind, minimum, ident):
        if not isinstance(value, str) or len(value.split()) < minimum:
            errors.append(f'{ident}: {kind} needs at least {minimum} words')
            return
        if kind in values:
            values[kind].append(value)

    for course_id in COURSE_NAMES:
        path = ROOT / 'assets/practice' / f'{course_id}.json'
        if not path.exists():
            errors.append(f'Missing source: {path.name}')
            continue
        raw = path.read_bytes()
        try:
            course = json.loads(raw.decode('utf-8-sig'))
        except (UnicodeDecodeError, json.JSONDecodeError) as error:
            errors.append(f'{course_id}: invalid editorial JSON: {error}')
            continue
        if course.get('courseId') != course_id or len(course.get('lessons', [])) != 8:
            errors.append(f'{course_id}: expected own course ID and eight practice lessons')
            continue
        courses.append(course)
        files.append({'path': path.relative_to(ROOT).as_posix(), 'sha256': hashlib.sha256(raw).hexdigest()})
        for lesson in course['lessons']:
            ident = lesson['id']
            check_encoding(lesson, ident)
            values['lesson ID'].append(ident)
            if not ident.startswith(f'{course_id}-practice-'):
                errors.append(f'{ident}: invalid practice prefix')
            if not lesson['sections'] or len(lesson['steps']) < 2 or len(lesson['questions']) != 3:
                errors.append(f'{ident}: expected theory, two steps and three exercises')
            if not lesson['sourceIds'] or not set(lesson['sourceIds']).issubset(SOURCE_IDS):
                errors.append(f'{ident}: unknown or missing sources')
            if lesson['diagram'] not in {'defense', 'identity', 'phishing'} or lesson['minutes'] <= 0:
                errors.append(f'{ident}: invalid diagram or duration')
            text(lesson['intro'], 'introduction', 20, ident)
            text(lesson['scenario'], 'case', 25, ident)
            for section in lesson['sections']:
                text(section['body'], 'theory', 60, ident)
            if set(lesson['aoi']) != LESSON_FIELDS:
                errors.append(f'{ident}: incomplete lesson script')
            for value in lesson['aoi'].values():
                text(value, 'Aoi line', 15, ident)
            for index, question in enumerate(lesson['questions']):
                anchor = f'{ident}:{index}'
                text(question['prompt'], 'question', 3, anchor)
                text(question['scenario'], 'case', 20, anchor)
                choices = question['options']
                answer = question['answer']
                if len(choices) != 3 or len({normalized(v) for v in choices}) != 3 or answer not in range(3):
                    errors.append(f'{anchor}: invalid answer or choices')
                    continue
                wrong = question['wrongExplanations']
                if len(wrong) != 3 or wrong[answer] is not None:
                    errors.append(f'{anchor}: incorrect distractor feedback layout')
                    continue
                text(question['explanation'], 'answer explanation', 25, anchor)
                for choice, explanation in enumerate(wrong):
                    if choice != answer:
                        text(explanation, 'answer explanation', 25, f'{anchor}:{choice}')
                if set(question['aoi']) != QUESTION_FIELDS:
                    errors.append(f'{anchor}: incomplete question script')
                for value in question['aoi'].values():
                    text(value, 'Aoi line', 15, anchor)
    for kind, entries in values.items():
        counts = Counter(normalized(value) for value in entries)
        for value, count in counts.items():
            if count > 1 or value in previous[kind]:
                errors.append(f'Duplicate {kind}: {value[:90]}')
    report = {
        'courses_expanded': len(courses),
        'added_lessons': len(values['lesson ID']),
        'added_exercises': len(values['question']),
        'starter_exercises_per_course': 30,
        'academy_lessons': 430,
        'academy_exercises': 930,
        'authored_aoi_lines': len(values['Aoi line']),
        'unique_aoi_lines': len({normalized(v) for v in values['Aoi line']}),
        'theories': len(values['theory']),
        'theory_words': sum(len(v.split()) for v in values['theory']),
        'independent_exercise_cases': len(values['question']),
        'answer_explanations': len(values['answer explanation']),
        'files': files,
        'errors': errors,
    }
    (ROOT / 'docs/STARTER_PRACTICE_AUDIT.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(report, ensure_ascii=True, indent=2))
    if errors:
        return False
    lines = ['// Generated by tool/compile_practice.py. Do not edit this file by hand.', "import '../models/course.dart';", '', 'const Map<String, List<Lesson>> starterPractice = {']
    syllabus = ['# Prácticas de los cursos iniciales', '', 'Cada curso contiene diez lecciones con tres ejercicios cada una: treinta ejercicios. Las dos primeras lecciones se conservan y se añaden ocho refuerzos. Los identificadores y notas anteriores se mantienen.', '', 'Cada ejercicio nuevo tiene un caso propio, tres opciones, una explicación correcta y dos explicaciones de error. Aoi cuenta con intervenciones propias para presentación, pista, acierto, primer fallo y reincidencia. No se alternan manualmente.', '']
    for course in courses:
        course_id = course['courseId']
        lines.append(f'  {dart(course_id)}: [')
        syllabus.extend([f'## {COURSE_NAMES[course_id]}', '', 'Además de los seis ejercicios originales:', '', '| Lección | Refuerzo | Ejercicios |', '| ---: | --- | ---: |'])
        for number, lesson in enumerate(course['lessons'], 3):
            lines.append(f'    {lesson_dart(lesson)},')
            syllabus.append(f'| {number} | {lesson["title"]} | 3 |')
        lines.append('  ],')
        syllabus.extend(['', 'Casos de práctica:', ''])
        for lesson in course['lessons']:
            for question in lesson['questions']:
                syllabus.append(f'- **{lesson["title"]}:** {question["prompt"]}')
        syllabus.append('')
    lines.append('};')
    (ROOT / 'lib/src/data/starter_practice.g.dart').write_text('\n'.join(lines) + '\n', encoding='utf-8')
    syllabus.extend(['## Auditoría y actualización', '', 'Se añadieron 24 lecciones, 72 ejercicios, 216 explicaciones de respuesta y 456 intervenciones originales de Aoi. Los casos y contenidos funcionan sin conexión. Las fuentes se consultan desde la sección Fuentes de la app.', '', 'Fuentes editoriales: assets/practice/*.json. Compilación: python tool/compile_practice.py. Auditoría reproducible: docs/STARTER_PRACTICE_AUDIT.json.', ''])
    (ROOT / 'docs/PRACTICAS_INICIALES.md').write_text('\n'.join(syllabus), encoding='utf-8')
    return True


if __name__ == '__main__':
    raise SystemExit(0 if compile_practice() else 1)
