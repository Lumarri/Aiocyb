"""Validate authored JSON lessons and compile local, typed Dart constants.

This compiler does not author or expand teaching text. Every exported string
comes from the six editorial source files, without network or runtime generation.
"""
from collections import Counter
import hashlib
import json
import re
from pathlib import Path
import unicodedata

ROOT = Path(__file__).resolve().parents[1]
COURSE_IDS = ['networks-basics', 'ip-dns', 'home-wifi', 'public-networks', 'safe-browsing', 'web-privacy']
SOURCE_IDS = {'cisco-basics', 'cisco-phishing', 'cisa-habits', 'cisa-mfa', 'cisco-networks', 'cloudflare-dns', 'mdn-doh', 'wifi-apple', 'nsa-home', 'ftc-public', 'mozilla-privacy', 'chrome-incognito', 'chrome-browsing', 'android-wifi', 'microsoft-wireless', 'iana-addresses', 'iana-ipv4', 'iana-ipv6', 'motorola-bluetooth', 'android-nfc', 'android-share'}
AOI_FIELDS = ['intro', 'theory', 'hint', 'correct', 'soft', 'sharp', 'pass', 'review']
SOURCE_IDS.update({'cisa-malware', 'cisa-ransomware', 'cisa-backups', 'ms-malware', 'ms-prevent', 'ms-defender', 'ms-recovery', 'ms-response', 'android-play-protect', 'android-malware', 'android-backups'})
SOURCE_IDS.update({'ms-continuity', 'android-updates', 'ms-lifecycle', 'chrome-permissions', 'ms-app-control', 'android-reset', 'google-sessions', 'ms-reset-options'})

SOURCE_IDS.update({'crypto-store', 'crypto-passwords', 'crypto-keys', 'crypto-secrets', 'crypto-api', 'web-tls', 'web-origin', 'web-cookies', 'web-csrf', 'web-xss', 'web-authz', 'code-input', 'code-sql', 'code-errors', 'code-logging', 'code-upload', 'code-repository', 'code-dependencies', 'web-csp'})
SOURCE_IDS.update({'code-transactions', 'code-business'})
SOURCE_IDS.add('code-review')
SOURCE_IDS.add('linux-response')
SOURCE_IDS.add('linux-inode')
SOURCE_IDS.update({'linux-kernel', 'linux-debian', 'linux-bash', 'linux-coreutils', 'linux-grep', 'linux-journal', 'linux-journal-fields', 'linux-systemctl', 'linux-permissions', 'linux-fhs', 'linux-proc', 'linux-acl', 'linux-sudo', 'linux-ssh', 'linux-timers', 'linux-apt', 'linux-ip', 'linux-ss', 'linux-logrotate', 'linux-nginx', 'linux-logging'})


def normalized(value):
    return ''.join(c for c in unicodedata.normalize('NFKD', value.lower()) if c.isalnum())


def dart(value):
    if value is None:
        return 'null'
    if isinstance(value, str):
        return "'" + value.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$').replace('\r', '\\r').replace('\n', '\\n') + "'"
    if isinstance(value, list):
        return '[' + ', '.join(dart(v) for v in value) + ']'
    if isinstance(value, dict):
        return '{' + ', '.join(f'{dart(k)}: {dart(v)}' for k, v in value.items()) + '}'
    return str(value)


