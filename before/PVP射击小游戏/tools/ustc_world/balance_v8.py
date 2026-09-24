"""Rooftop facilities, visible capture beacons and neutral rare-equipment caches."""
import json
# Locations lie near the perpendicular bisector of the two initial bases.
ADVANCED=[(-1858,2,-1630,'北区'),(-1843,2,-1410,'南区')]
ROOFS={'A':(-1990,28,-1535),'C':(-1710,29,-1535)}
def regions():
 out=[]
 for k,(x,y,z) in ROOFS.items():
  out += [((x-2,y-1,-1555,x+2,y-1,-1544),'roof_'+k+'_dive'),((x-5,-1,-1565,x+5,2,-1555),'roof_'+k+'_pool'),((x-2,0,-1570,x+2,4,-1566),'roof_'+k+'_launcher')]
 return out

def extend(path,points):
 def fn(name,lines):
  p=path/'data/ustc_pvp/function'/f'{name}.mcfunction';p.parent.mkdir(parents=True,exist_ok=True);p.write_text('\n'.join(lines)+'\n')
 def append(name,lines):
  p=path/'data/ustc_pvp/function'/f'{name}.mcfunction';p.write_text(p.read_text().rstrip()+'\n'+'\n'.join(lines)+'\n')
 build=['scoreboard players set #protection.edit ustc.clock 1','kill @e[tag=ustc.launch]','kill @e[tag=ustc.roof_label]']
 for k,(x,y,z) in ROOFS.items():
  build += [f'fill {x-9} {y-1} {z-9} {x+9} {y-1} {z+9} smooth_stone',f'fill {x-9} {y} {z-9} {x+9} {y+4} {z+9} air',f'fill {x-2} {y-1} -1555 {x+2} {y-1} -1544 smooth_stone',f'fill {x-2} {y} -1555 {x+2} {y+2} -1544 air',f'fill {x-5} -1 -1565 {x+5} -1 -1555 bedrock',f'fill {x-5} 0 -1565 {x+5} 1 -1555 stone_bricks',f'fill {x-4} 0 -1564 {x+4} 1 -1556 water',f'fill {x-5} 2 -1565 {x+5} 3 -1555 air',f'fill {x-2} 1 -1570 {x+2} 1 -1566 polished_deepslate',f'fill {x-2} 2 -1570 {x+2} 4 -1566 air',f'setblock {x} 1 -1568 slime_block',f'summon marker {x+.5} 2 -1567.5 '+json.dumps({'Tags':['ustc.marker','ustc.launch','ustc.launch.'+k,f'pvp.launch:{x+.5},{y},-1541.5']},separators=(',',':'))]
  for bx,by,bz,title in [(x+.5,5,-1567.5,k+' 楼顶弹射器 · 站上中心'),(x+.5,y+2,-1554.5,'下楼落水区 ↓')]:
   build += [f'summon text_display {bx} {by} {bz} '+json.dumps({'Tags':['ustc.decor','ustc.roof_label'],'text':{'text':title,'color':'aqua'},'billboard':'center','background':1073741824},ensure_ascii=False,separators=(',',':'))]
 fn('v8/facilities',build+['scoreboard players set #protection.edit ustc.clock 0'])
 # Install roof surfaces before the standard point markers and beacons.
 p=path/'data/ustc_pvp/function/build.mcfunction';s=p.read_text().replace('function ustc_pvp:points/build','function ustc_pvp:v8/facilities\nscoreboard players set #protection.edit ustc.clock 1\nfunction ustc_pvp:points/build');p.write_text(s)
 append('build',['data modify storage ustc_pvp:state balance_v8 set value 1b'])
 p=path/'data/ustc_pvp/function/advanced/build.mcfunction';s=p.read_text().replace('点高级航空补给\\n5 分钟刷新 · 战斗机 25%','独立高级补给\\n5 分钟刷新 · 稀有装备 100%');p.write_text(s)
 fn('advanced/one',['data modify block ~ ~ ~ Items set value []','execute store result score #aircraft.roll ustc.clock run random value 1..4',*[f'execute if score #aircraft.roll ustc.clock matches {i} run loot insert ~ ~ ~ loot pvpshot:item/{id}' for i,id in enumerate(['fighter','orbital380','eagle500','airburst'],1)],'execute if score #aircraft.roll ustc.clock matches 4 run loot insert ~ ~ ~ loot pvpshot:item/airburst','execute store result score #rocket.roll ustc.clock run random value 1..2','execute if score #rocket.roll ustc.clock matches 1 run loot insert ~ ~ ~ loot pvpshot:item/rocket',*[f'loot insert ~ ~ ~ loot pvpshot:item/{id}' for id in ['speed','jump','heal','grenade','bow','crossbow','shotgun','bunker']],'execute store result score #mace.roll ustc.clock run random value 1..20','execute if score #mace.roll ustc.clock matches 1 run loot insert ~ ~ ~ loot pvpshot:item/mace'])
 append('test_kit',[f'loot give @s loot pvpshot:item/{id}' for id in ['shotgun','bunker','orbital380','eagle500','airburst']])
 # Restore only obsolete facility footprints from the pristine template dimension.
 old=[]
 for x,y,z in [(-2035,2,-1545),(-1676,2,-1535)]:
  old += [(x-1,y-1,z-1,x+1,y+1,z+1),(x+4,y,z+4,x+6,y+4,z+4)]
  import math
  for i in range(16):
   dx=round(9*math.cos(i*math.pi/8));dz=round(9*math.sin(i*math.pi/8));old.append((x+dx,y-1,z+dz,x+dx,y-1,z+dz))
 for x,y,z in [(-1849,2,-1533),(-2072,2,-1370)]:old.append((x-1,y-1,z-1,x+1,y+2,z+1))
 chunks=sorted({(x//16*16,z//16*16) for a,b,c,d,e,f in old for x in range(a,d+1) for z in range(c,f+1)})
 fn('v8/upgrade',['execute if score #reset.active ustc.clock matches 1 run return run schedule function ustc_pvp:v8/upgrade 40t replace','function ustc_pvp:anchors',*[f'execute in ustc_pvp:template run forceload add {x} {z}' for x,z in chunks],*[f'forceload add {x} {z}' for x,z in chunks],'schedule function ustc_pvp:v8/ready 10t replace'])
 from make_pack import ANCHORS
 fn('v8/ready',['scoreboard players set #v8.ready ustc.clock 1',*[f'execute unless loaded {x} 0 {z} run scoreboard players set #v8.ready ustc.clock 0' for x,z in sorted(ANCHORS|set(chunks))],*[f'execute in ustc_pvp:template unless loaded {x} 0 {z} run scoreboard players set #v8.ready ustc.clock 0' for x,z in chunks],'execute if score #v8.ready ustc.clock matches 0 run return run schedule function ustc_pvp:v8/ready 10t replace','scoreboard players set #protection.edit ustc.clock 1',*[f'clone from ustc_pvp:template {a} {b} {c} {d} {e} {f} to minecraft:overworld {a} {b} {c} replace force' for a,b,c,d,e,f in old],*[f'execute in ustc_pvp:template run forceload remove {x} {z}' for x,z in chunks], 'kill @e[tag=ustc.point]',*[f'kill @e[tag=ustc.label.{k}]' for k in points], 'function ustc_pvp:v8/facilities','scoreboard players set #protection.edit ustc.clock 1','function ustc_pvp:points/build','function ustc_pvp:respawn/build','function ustc_pvp:advanced/build','function ustc_pvp:apply_preset','function ustc_pvp:refill','scoreboard players set #protection.edit ustc.clock 0','data modify storage ustc_pvp:state balance_v8 set value 1b'])
 append('load',['execute unless data storage ustc_pvp:state {balance_v8:1b} run schedule function ustc_pvp:v8/upgrade 10t replace'])
