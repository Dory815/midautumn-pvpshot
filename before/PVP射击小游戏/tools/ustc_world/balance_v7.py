"""Campus additions: safe forward respawns and two independently timed aircraft caches."""
from pathlib import Path
import json
from balance_v8 import ADVANCED
def extend(path,points):
 path=Path(path)
 def fn(name,lines,namespace='ustc_pvp'):
  p=path/'data'/namespace/'function'/f'{name}.mcfunction';p.parent.mkdir(parents=True,exist_ok=True);p.write_text('\n'.join(lines)+'\n')
 def append(name,lines):
  p=path/'data/ustc_pvp/function'/f'{name}.mcfunction';p.write_text(p.read_text().rstrip()+'\n'+'\n'.join(lines)+'\n')
 def marker(x,y,z,tags):return f'summon marker {x} {y} {z} '+json.dumps({'Tags':tags},separators=(',',':'))
 spawn=['kill @e[tag=ustc.forward]']
 for k,(x,y,z,_) in points.items():
  for dx,dz in [(-7,0),(7,0),(0,-7),(0,7),(-7,-7),(7,7)]:spawn.append(marker(x+dx+.5,y,z+dz+.5,['ustc.marker','ustc.forward','ustc.spawn.'+k]))
 fn('respawn/build',spawn)
 for team,owner,enemy,tdm in [('red',1,'blue','AE'),('blue',2,'red','CD')]:
  lines=[]
  for k in points:lines.append(f'execute if score #mode pvpshot.cfg matches 1 if entity @e[tag=ustc.point.{k},tag=pvpshot.point,scores={{pvpshot.owner={owner}}}] run tag @e[tag=ustc.spawn.{k}] add ustc.eligible')
  for k in tdm:lines.append(f'execute if score #mode pvpshot.cfg matches 0 run tag @e[tag=ustc.spawn.{k}] add ustc.eligible')
  lines += [f'execute as @e[tag=ustc.eligible] at @s if entity @a[team=pvpshot.{enemy},gamemode=!spectator,nbt=!{{Health:0.0f}},distance=..24] run tag @s remove ustc.eligible', 'execute as @e[tag=ustc.eligible] at @s unless block ~ ~ ~ air run tag @s remove ustc.eligible','execute as @e[tag=ustc.eligible] at @s unless block ~ ~1 ~ air run tag @s remove ustc.eligible','execute as @e[tag=ustc.eligible] at @s if block ~ ~-1 ~ #pvpshot:blast_passable run tag @s remove ustc.eligible',f'execute unless entity @e[tag=ustc.eligible] run tag @e[tag=pvpshot.spawn.{team}] add ustc.eligible']
  fn('respawn/'+team,lines)
 fn('respawn/location',['tag @e[tag=ustc.eligible] remove ustc.eligible','tag @e[tag=ustc.selected] remove ustc.selected','execute if entity @s[team=pvpshot.red] run function ustc_pvp:respawn/red','execute if entity @s[team=pvpshot.blue] run function ustc_pvp:respawn/blue','tag @e[type=marker,tag=ustc.eligible,sort=random,limit=1] add ustc.selected','execute at @e[tag=ustc.selected,limit=1] run tp @s ~ ~ ~','execute at @e[tag=ustc.selected,limit=1] run spawnpoint @s ~ ~ ~','tag @e[tag=ustc.eligible] remove ustc.eligible','tag @e[tag=ustc.selected] remove ustc.selected'])
 fn('player/spawn_location',['function ustc_pvp:respawn/location'],'pvpshot')
 build=['scoreboard players set #protection.edit ustc.clock 1','kill @e[tag=ustc.advanced]','kill @e[tag=ustc.advanced_label]']
 for x,y,z,k in ADVANCED:
  build += [f'fill {x-1} {y-1} {z-1} {x+1} {y-1} {z+1} polished_deepslate',f'fill {x-1} {y} {z-1} {x+1} {y+2} {z+1} air',f'setblock {x} {y} {z} trapped_chest[facing=north]',marker(x+.5,y,z+.5,['ustc.marker','ustc.advanced']),f'summon text_display {x+.5} {y+3} {z+.5} '+json.dumps({'Tags':['ustc.decor','ustc.advanced_label'],'text':{'text':k+' 点高级航空补给\n5 分钟刷新 · 战斗机 25%','color':'light_purple'},'billboard':'center','background':1073741824,'line_width':260},ensure_ascii=False,separators=(',',':'))]
 fn('advanced/build',build+['scoreboard players set #protection.edit ustc.clock 0','scoreboard players set #advanced.timer ustc.clock 0','function ustc_pvp:advanced/refill'])
 fn('advanced/second',['execute if score #reset.active ustc.clock matches 1 run return 0','scoreboard players add #advanced.timer ustc.clock 1','execute if score #advanced.timer ustc.clock matches 300.. run function ustc_pvp:advanced/refill'])
 fn('advanced/refill',['scoreboard players set #advanced.timer ustc.clock 0','execute as @e[type=marker,tag=ustc.advanced] at @s run function ustc_pvp:advanced/one'])
 fn('advanced/one',['data modify block ~ ~ ~ Items set value []',*[f'loot insert ~ ~ ~ loot pvpshot:item/{id}' for id in ['rocket','rocket','rocket','rocket','speed','jump','heal','grenade','bow','crossbow']],'execute store result score #aircraft.roll ustc.clock run random value 1..4','execute if score #aircraft.roll ustc.clock matches 1 run loot insert ~ ~ ~ loot pvpshot:item/fighter'])
 append('build',['function ustc_pvp:respawn/build','function ustc_pvp:advanced/build','scoreboard players set #drops.clear ustc.clock 1',*[f'gamerule minecraft:{g} false' for g in ['block_drops','entity_drops','mob_drops']],'data modify storage ustc_pvp:state balance_v7 set value 1b'])
 append('second',['function ustc_pvp:advanced/second'])
 # This one-time upgrade changes entities/new caches, never replaces the played world.
 fn('v7/upgrade',['scoreboard players set #v7.ready ustc.clock 1',*[f'execute unless loaded {x+dx} {y} {z+dz} run scoreboard players set #v7.ready ustc.clock 0' for x,y,z,_ in points.values() for dx,dz in [(-7,-7),(7,7)]],'execute if score #v7.ready ustc.clock matches 0 run return run schedule function ustc_pvp:v7/upgrade 20t replace','effect clear @a minecraft:jump_boost','function ustc_pvp:respawn/build','function ustc_pvp:advanced/build','data modify storage ustc_pvp:state balance_v7 set value 1b'])
 append('load',['scoreboard players set #drops.clear ustc.clock 1',*[f'gamerule minecraft:{g} false' for g in ['block_drops','entity_drops','mob_drops']],'execute unless data storage ustc_pvp:state {balance_v7:1b} run schedule function ustc_pvp:v7/upgrade 10t replace'])
 append('second',['scoreboard players add #item.sweep ustc.clock 1','execute if score #item.sweep ustc.clock matches 180.. run kill @e[type=item,x=-2149,y=-2048,z=-1807,dx=580,dy=4096,dz=654]','execute if score #item.sweep ustc.clock matches 180.. run scoreboard players set #item.sweep ustc.clock 0'])
 fn('mobility/apply',['# Mobility is supplied by timed reward potions, never refreshed on spawn.'])
 for n,id in [(0,'speed'),(1,'jump'),(2,'jump')]:fn('mobility/profile_'+str(n),[f'loot give @s loot pvpshot:item/{id}'])
 p=path/'data/ustc_pvp/function/test_kit.mcfunction';s=p.read_text();s=s.replace('loot give @s loot pvpshot:item/speed','loot give @s loot pvpshot:item/speed\nloot give @s loot pvpshot:item/jump\nloot give @s loot pvpshot:item/fighter');p.write_text(s)
