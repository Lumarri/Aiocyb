"""Verify that the release APK includes the audited offline academy content."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[1]
NETWORK_IDS = ['ipv4-subnetting', 'ipv6-foundations', 'switching-routing',
               'network-diagnostics', 'network-defense', 'security-operations']
REINFORCED_IDS = ['networks-basics', 'ip-dns', 'home-wifi',
                  'public-networks', 'safe-browsing', 'web-privacy']


def dependency_resolution():
    """Record the existing workspace lock without modifying or publishing it."""
    workspace_bytes = (ROOT / 'pubspec.lock').read_bytes()
    published_bytes = subprocess.run(
        ['git', 'show', 'HEAD:pubspec.lock'], cwd=ROOT,
        check=True, capture_output=True).stdout

    def versions(content):
        current, selected = None, {}
        for line in content.decode('utf-8-sig').splitlines():
            package = re.fullmatch(r'  ([A-Za-z0-9_]+):', line)
            if package:
                current = package.group(1)
            value = re.match(r'''    version:\s*["']?([^"'\s]+)''', line)
            if value and current in ['jni', 'shared_preferences_android']:
                selected[current] = value.group(1)
        assert set(selected) == {'jni', 'shared_preferences_android'}, 'Missing dependency-resolution evidence'
        return selected

    return {
        'lockfile': 'pubspec.lock',
        'workspaceSha256': hashlib.sha256(workspace_bytes).hexdigest(),
        'publishedGitReference': 'HEAD:pubspec.lock',
        'publishedSha256': hashlib.sha256(published_bytes).hexdigest(),
        'workspaceVersions': versions(workspace_bytes),
        'publishedVersions': versions(published_bytes),
        'workspaceDiffersFromPublished': workspace_bytes != published_bytes,
        'preexistingLocalChangesPreserved': True,
        'published': False,
        'note': 'The binary was built with the pre-existing workspace dependency resolutions. The local lockfile change is not published; a byte-identical rebuild from published sources is not claimed.',
    }


def audit_release(apk, aapt):
    version = re.search(r'^version:\s*(\S+)', (ROOT / 'pubspec.yaml').read_text(encoding='utf-8'), re.M).group(1)
    version_name, version_code = version.split('+')
    compiled_web_sha = hashlib.sha256((ROOT / 'build/web/main.dart.js').read_bytes()).hexdigest()
    browser_reports = {}
    for name in ['COURSE_BROWSER_AUDIT', 'DASHBOARD_BROWSER_AUDIT', 'NETWORK_BROWSER_AUDIT']:
        report = json.loads((ROOT / 'docs' / f'{name}.json').read_text(encoding='utf-8'))
        assert report['status'] == 'passed' and report['version'] == version, f'{name} is not current'
        assert report['compiledWebSha256'] == compiled_web_sha, f'{name} is from a different web build'
        assert not report['errors'], f'{name} has unresolved browser errors'
        for source in report['sourceFiles']:
            assert hashlib.sha256((ROOT / source['path']).read_bytes()).hexdigest() == source['sha256'], f'Stale {name}: {source["path"]}'
        for screenshot in report['screenshots']:
            assert (ROOT / 'docs/screenshots' / screenshot).is_file(), f'Missing browser evidence: {screenshot}'
        browser_reports[name] = report
    interface, dashboard, network_browser = (browser_reports[name] for name in
        ['COURSE_BROWSER_AUDIT', 'DASHBOARD_BROWSER_AUDIT', 'NETWORK_BROWSER_AUDIT'])
    assert len(dashboard['paths']) == 6, 'Expected six learning paths'
    reports = {}
    for name in ['AOI_BANK_AUDIT', 'AOI_VISUAL_AUDIT', 'COURSE_CONTENT_AUDIT', 'STARTER_PRACTICE_AUDIT', 'MALWARE_CONTENT_AUDIT', 'SECURE_CONTENT_AUDIT', 'LINUX_CONTENT_AUDIT', 'LAB_CONTENT_AUDIT', 'NETWORK_EXPANSION_AUDIT']:
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
    expansion = reports['NETWORK_EXPANSION_AUDIT']
    assert expansion['partial'] is False and expansion['courses'] == 6
    assert expansion['lessons'] == 60 and expansion['course_exercises'] == 360
    assert expansion['reinforcement_exercises'] == 240 and expansion['explained_cases'] == 120
    for course_id in NETWORK_IDS:
        course = json.loads((ROOT / 'assets/network_expansion' / f'{course_id}.json').read_text(encoding='utf-8'))
        assert course['id'] == course_id and len(course['lessons']) == 10
        course_count += 1
        for lesson in course['lessons']:
            assert len(lesson['questions']) == 6 and len(lesson['cases']) == 2
            assert 600 <= sum(len(section['body'].split()) for section in lesson['sections']) <= 900
            lesson_ids.append(lesson['id'])
            exercises += len(lesson['questions'])
    reinforcement_keys = []
    for course_id in REINFORCED_IDS:
        original = json.loads((ROOT / 'assets/courses' / f'{course_id}.json').read_text(encoding='utf-8-sig'))
        expected = {lesson['id'] for lesson in original['lessons']}
        authored = (ROOT / 'assets/network_expansion' / f'{course_id}.practice.md').read_text(encoding='utf-8')
        keys = re.findall(r'^@practice ([^|]+)\|', authored, re.M)
        assert len(keys) == 40 and len(set(keys)) == 40 and set(keys) == expected, f'Incomplete reinforcement mapping: {course_id}'
        assert len(re.findall(r'^@q ', authored, re.M)) == 40, f'Incomplete reinforcement questions: {course_id}'
        reinforcement_keys.extend(keys)
    assert len(reinforcement_keys) == len(set(reinforcement_keys)) == 240
    generated = (ROOT / 'lib/src/data/network_expansion.g.dart').read_text(encoding='utf-8')
    generated_practice = generated.split('networkReinforcementQuestions = {', 1)[1]
    exported_keys = re.findall(r"'([^']+)'\s*:\s*Question\(", generated_practice)
    assert len(exported_keys) == 240 and set(exported_keys) == set(reinforcement_keys), 'Compiled bank differs from authored reinforcement keys'
    practice_source = (ROOT / 'lib/src/data/network_practice.dart').read_text(encoding='utf-8')
    assert "id: '${lesson.id}-reinforcement'" in practice_source, 'Reinforcement ID strategy changed; review audit'
    reinforcement_ids = [f'{key}-reinforcement' for key in reinforcement_keys]
    assert not set(reinforcement_ids).intersection(lesson_ids), 'Reinforcement ID collides with a regular lesson'
    exercises += len(reinforcement_keys)
    assert len(lesson_ids) == len(set(lesson_ids)), 'Duplicate lesson IDs'
    assert (course_count, len(lesson_ids), exercises) == (31, 490, 1530), 'Unexpected academy totals'
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
        missing_reinforcement_keys = [key for key in reinforcement_keys if key.encode('ascii') not in compiled]
        assert not missing_reinforcement_keys, f'Missing compiled reinforcement base keys: {missing_reinforcement_keys}'
        assert b'-reinforcement' in compiled, 'Missing compiled reinforcement ID suffix'
        assert all(ident.encode('ascii') in compiled for ident in NETWORK_IDS), 'Missing compiled network course'
        certification_ids = ['ccst-networking', 'ccst-cybersecurity', 'isc2-cc', 'ccna']
        guide_source = (ROOT / 'lib/src/data/certification_guides.dart').read_text(encoding='utf-8')
        assert re.findall(r"CertificationGuide\(\s*id:\s*'([^']+)'", guide_source) == certification_ids, 'Unexpected certification guide mapping'
        certification_titles = ['Cisco CCST Networking', 'Cisco CCST Cybersecurity',
                                'ISC2 Certified in Cybersecurity (CC)', 'Cisco CCNA']
        assert all(title.encode('ascii') in compiled for title in certification_titles), 'Missing compiled certification guidance titles'
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
        'dependency_resolution': dependency_resolution(),
        'bytes': apk.stat().st_size, 'sha256': hashlib.sha256(apk.read_bytes()).hexdigest(),
        'portraits': len(portraits), 'course_covers': len(covers),
        'course_interface_source_files': interface['sourceFiles'],
        'dashboard_source_files': dashboard['sourceFiles'],
        'network_source_files': network_browser['sourceFiles'],
        'compiled_web_sha256': compiled_web_sha,
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
        'advanced_network_courses': expansion['courses'],
        'advanced_network_lessons': expansion['lessons'],
        'advanced_network_exercises': expansion['course_exercises'],
        'advanced_network_explained_cases': expansion['explained_cases'],
        'advanced_network_theory_words': expansion['theory_words'],
        'network_authored_aoi_lines': expansion['authored_aoi_lines'],
        'network_reinforcement_exercises': len(reinforcement_keys),
        'reinforced_course_ids': REINFORCED_IDS,
        'certification_guides': certification_ids,
        'compiled_certification_titles': certification_titles,
        'offline_labs': reports['LAB_CONTENT_AUDIT']['labs'],
        'lab_stages': reports['LAB_CONTENT_AUDIT']['stages'],
        'lab_authored_aoi_lines': reports['LAB_CONTENT_AUDIT']['authored_aoi_lines'],
        'compiled_lesson_ids': len(lesson_ids), 'compiled_regular_lesson_ids': len(lesson_ids),
        'missing_lesson_ids': missing,
        'compiled_reinforcement_base_keys': len(reinforcement_keys),
        'missing_reinforcement_base_keys': missing_reinforcement_keys,
        'reinforcement_id_strategy': '240 runtime IDs from verified compiled base keys plus the compiled -reinforcement suffix; not 240 literal full IDs',
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
