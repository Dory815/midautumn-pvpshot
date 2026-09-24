#!/usr/bin/env python3
"""Run tests against an official 26.2 server jar, with Java 25, in a temporary world.

No client, existing save, global Java installation, or third-party mod is used.
"""
import argparse
import importlib.util
import json
import re
from pathlib import Path
import shutil
import subprocess
import zipfile

parser = argparse.ArgumentParser()
parser.add_argument('--java-home', type=Path, required=True)
parser.add_argument('--server-jar', type=Path, required=True)
parser.add_argument('--work-dir', type=Path, required=True)
parser.add_argument('--suite', choices=['weapons', 'modes', 'rifle', 'field', 'protection', 'balance', 'revision8'], default='weapons')
parser.add_argument('--protection-agent', type=Path)
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
work = args.work_dir.resolve()
work.mkdir(parents=True, exist_ok=True)
jars = []
with zipfile.ZipFile(args.server_jar) as archive:
    for name in archive.namelist():
        if name.endswith('.jar') and name.startswith(('META-INF/versions/', 'META-INF/libraries/')):
            path = work / 'jars' / name
            path.parent.mkdir(parents=True, exist_ok=True)
            if not path.exists():
                path.write_bytes(archive.read(name))
            jars.append(str(path))
cp = ':'.join(jars)
classes = work / 'classes'
classes.mkdir(exist_ok=True)
main_class={'weapons':'TestMain','modes':'ModeAudit','rifle':'RifleAudit','field':'FieldAudit','protection':'ProtectionAudit','balance':'BalanceAudit','revision8':'Revision8Audit'}[args.suite]
sources = [str(root / 'tests/TestMain.java')]
if args.suite != 'weapons':
    sources.append(str(root / ('tests/'+main_class+'.java')))
subprocess.run([str(args.java_home / 'bin/javac'), '-encoding', 'UTF-8', '-cp', cp,
                '-d', str(classes), *sources], check=True)
packs = work / 'packs'
packs.mkdir(exist_ok=True)
if (packs / 'pvpshot').exists():
    shutil.rmtree(packs / 'pvpshot')
shutil.copytree(root / 'pvpshot', packs / 'pvpshot')
if (packs / 'ustc_pvp').exists():
    shutil.rmtree(packs / 'ustc_pvp')
if args.suite == 'protection':
    shutil.copytree(root/'ustc_pvp', packs/'ustc_pvp', dirs_exist_ok=True)
testpack = packs / 'pvptest'
if testpack.exists():shutil.rmtree(testpack)
testpack.mkdir(exist_ok=True)
(testpack / 'pack.mcmeta').write_text(json.dumps({'pack': {'description': 'PVP regression tests', 'min_format': [107, 1], 'max_format': 107}}))
if args.suite == 'protection':
    for event in ['load','tick']:
        tag=testpack/'data/minecraft/tags/function'/(event+'.json')
        tag.parent.mkdir(parents=True,exist_ok=True)
        tag.write_text(json.dumps({'replace':True,'values':['pvpshot:'+event]}))
spec = importlib.util.spec_from_file_location('structures', root / 'tools/build_structures.py')
builder = importlib.util.module_from_spec(spec)
spec.loader.exec_module(builder)
builder.ROOT = testpack / 'data/pvptest'
(builder.ROOT / 'structure').mkdir(parents=True, exist_ok=True)
builder.write_structure('arena', [48, 12, 48], {(x, 0, z): ('smooth_stone', {}) for x in range(48) for z in range(48)})
(builder.ROOT / 'test_instance').mkdir(exist_ok=True)
(builder.ROOT / 'test_instance/suite.json').write_text(json.dumps({
    'type': 'minecraft:function', 'environment': 'minecraft:default',
    'structure': 'pvptest:arena', 'function': 'pvptest:suite', 'max_ticks': 1300, 'sky_access': True
}))
agent_args=[]
if args.protection_agent:
    agent=args.protection_agent.resolve()
    agent_args=['-javaagent:'+str(agent)+'='+str(agent.parent/'regions.tsv'),'-Dpvpshot.protection.regions='+str(agent.parent/'regions.tsv')]
command = [str(args.java_home / 'bin/java'), '-Xms256M', '-Xmx1G', *agent_args, '-cp', str(classes) + ':' + cp,
           main_class, '--packs', str(packs), '--tests', 'pvptest:*',
           '--universe', str(work / 'generated-world'), '--report', str(work / 'report.xml')]
print('Testing in', work, flush=True)
with (work / 'run.log').open('w') as log:
    result = subprocess.run(command, cwd=work, stdout=log, stderr=subprocess.STDOUT, timeout=150)
log_text = (work / 'run.log').read_text()
print(log_text)
load_errors = re.findall(r'^.*(?:Couldn.t parse|Failed to load|Expected end of options|/ERROR\]).*$', log_text, re.MULTILINE)
if load_errors:
    print('Engine errors detected; this run is not a pass.')
raise SystemExit(result.returncode or bool(load_errors))