def lesson_dart(lesson):
    """Serialize editorial lessons, including independent practice cases."""
    args = ', '.join(f'{field}: {dart(lesson[field])}' for field in ['id', 'title', 'minutes', 'intro', 'steps', 'scenario', 'sourceIds', 'diagram'])
    sections = ', '.join(f'TheorySection({dart(s["title"])}, {dart(s["body"])})' for s in lesson['sections'])
    questions = []
    for question in lesson['questions']:
        optional = ''
        if 'scenario' in question:
            optional += f', scenario: {dart(question["scenario"])}'
        if 'aoi' in question:
            optional += f', tutor: {dart(question["aoi"])}'
        questions.append(f'Question({dart(question["prompt"])}, {dart(question["options"])}, {question["answer"]}, {dart(question["explanation"])}, wrongExplanations: {dart(question["wrongExplanations"])}{optional})')
    cases = ''
    if 'cases' in lesson:
        cases = ', cases: [' + ', '.join(f'ExplainedCase(title: {dart(c["title"])}, scenario: {dart(c["scenario"])}, explanation: {dart(c["explanation"])})' for c in lesson['cases']) + ']'
    return f'Lesson({args}, sections: [{sections}], questions: [{", ".join(questions)}], tutor: {dart(lesson["aoi"])}{cases})'


