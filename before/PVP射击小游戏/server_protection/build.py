#!/usr/bin/env python3
"""Build a server-only agent with Java 25's standard Class-File API; no downloads."""
from pathlib import Path
import argparse, subprocess, sys, zipfile
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools/ustc_world'))
from make_pack import protection_regions
ap=argparse.ArgumentParser()
ap.add_argument('--java-home',type=Path,required=True)
ap.add_argument('--output',type=Path,required=True)
ap.add_argument('--server-jar',type=Path,default=ROOT/'发布/测试服务端/server.jar')
a=ap.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=True)
classes=out/'classes';classes.mkdir(exist_ok=True)
cache=Path('/tmp/pvpshot-public-reset-20260922/jars')
if not cache.exists():
    cache=out/'jars'
    with zipfile.ZipFile(a.server_jar) as archive:
        for name in archive.namelist():
            if name.endswith('.jar') and name.startswith(('META-INF/versions/','META-INF/libraries/')):
                p=cache/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(archive.read(name))
cp=':'.join(str(p) for p in cache.rglob('*.jar'))
subprocess.run([str(a.java_home/'bin/javac'),'-encoding','UTF-8','-cp',cp,'-d',str(classes),
    *[str(p) for p in (ROOT/'server_protection/src').rglob('*.java')]],check=True)
manifest=out/'MANIFEST.MF'
manifest.write_text('Manifest-Version: 1.0\nPremain-Class: pvpshot.protection.ProtectionAgent\n\n')
for name,patterns,extra in [('pvpshot-protection-26.2.jar',['ProtectionAgent*.class','GameplayRules*.class','GameplayV8*.class'],['--manifest',str(manifest)]),
                           ('pvpshot-protection-runtime-26.2.jar',['ProtectionRules*.class','GameplayBridge*.class'],[])]:
    command=[str(a.java_home/'bin/jar'),'--create','--file',str(out/name),*extra]
    for pattern in patterns:
        for p in sorted(classes.rglob(pattern)):command+=['-C',str(classes),str(p.relative_to(classes))]
    subprocess.run(command,check=True)
(out/'regions.tsv').write_text('# x0 y0 z0 x1 y1 z1 label; inclusive block coordinates\n'+
    ''.join(' '.join(map(str,bounds))+' '+label+'\n' for bounds,label in protection_regions()))
print(out/'pvpshot-protection-26.2.jar')
