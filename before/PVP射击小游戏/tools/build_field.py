"""Generate an owner-attributed frost field without changing native snowball motion."""
from pathlib import Path
import json,math
ROOT=Path(__file__).resolve().parents[1];P=ROOT/'pvpshot/data/pvpshot'
def fn(name,lines):
 p=P/'function'/f'{name}.mcfunction';p.parent.mkdir(parents=True,exist_ok=True);p.write_text('\n'.join(lines)+'\n')
def js(path,obj):
 path.parent.mkdir(parents=True,exist_ok=True);path.write_text(json.dumps(obj,ensure_ascii=False,indent=2)+'\n')
# Lifetime is an absolute server-tick deadline, including time spent unloaded.
fn('field/load',['scoreboard objectives add pvpshot.field_end dummy','scoreboard objectives add pvpshot.field_next dummy','scoreboard objectives add pvpshot.field_time dummy','scoreboard players add #clock pvpshot.field_time 0'])
fn('field/create',['scoreboard players set #field.owner pvpshot.shooter 0',
 'execute as @a[tag=pvpshot.damage_source] unless score @s pvpshot.shooter matches 1.. run function pvpshot:shot/assign',
 'execute as @a[tag=pvpshot.damage_source] run scoreboard players operation #field.owner pvpshot.shooter = @s pvpshot.shooter',
 'execute summon minecraft:marker run function pvpshot:field/init',
 'playsound minecraft:block.powder_snow.break player @a[distance=..24] ~ ~ ~ 0.5 0.8'])
fn('field/init',['tag @s add pvpshot.field','scoreboard players operation @s pvpshot.shooter = #field.owner pvpshot.shooter',
 'scoreboard players operation @s pvpshot.field_end = #clock pvpshot.field_time','scoreboard players add @s pvpshot.field_end 100',
 'scoreboard players set @s pvpshot.age 0','function pvpshot:field/visual','function pvpshot:field/apply'])
fn('field/tick',['scoreboard players add #clock pvpshot.field_time 1','execute as @e[type=marker,tag=pvpshot.field] at @s run function pvpshot:field/tick_one'])
fn('field/tick_one',['execute if score #clock pvpshot.field_time >= @s pvpshot.field_end run return run kill @s',
 'scoreboard players add @s pvpshot.age 1','execute if score @s pvpshot.age matches 10.. run function pvpshot:field/visual','function pvpshot:field/apply'])
visual=['scoreboard players set @s pvpshot.age 0','particle minecraft:snowflake ~ ~0.3 ~ 1.5 0.2 1.5 0.015 8 normal']
for i in range(16):
 x=3*math.cos(i*math.pi/8);z=3*math.sin(i*math.pi/8)
 visual.append(f'particle minecraft:dust{{color:[0.4,0.8,1.0],scale:0.8}} ~{x:.4f} ~0.15 ~{z:.4f} 0 0 0 0 1 normal')
fn('field/visual',visual)
js(P/'predicate/in_field.json',{'condition':'minecraft:entity_properties','entity':'this','predicate':{'minecraft:distance':{'horizontal':{'max':3},'y':{'max':2}}}})
fn('field/apply',['tag @s add pvpshot.field_current','scoreboard players operation #field.owner pvpshot.shooter = @s pvpshot.shooter',
 'execute as @a if score @s pvpshot.shooter = #field.owner pvpshot.shooter run tag @s add pvpshot.field_owner',
 'execute as @a[gamemode=!creative,gamemode=!spectator,nbt=!{Health:0.0f},distance=..4] if predicate pvpshot:in_field at @s run function pvpshot:field/target',
 'tag @a[tag=pvpshot.field_owner] remove pvpshot.field_owner','tag @s remove pvpshot.field_current'])
