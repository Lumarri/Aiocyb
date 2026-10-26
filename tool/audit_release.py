"""Verify that the release APK includes the audited offline academy content."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[1]


def audit_release(apk, aapt):
    version = re.search(r'^version:\s*(\S+)', (ROOT / 'pubspec.yaml').read_text(encoding='utf-8'), re.M).group(1)
    version_name, version_code = version.split('+')
    interface = json.loads((ROOT / 'docs/COURSE_BROWSER_AUDIT.json').read_text(encoding='utf-8'))
    assert interface['status'] == 'passed' and interface['version'] == version, 'Course browser audit is not current'
    for source in interface['sourceFiles']:
        assert hashlib.sha256((ROOT / source['path']).read_bytes()).hexdigest() == source['sha256'], f'Stale interface audit: {source["path"]}'
    dashboard = json.loads((ROOT / 'docs/DASHBOARD_BROWSER_AUDIT.json').read_text(encoding='utf-8'))
    assert dashboard['status'] == 'passed' and dashboard['version'] == version, 'Dashboard browser audit is not current'
    assert dashboard['compiledWebSha256'] == interface['compiledWebSha256'], 'UI reports are from different builds'
    for source in dashboard['sourceFiles']:
        assert hashlib.sha256((ROOT / source['path']).read_bytes()).hexdigest() == source['sha256'], f'Stale dashboard audit: {source["path"]}'
    reports = {}
    for name in ['AOI_BANK_AUDIT', 'AOI_VISUAL_AUDIT', 'COURSE_CONTENT_AUDIT', 'STARTER_PRACTICE_AUDIT', 'MALWARE_CONTENT_AUDIT', 'SECURE_CONTENT_AUDIT', 'LINUX_CONTENT_AUDIT', 'LAB_CONTENT_AUDIT']:
        report = json.loads((ROOT / 'docs' / f'{name}.json').read_text(encoding='utf-8'))
        assert not report['errors'], f'{name} has unresolved errors'
        for source in report['files']:
            assert hashlib.sha256((ROOT / source['path']).read_bytes()).hexdigest() == source['sha256'], f'Stale audit: {source["path"]}'
        reports[name] = report
    initial = (ROOT / 'lib/src/data/curriculum.dart').read_text(encoding='utf-8').split('const initialCourses = [', 1)[1].split('final List<Course> starterCourses', 1)[0]
    lesson_ids = re.findall(r"Lesson\(\s*id:\s*'([^']+)'", initial)
    exercises = len(re.findall(r'\bQuestion\(', initial))
    course_count = len(re.findall(r"Course\(\s*id:\s*'([^']+)'", initial))
    for directory in ['courses', 'practice', 'malware', 'secure', 'linux']:
        paths = list((ROOT / 'assets' / directory).glob('*.json'))
        if directory != 'practice':
            course_count += len(paths)
        for path in paths:
            for lesson in json.loads(path.read_text(encoding='utf-8-sig'))['lessons']:
                lesson_ids.append(lesson['id'])
                exercises += len(lesson['questions'])
    assert len(lesson_ids) == len(set(lesson_ids)), 'Duplicate lesson IDs'
    with zipfile.ZipFile(apk) as archive:
        names = archive.namelist()
        portraits = [name for name in names if name.startswith('assets/flutter_assets/assets/aoi/') and name.endswith('.png')]
        banks = [name for name in names if name.startswith('assets/flutter_assets/assets/dialogues/') and name.endswith('.json')]
        covers = [name for name in names if name.startswith('assets/flutter_assets/assets/artwork/') and name.endswith('.png')]
        assert len(portraits) == len(list((ROOT / 'assets/aoi').glob('*.png'))), 'Missing portrait'
        assert len(banks) == len(list((ROOT / 'assets/dialogues').glob('*.json'))), 'Missing dialogue asset'
        assert len(covers) == 5, 'Missing course cover'
        for name in portraits + banks + covers:
            assert archive.read(name) == (ROOT / name.removeprefix('assets/flutter_assets/')).read_bytes(), f'Stale asset: {name}'
        compiled = archive.read('lib/arm64-v8a/libapp.so')
        missing = [ident for ident in lesson_ids if ident.encode('ascii') not in compiled]
        assert not missing, f'Missing compiled lessons: {missing}'
        assert all(lab['id'].encode('ascii') in compiled for lab in reports['LAB_CONTENT_AUDIT']['data']), 'Missing compiled laboratory'
        flutter_abis = [name.split('/')[1] for name in names if re.fullmatch(r'lib/[^/]+/libflutter\.so', name)]
        dialogues = sum(len(json.loads(archive.read(name))['dialogues']) for name in banks)
    def dump(kind):
        return subprocess.run([str(aapt), 'dump', kind, str(apk)], check=True, capture_output=True).stdout.decode('utf-8', errors='replace')
    badging, permissions = dump('badging'), dump('permissions')
    assert "name='com.aiocyb.aiocyb'" in badging, 'Unexpected application ID'
    assert f"versionName='{version_name}'" in badging and f"versionCode='{version_code}'" in badging, 'APK is from a different version'
    assert 'android.permission.INTERNET' not in permissions, 'Unexpected Internet permission in the release APK'
    report = {
        'version': version, 'apk': apk.relative_to(ROOT).as_posix(),
        'bytes': apk.stat().st_size, 'sha256': hashlib.sha256(apk.read_bytes()).hexdigest(),
        'portraits': len(portraits), 'course_covers': len(covers),
        'course_interface_source_files': interface['sourceFiles'],
        'dashboard_source_files': dashboard['sourceFiles'],
        'learning_paths': len(dashboard['paths']),
        'course_cover_files': [name.removeprefix('assets/flutter_assets/') for name in covers],
        'dialogue_assets': len(banks), 'editorial_dialogues': dialogues,
        'courses': course_count, 'lessons': len(lesson_ids), 'exercises': exercises,
        'starter_exercises': {'foundations': 30, 'identity': 30, 'phishing': 30},
        'malware_courses': reports['MALWARE_CONTENT_AUDIT']['courses'],
        'malware_lessons': reports['MALWARE_CONTENT_AUDIT']['lessons'],
        'malware_exercises': reports['MALWARE_CONTENT_AUDIT']['exercises'],
        'malware_explained_cases': reports['MALWARE_CONTENT_AUDIT']['explained_cases'],
        'malware_theory_words': reports['MALWARE_CONTENT_AUDIT']['theory_words'],
        'malware_authored_aoi_lines': reports['MALWARE_CONTENT_AUDIT']['authored_aoi_lines'],
        'secure_courses': reports['SECURE_CONTENT_AUDIT']['courses'],
        'secure_lessons': reports['SECURE_CONTENT_AUDIT']['lessons'],
        'secure_exercises': reports['SECURE_CONTENT_AUDIT']['exercises'],
        'secure_explained_cases': reports['SECURE_CONTENT_AUDIT']['explained_cases'],
        'secure_theory_words': reports['SECURE_CONTENT_AUDIT']['theory_words'],
        'secure_authored_aoi_lines': reports['SECURE_CONTENT_AUDIT']['authored_aoi_lines'],
        'linux_courses': reports['LINUX_CONTENT_AUDIT']['courses'],
        'linux_lessons': reports['LINUX_CONTENT_AUDIT']['lessons'],
        'linux_exercises': reports['LINUX_CONTENT_AUDIT']['exercises'],
        'linux_explained_cases': reports['LINUX_CONTENT_AUDIT']['explained_cases'],
        'linux_theory_words': reports['LINUX_CONTENT_AUDIT']['theory_words'],
        'linux_authored_aoi_lines': reports['LINUX_CONTENT_AUDIT']['authored_aoi_lines'],
        'offline_labs': reports['LAB_CONTENT_AUDIT']['labs'],
        'lab_stages': reports['LAB_CONTENT_AUDIT']['stages'],
        'lab_authored_aoi_lines': reports['LAB_CONTENT_AUDIT']['authored_aoi_lines'],
        'compiled_lesson_ids': len(lesson_ids), 'missing_lesson_ids': missing,
        'flutter_abis': flutter_abis, 'internet_permission': False,
        'minimum_sdk': int(re.search(r"sdkVersion:'(\d+)'", badging).group(1)),
        'target_sdk': int(re.search(r"targetSdkVersion:'(\d+)'", badging).group(1)),
    }
    assert dialogues == reports['AOI_BANK_AUDIT']['total_dialogues']
    (ROOT / 'docs/BUILD_AUDIT.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(report, ensure_ascii=True, indent=2))
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apk', type=Path, default=ROOT / 'build/app/outputs/flutter-apk/app-release.apk')
    parser.add_argument('--aapt', type=Path, required=True, help='Android SDK build-tools aapt executable')
    arguments = parser.parse_args()
    audit_release(arguments.apk.resolve(), arguments.aapt.resolve())