def compile_courses():
    courses, errors, files = [], [], []
    lesson_ids, theory_texts, question_texts, aoi_texts, feedback_texts = [], [], [], [], []
    for course_id in COURSE_IDS:
        path = ROOT / 'assets/courses' / f'{course_id}.json'
        if not path.exists():
            errors.append(f'Missing source: {path.name}')
            continue
        raw = path.read_bytes()
        try:
            course = json.loads(raw.decode('utf-8-sig'))
        except (UnicodeDecodeError, json.JSONDecodeError) as error:
            errors.append(f'{course_id}: unreadable editorial JSON: {error}')
            continue
        if not isinstance(course.get('lessons'), list):
            errors.append(f'{course_id}: missing lessons list')
            continue
        courses.append(course)
        files.append({'path': path.relative_to(ROOT).as_posix(), 'sha256': hashlib.sha256(raw).hexdigest(), 'lessons': len(course['lessons'])})
        if course['id'] != course_id or len(course['lessons']) != 40:
            errors.append(f'{course_id}: expected own ID and exactly 40 lessons')
        for lesson in course['lessons']:
            ident = lesson['id']
            def check_encoding(value):
                if isinstance(value, str) and ('\ufffd' in value or re.search(r'\w\?\w', re.sub(r'https?://\S+', '', value))):
                    errors.append(f'{ident}: invalid text encoding')
                elif isinstance(value, list):
                    for item in value:
                        check_encoding(item)
                elif isinstance(value, dict):
                    for item in value.values():
                        check_encoding(item)
            check_encoding(lesson)
            lesson_ids.append(ident)
            if not ident.startswith(course_id + '-'):
                errors.append(f'{ident}: missing course prefix')
            if not lesson['sections'] or len(lesson['steps']) < 2 or len(lesson['questions']) != 1:
                errors.append(f'{ident}: incomplete micro-lesson')
            if not set(lesson['sourceIds']).issubset(SOURCE_IDS) or not lesson['sourceIds']:
                errors.append(f'{ident}: unknown or missing source ID')
            for section in lesson['sections']:
                theory_texts.append(section['body'])
                if len(section['body'].split()) < 60:
                    errors.append(f'{ident}: theory shorter than 60 words')
            for field in AOI_FIELDS:
                text = lesson['aoi'].get(field, '')
                aoi_texts.append(text)
                if len(text.split()) < 15:
                    errors.append(f'{ident}: short Aoi {field}')
            for question in lesson['questions']:
                question_texts.append(question['prompt'])
                if len(question['options']) != 3 or question['answer'] not in range(3):
                    errors.append(f'{ident}: invalid choices')
                if len({normalized(option) for option in question['options']}) != 3:
                    errors.append(f'{ident}: duplicate choices')
                wrong = question['wrongExplanations']
                if len(wrong) != 3 or wrong[question['answer']] is not None:
                    errors.append(f'{ident}: invalid wrong-answer explanations')
                for choice, explanation in enumerate(wrong):
                    if choice != question['answer'] and (not explanation or len(explanation.split()) < 25):
                        errors.append(f'{ident}: missing specific distractor feedback {choice}')
                    if explanation:
                        feedback_texts.append(explanation)
                if len(question['explanation'].split()) < 25:
                    errors.append(f'{ident}: short correct-answer explanation')
                feedback_texts.append(question['explanation'])
    for field, values in [('lesson ID', lesson_ids), ('theory', theory_texts), ('question', question_texts), ('Aoi line', aoi_texts), ('answer explanation', feedback_texts)]:
        for value, count in Counter(normalized(v) for v in values).items():
            if count > 1:
                errors.append(f'Duplicate {field}: {value[:90]}')
    report = {'courses': len(courses), 'lessons': len(lesson_ids), 'exercises': len(question_texts), 'authored_aoi_lines': len(aoi_texts), 'unique_theories': len({normalized(t) for t in theory_texts}), 'answer_explanations': len(feedback_texts), 'unique_answer_explanations': len({normalized(t) for t in feedback_texts}), 'theory_words': sum(len(t.split()) for t in theory_texts), 'files': files, 'errors': errors}
    (ROOT / 'docs/COURSE_CONTENT_AUDIT.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    if errors:
        print(json.dumps(report, ensure_ascii=True, indent=2))
        return False
    lines = ["// Generated by tool/compile_courses.py. Do not edit this file by hand.", "import '../models/course.dart';", '', 'const List<Course> extendedCourses = [']
    for course in courses:
        args = ', '.join(f'{field}: {dart(course[field])}' for field in ['id', 'title', 'description', 'category', 'symbol', 'color'])
        lines.append(f'  Course({args}, lessons: [')
        for lesson in course['lessons']:
            lines.append(f'    {lesson_dart(lesson)},')
        lines.append('  ]),')
    lines.append('];')
    (ROOT / 'lib/src/data/extended_curriculum.g.dart').write_text('\n'.join(lines) + '\n', encoding='utf-8')
    syllabus = ['# Cursos de redes, Wi-Fi y navegación', '', 'Seis cursos de cuarenta microlecciones cada uno. Cada microlección incluye teoría, pasos, un caso ficticio, un ejercicio de tres opciones y explicaciones de los dos distractores. Duración orientativa: tres minutos por microlección.', '', 'Los tres cursos iniciales incluyen diez lecciones y treinta ejercicios cada uno. La ruta de malware añade seis cursos de diez lecciones profundas y cuarenta ejercicios cada uno. La ruta de criptografía, web y código añade cuatro cursos de diez lecciones y treinta ejercicios cada uno. La ruta de Linux incorpora seis cursos de diez lecciones y cuarenta ejercicios cada uno. Total de la academia: veinticinco cursos, 430 lecciones y 930 ejercicios, más cinco preguntas de diagnóstico. Véanse [las prácticas iniciales](PRACTICAS_INICIALES.md) y [los cursos de malware](MALWARE_CURSOS.md) y [criptografía, web y código](SECURE_CURSOS.md).', '']
    for course in courses:
        syllabus.extend([f'## {course["title"]}', '', course['description'], '', '| Lección | Tema |', '| ---: | --- |'])
        for index, lesson in enumerate(course['lessons'], 1):
            syllabus.append(f'| {index} | {lesson["title"]} |')
        syllabus.append('')
    syllabus.extend(['## Guiones y fuentes', '', 'Los ocho mensajes de Aoi por microlección están escritos en los JSON editoriales, junto a la teoría y la retroalimentación. El compilador exporta estos textos a constantes Dart; no crea ni combina frases para aumentar el conteo editorial. Las pantallas reutilizan el contenido de cada lección en sus situaciones correspondientes.', '', 'Las fuentes primarias se registran en la pantalla Fuentes y en lib/src/data/curriculum.dart. No son cursos oficiales ni material copiado de Cisco. Los ejemplos, casos y ejercicios se redactaron para Aiocyb.', ''])
    (ROOT / 'docs/CURSOS.md').write_text('\n'.join(syllabus), encoding='utf-8')
    print(json.dumps(report, ensure_ascii=True, indent=2))
    return True


if __name__ == '__main__':
    raise SystemExit(0 if compile_courses() else 1)