fn('field/target',[
 'execute unless score #friendlyfire pvpshot.cfg matches 1 if entity @s[team=pvpshot.red] if entity @a[tag=pvpshot.field_owner,team=pvpshot.red] run return 0',
 'execute unless score #friendlyfire pvpshot.cfg matches 1 if entity @s[team=pvpshot.blue] if entity @a[tag=pvpshot.field_owner,team=pvpshot.blue] run return 0',
 'scoreboard players set #field.ray pvpshot.cal 24',
 'execute if predicate pvpshot:low_pose positioned ~ ~0.3 ~ facing entity @e[tag=pvpshot.field_current,limit=1] feet run return run function pvpshot:field/ray',
 'execute if predicate pvpshot:crouching positioned ~ ~0.75 ~ facing entity @e[tag=pvpshot.field_current,limit=1] feet run return run function pvpshot:field/ray',
 'execute positioned ~ ~0.9 ~ facing entity @e[tag=pvpshot.field_current,limit=1] feet run function pvpshot:field/ray'])
fn('field/ray',['execute unless block ~ ~ ~ #pvpshot:blast_passable run return 0',
 'execute if entity @e[type=marker,tag=pvpshot.field_current,distance=..0.22,limit=1] run return run function pvpshot:field/affect',
 'scoreboard players remove #field.ray pvpshot.cal 1','execute if score #field.ray pvpshot.cal matches 1.. positioned ^ ^ ^0.2 run function pvpshot:field/ray'])
fn('field/affect',['effect give @s minecraft:slowness 1 1 true',
 'execute if score @s pvpshot.field_next > #clock pvpshot.field_time run return 0',
 'scoreboard players operation @s pvpshot.field_next = #clock pvpshot.field_time','scoreboard players add @s pvpshot.field_next 20',
 'execute if entity @a[tag=pvpshot.field_owner,limit=1] run return run damage @s 1 pvpshot:field by @e[tag=pvpshot.field_current,limit=1] from @a[tag=pvpshot.field_owner,limit=1]',
 'damage @s 1 pvpshot:field by @e[tag=pvpshot.field_current,limit=1]'])
fn('field/clear',['scoreboard players add #clock pvpshot.field_time 100','kill @e[tag=pvpshot.field]'])
js(P/'damage_type/field.json',{'exhaustion':0,'message_id':'indirectMagic','scaling':'never'})
for name in ['no_knockback','bypasses_cooldown']:
 p=ROOT/'pvpshot/data/minecraft/tags/damage_type'/f'{name}.json';v=json.loads(p.read_text())
 if 'pvpshot:field' not in v['values']:v['values'].append('pvpshot:field')
 js(p,v)
p=P/'loot_table/item/snowball.json';v=json.loads(p.read_text());f=v['pools'][0]['entries'][0]['functions'];f[0]['count']=4;c=f[1]['components'];c['minecraft:item_name']={'text':'霜蚀雪球','italic':False};c['minecraft:lore']=[{'text':'半径 3 格 · 持续 5 秒 · 迟缓 II · 每秒 1 伤害','color':'gray','italic':False},{'text':'影响敌我 · 重叠不叠伤 · 不破坏地形','color':'gray','italic':False}];c['minecraft:use_cooldown']['seconds']=1;js(p,v)
# Spawns use the support pool. Supply crates retain all five weapons.
lines=['scoreboard players set #sum pvpshot.cal 0']
for n in ['snowball','egg','trident']:lines.append(f'scoreboard players operation #sum pvpshot.cal += #w.{n} pvpshot.cfg')
lines += ['execute if score #sum pvpshot.cal matches ..0 run return fail','execute store result storage pvpshot:tmp max int 1 run scoreboard players get #sum pvpshot.cal','function pvpshot:roll/rng with storage pvpshot:tmp','scoreboard players set #c pvpshot.cal 0']
for n in ['snowball','egg']:
 lines += [f'scoreboard players operation #c pvpshot.cal += #w.{n} pvpshot.cfg',f'execute if score #r pvpshot.cal <= #c pvpshot.cal run return run data modify storage pvpshot:roll id set value "{n}"']
lines.append('data modify storage pvpshot:roll id set value "trident"');fn('roll/secondary',lines)
print('Generated frost fields and the spawn support pool')
