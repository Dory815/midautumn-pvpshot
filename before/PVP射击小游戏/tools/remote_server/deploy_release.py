#!/usr/bin/env python3
"""Install a verified release into a fresh directory, without accepting EULA."""
import hashlib
import json
from pathlib import Path
import shutil
import sys
import zipfile


def digest(path):
    with path.open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def extract(archive, destination, prefix=''):
    with zipfile.ZipFile(archive) as package:
        for entry in package.infolist():
            if entry.is_dir():
                continue
            if prefix and not entry.filename.startswith(prefix):
                raise ValueError('Unexpected archive prefix: ' + entry.filename)
            relative = Path(entry.filename[len(prefix):])
            target = destination / relative
            if not target.resolve().is_relative_to(destination.resolve()):
                raise ValueError('Unsafe archive path: ' + entry.filename)
            target.parent.mkdir(parents=True, exist_ok=True)
            with package.open(entry) as source, target.open('xb') as output:
                shutil.copyfileobj(source, output)


base = Path(sys.argv[1]).resolve()
release = base / 'release'
manifest = json.loads((release / 'manifest.json').read_text())
checksums = manifest['files_sha256']
archives = {
    'PVP测试服务端-26.2.zip': 'PVP测试服务端-26.2.zip',
    'pvpshot-26.2.zip': '正式服代码/pvpshot-26.2.zip',
    'ustc_pvp-26.2.zip': '正式服代码/ustc_pvp-26.2.zip',
}
assert not (base / 'world').exists(), 'Refusing to overwrite an existing world'
assert not (base / 'server.jar').exists(), 'Refusing to overwrite a server installation'
for name, key in archives.items():
    assert digest(release / name) == checksums[key], 'Archive checksum mismatch: ' + name
extract(release / 'PVP测试服务端-26.2.zip', base, 'PVP测试服务端-26.2/')
verified = 0
for key, expected in checksums.items():
    if key.startswith('测试服务端/'):
        path = base / key.removeprefix('测试服务端/')
        assert digest(path) == expected, 'World/server checksum mismatch: ' + key
        verified += 1
for pack in ('pvpshot', 'ustc_pvp'):
    destination = base / 'world' / 'datapacks' / pack
    shutil.rmtree(destination)  # Only the freshly extracted, verified test pack.
    extract(release / (pack + '-26.2.zip'), destination)
    expected_files = {}
    prefix = '正式服代码/' + pack + '/'
    for key, expected in checksums.items():
        if key.startswith(prefix):
            relative = key.removeprefix(prefix)
            expected_files[relative] = expected
    actual_files = {str(p.relative_to(destination)): digest(p)
                    for p in destination.rglob('*') if p.is_file()}
    assert actual_files == expected_files, 'Formal datapack mismatch: ' + pack
config = base / 'world/datapacks/ustc_pvp/data/ustc_pvp/function/configure.mcfunction'
assert 'scoreboard players set #test.controls pvpshot.cfg 1' in config.read_text()
template = base / 'world/dimensions/ustc_pvp/template'
assert any(template.rglob('*.mca')), 'Terrain restoration template missing'
properties = base / 'server.properties'
text = properties.read_text()
assert 'server-port=25565\n' in text
properties.write_text(text.replace('server-port=25565\n', 'server-port=28898\n'))
assert 'eula=false' in (base / 'eula.txt').read_text()
(base / 'start.sh').chmod(0o755)
report = {
    'minecraft': manifest['minecraft'],
    'balance_revision': manifest['balance_revision'],
    'verified_original_server_files': verified,
    'formal_packs_verified': True,
    'terrain_template_present': True,
    'public_test_controls': True,
    'port': 28898,
    'eula_accepted': False,
    'started': False,
}
(base / 'deployment-check.json').write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps(report, indent=2))
