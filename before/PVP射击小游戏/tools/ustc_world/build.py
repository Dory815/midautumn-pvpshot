"""Build an isolated playable campus copy and validate it with the official engine."""
from pathlib import Path
import sys,argparse,subprocess,zipfile,json,shutil,re,importlib.util,time
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools/test_world'))
from nbt import read,write
from make_pack import make_pack,LOBBY
FOLDER='USTC_PVP_Field_26.2'
def export(source,generated,output):
 target=output/FOLDER
 if target.exists():raise RuntimeError('Output exists; choose a new directory')
 shutil.copytree(source,target,ignore=shutil.ignore_patterns('session.lock','level.dat_old','players','voxy','syncmatica','serenitea_pot','scripts','datapacks','.DS_Store'))
 # Retain the rest of the campus; replace only the four arena region files touched by the engine.
 for folder in ['region','entities','poi']:
  for rx in [-5,-4]:
   for rz in [-4,-3]:
    name=f'r.{rx}.{rz}.mca';p=generated/'dimensions/minecraft/overworld'/folder/name
    if p.exists():shutil.copy2(p,target/'dimensions/minecraft/overworld'/folder/name)
 shutil.copytree(generated/'dimensions/ustc_pvp',target/'dimensions/ustc_pvp')
 # Rules and scheduler state must correspond to the verified map, not the author's editor session.
 for name in ['game_rules.dat','weather.dat','world_clocks.dat','custom_boss_events.dat','scoreboard.dat']:
  p=generated/'data/minecraft'/name
  if p.exists():shutil.copy2(p,target/'data/minecraft'/name)
 for name in ['scheduled_events.dat','stopwatches.dat']:(target/'data/minecraft'/name).unlink(missing_ok=True)
 for namespace in ['ustc_pvp','pvpshot']:
  p=generated/'data'/namespace
  if p.exists():shutil.copytree(p,target/'data'/namespace,dirs_exist_ok=True)
 for p in (generated/'dimensions/minecraft/overworld/data').rglob('*'):
  if p.is_file() and 'forced' in p.name:
   q=target/'dimensions/minecraft/overworld/data'/p.relative_to(generated/'dimensions/minecraft/overworld/data');q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
 shutil.copytree(ROOT/'pvpshot',target/'datapacks/pvpshot');shutil.copytree(ROOT/'ustc_pvp',target/'datapacks/ustc_pvp')
 nbt=read(target/'level.dat');d=nbt[1][1]['Data'][1];d['LevelName']=(8,'科大中区 · 霜蚀雪球测试');d['GameType']=(3,0);d['difficulty_settings']=(10,{'difficulty':(8,'normal'),'hardcore':(1,0),'locked':(1,0)});d['enabled_features']=(9,(8,['minecraft:vanilla']));d['allowCommands']=(1,1);d['LastPlayed']=(4,int(time.time()*1000));d['spawn']=(10,{'pos':(11,list(LOBBY)),'pitch':(5,0.),'yaw':(5,180.),'dimension':(8,'minecraft:overworld')});d['DataPacks']=(10,{'Enabled':(9,(8,['vanilla','file/pvpshot','file/ustc_pvp'])),'Disabled':(9,(8,[]))});d.pop('Player',None);d.pop('singleplayer_uuid',None);write(target/'level.dat',nbt)
 # Add the private restoration dimension to the author's original worldgen data.
 p=target/'data/minecraft/world_gen_settings.dat';w=read(p);dims=w[1][1]['data'][1]['dimensions'][1];g=read(generated/'data/minecraft/world_gen_settings.dat');dims['ustc_pvp:template']=g[1][1]['data'][1]['dimensions'][1]['ustc_pvp:template'];write(p,w)
 return target

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--java-home',type=Path,required=True);ap.add_argument('--server-jar',type=Path,required=True);ap.add_argument('--source',type=Path,default=ROOT/'USTC_project');ap.add_argument('--work-dir',type=Path,required=True);ap.add_argument('--output',type=Path,required=True);ap.add_argument('--protection-agent',type=Path);a=ap.parse_args()
 source=a.source.resolve();work=a.work_dir.resolve();out=a.output.resolve()
 assert source!=work and not work.is_relative_to(source) and not out.is_relative_to(source)
 if (out/FOLDER).exists():raise SystemExit('Output save exists')
 work.mkdir(parents=True,exist_ok=True);jars=[]
 with zipfile.ZipFile(a.server_jar) as archive:
  for n in archive.namelist():
   if n.endswith('.jar') and n.startswith(('META-INF/versions/','META-INF/libraries/')):
    p=work/'jars'/n;p.parent.mkdir(parents=True,exist_ok=True)
    if not p.exists():p.write_bytes(archive.read(n))
    jars.append(str(p))
 cp=':'.join(jars);classes=work/'classes';classes.mkdir(exist_ok=True)
 subprocess.run([str(a.java_home/'bin/javac'),'-encoding','UTF-8','-cp',cp,'-d',str(classes),str(ROOT/'tests/TestMain.java'),str(ROOT/'tools/ustc_world/BuildCampus.java')],check=True)
 packs=work/'packs';packs.mkdir(exist_ok=True)
 for name in ['pvpshot','ustc_pvp','campusbuild']:
  if (packs/name).exists():shutil.rmtree(packs/name)
 shutil.copytree(ROOT/'pvpshot',packs/'pvpshot');shutil.copytree(ROOT/'ustc_pvp',packs/'ustc_pvp')
 test=packs/'campusbuild';test.mkdir();(test/'pack.mcmeta').write_text(json.dumps({'pack':{'description':'Campus validation only','min_format':[107,1],'max_format':107}}))
 # GameTest deliberately ignores extra dimension entries and uses the flat preset.
 # Extend that preset in the test-only pack so native cross-dimension reset is tested.
 inner=next(Path(p) for p in jars if '/versions/' in p)
 with zipfile.ZipFile(inner) as z: preset=json.loads(z.read('data/minecraft/worldgen/world_preset/flat.json'))
 preset['dimensions']['ustc_pvp:template']=json.loads((ROOT/'ustc_pvp/data/ustc_pvp/dimension/template.json').read_text())
 preset_file=test/'data/minecraft/worldgen/world_preset/flat.json';preset_file.parent.mkdir(parents=True,exist_ok=True);preset_file.write_text(json.dumps(preset))
 spec=importlib.util.spec_from_file_location('structures',ROOT/'tools/build_structures.py');builder=importlib.util.module_from_spec(spec);spec.loader.exec_module(builder);builder.ROOT=test/'data/campusbuild';(builder.ROOT/'structure').mkdir(parents=True);builder.write_structure('empty',[1,1,1],{(0,0,0):('smooth_stone',{})});(builder.ROOT/'test_instance').mkdir();(builder.ROOT/'test_instance/suite.json').write_text(json.dumps({'type':'minecraft:function','environment':'minecraft:default','structure':'campusbuild:empty','function':'campusbuild:suite','max_ticks':6000,'sky_access':True}))
 agent_args=[] if not a.protection_agent else ['-javaagent:'+str(a.protection_agent.resolve())+'='+str(a.protection_agent.resolve().parent/'regions.tsv')]
 command=[str(a.java_home/'bin/java'),'-Xms256M','-Xmx3G',*agent_args,'-Dustc.source='+str(source),'-Dustc.pack='+str(ROOT/'ustc_pvp'),'-cp',str(classes)+':'+cp,'BuildCampus','--packs',str(packs),'--tests','campusbuild:*','--universe',str(work/'generated-world'),'--report',str(work/'report.xml')]
 print('Building from read-only original:',source,flush=True)
 with (work/'build.log').open('w') as log:r=subprocess.run(command,cwd=work,stdout=log,stderr=subprocess.STDOUT,timeout=600)
 log=(work/'build.log').read_text();print(log)
 if r.returncode or re.search(r'Couldn.t parse|Failed to load|/ERROR\]|Serialization errors',log):raise SystemExit('Native validation failed; no world exported')
 out.mkdir(parents=True,exist_ok=True);target=export(source,work/'generated-world/gametestworld',out);shutil.copy2(work/'build.log',out/'中区构建验证.log');shutil.copy2(work/'report.xml',out/'中区构建验证.xml');print('Verified world:',target)
if __name__=='__main__':main()
