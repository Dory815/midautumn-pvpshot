#!/usr/bin/env python3
"""Package a verified world, official server runtime and server-only datapack.

No download, EULA acceptance, server launch, or existing-world replacement.
"""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[1]
SERVER_SHA1 = '823e2250d24b3ddac457a60c92a6a941943fcd6a'


def archive(folder, target, prefix=''):
    with zipfile.ZipFile(target, 'w', zipfile.ZIP_DEFLATED) as z:
        for path in sorted(folder.rglob('*')):
            if path.is_file() and path.name != '.DS_Store' and '__pycache__' not in path.parts:
                z.write(path, str(Path(prefix) / path.relative_to(folder)))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--world', type=Path, required=True)
    parser.add_argument('--server-jar', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--protection-dir', type=Path)
    args = parser.parse_args()
    if args.output.exists():
        raise SystemExit('Choose a fresh output directory; existing releases are never overwritten.')
    if hashlib.sha1(args.server_jar.read_bytes()).hexdigest() != SERVER_SHA1:
        raise SystemExit('Expected the verified official Java 26.2 server jar.')
    campus = (args.world / 'datapacks/ustc_pvp/pack.mcmeta').is_file()
    if campus:
        if not args.protection_dir:
            raise SystemExit('Campus server release requires --protection-dir with the verified server module.')
        for name in ['pvpshot-protection-26.2.jar', 'pvpshot-protection-runtime-26.2.jar', 'regions.tsv']:
            if not (args.protection_dir/name).is_file():raise SystemExit('Missing facility protection file: '+name)
    packs = ['pvpshot', 'ustc_pvp' if campus else 'pvp_test']
    for pack in packs:
        if not (args.world / 'datapacks' / pack / 'pack.mcmeta').is_file():
            raise SystemExit('World is missing required pack: ' + pack)
    # Do not distribute a stale world alongside newer production code.
    for pack in packs if campus else ['pvpshot']:
        source = {p.relative_to(ROOT/pack): p.read_bytes() for p in (ROOT/pack).rglob('*') if p.is_file()}
        worldpack = {p.relative_to(args.world/'datapacks'/pack): p.read_bytes() for p in (args.world/'datapacks'/pack).rglob('*') if p.is_file()}
        if source != worldpack:
            raise SystemExit('Rebuild the world: its datapack differs from the source: '+pack)
    args.output.mkdir(parents=True)
    formal = args.output / '正式服代码'
    formal.mkdir()
    shutil.copytree(ROOT/'pvpshot', formal/'pvpshot')
    shutil.copy2(ROOT/('tools/ustc_world/正式服部署.md' if campus else '说明.md'), formal/'说明.md')
    shutil.copy2(ROOT/'武器平衡表.md', formal/'武器平衡表.md')
    archive(ROOT/'pvpshot', formal/'pvpshot-26.2.zip')
    if campus:
        sys.path.insert(0,str(ROOT/'tools/ustc_world'))
        from make_pack import make_pack
        make_pack(formal/'ustc_pvp',test_controls=1)
        archive(formal/'ustc_pvp', formal/'ustc_pvp-26.2.zip')
        (formal/'protection').mkdir()
        for name in ['pvpshot-protection-26.2.jar', 'pvpshot-protection-runtime-26.2.jar', 'regions.tsv']:
            shutil.copy2(args.protection_dir/name, formal/'protection'/name)
        shutil.copy2(ROOT/'server_protection/README.md',formal/'protection/说明.md')
        shutil.copytree(ROOT/'server_protection/src',formal/'protection/src')
        shutil.copy2(ROOT/'地图方案/科大中区-点位讨论.md',formal/'中区地图说明.md')
        shutil.copy2(ROOT/'地图方案/移动能力评估.md',formal/'移动能力评估.md')
        for name in ['科大中区-部署图.png','实际点位.json']:
            shutil.copy2(ROOT/'地图方案'/name,formal/name)
    server = args.output / '测试服务端'
    server.mkdir()
    shutil.copytree(args.world, server/'world')
    shutil.copy2(args.server_jar, server/'server.jar')
    for path in (ROOT/'tools/server_template').iterdir():
        shutil.copy2(path, server/path.name)
    if campus:
        shutil.copytree(formal/'protection',server/'protection')
        (server/'protection-required.txt').write_text('Campus facilities require the bundled server protection module.\n')
    (server/'start.sh').chmod(0o755)
    (server/'启动测试服.command').chmod(0o755)
    shutil.copy2(ROOT/'测试存档/打开与测试.md', server/'场地使用说明.md')
    archive(server, args.output/'PVP测试服务端-26.2.zip', 'PVP测试服务端-26.2')
    manifest = {
        'minecraft': '26.2', 'java_major': 25,
        'server_sha1': SERVER_SHA1, 'eula_accepted': False,
        'world': '测试服务端/world', 'friendly_fire': True, 'max_health': 20,
        'production_pack': '正式服代码/pvpshot-26.2.zip',
        'map_pack': '正式服代码/ustc_pvp-26.2.zip' if campus else None,
        'map': 'USTC_project independent copy' if campus else 'flat arena',
        'balance_revision': 8, 'controls_revision': 1, 'server_protection': campus, 'protected_regions': 181 if campus else 0,
        'rifle_damage':6, 'rifle_magazine':16, 'rifle_splash':{'radius':1.5,'inner_radius':1,'inner_damage':3,'outer_damage':1}, 'demolition_damage':2,
        'spawn_secondary_pool':['snowball','egg','trident'], 'snow_field':{'count':4,'radius':3,'duration_seconds':5,'damage_per_second':2,'slowness':4,'friendly_fire':True,'stacking_damage':False},
        'spawn_rockets':1, 'supply_rockets':4, 'gym_rockets':6, 'full_hunger':True, 'enemy_mark_seconds':2,
        'campus_supply_boxes':80 if campus else None, 'campus_cover_groups':100 if campus else None,
        'movement': {'speed':0,'jump_boost':0} if campus else None,
        'rifle_cooldown_seconds':0.3, 'advanced_caches':{'count':2,'interval_seconds':300,'fighter_chance':0.0625,'rare_chance':0.25,'positions':[[-1858,2,-1630],[-1843,2,-1410]],'pool':['fighter','orbital380','eagle500','airburst']},
        'crossbow':{'load_seconds':3,'lethal_min_distance':20,'close_damage':4,'straight':True,'limit_per_player':1,'range':240}, 'bow_proximity':{'arm_distance':20,'trigger_radius':0.75,'blast_radius':2.5},
        'fighter':{'cannon':24,'bombs':4,'boosts':12,'exit':'30_seconds_or_both_ammunition_exhausted','duration_seconds':30},'smg':{'rounds':48,'rounds_per_second':20/3,'close_damage':4},
        'shotgun':{'pellets':10,'near_damage_per_pellet':3,'range':24,'cooldown_seconds':1.2},'roof_points':{'A':[-1990,28,-1535],'C':[-1710,29,-1535]},'shield':{'absorption':0.5,'durability':96},
        'public_test_controls': {'test_world':True,'formal_pack':True},
        'files_sha256': {str(p.relative_to(args.output)): hashlib.sha256(p.read_bytes()).hexdigest()
                         for p in sorted(args.output.rglob('*')) if p.is_file()}
    }
    (args.output/'manifest.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2)+'\n')
    print('Release:', args.output)


if __name__ == '__main__':
    main()
