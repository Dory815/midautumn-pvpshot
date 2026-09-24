"""Generate the straight-flight rifle and low-damage demolition projectile."""
from pathlib import Path
import json,re,math
ROOT=Path(__file__).resolve().parents[1];P=ROOT/'pvpshot/data/pvpshot'
def fn(name,lines):
 p=P/'function'/f'{name}.mcfunction';p.parent.mkdir(parents=True,exist_ok=True);p.write_text('\n'.join(lines)+'\n')
def js(p,obj):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(obj,ensure_ascii=False,indent=2)+'\n')
def item(name,base,title,lore,count,seconds,model=None):
 c={'minecraft:custom_data':{'pvpshot':{'weapon':name}},'minecraft:item_name':{'text':title,'italic':False},'minecraft:lore':[{'text':lore,'italic':False,'color':'gray'}],'minecraft:consumable':{'consume_seconds':.05,'animation':'none','has_consume_particles':False},'minecraft:use_cooldown':{'seconds':seconds,'cooldown_group':'pvpshot:'+name}}
 if model:c['minecraft:item_model']=model
 js(P/'loot_table/item'/f'{name}.json',{'type':'minecraft:generic','pools':[{'rolls':1,'entries':[{'type':'minecraft:item','name':'minecraft:'+base,'functions':[{'function':'minecraft:set_count','count':count},{'function':'minecraft:set_components','components':c}]}]}]})
 js(P/'advancement'/f'use_{name}.json',{'criteria':{'use':{'trigger':'minecraft:consume_item','conditions':{'item':{'items':'minecraft:'+base,'predicates':{'minecraft:custom_data':{'pvpshot':{'weapon':name}}}}}}},'rewards':{'function':'pvpshot:'+('fire/launch' if name=='fire_charge' else 'rocket/launch')}})
item('fire_charge','blaze_powder','基础火焰弹','直击 6 · 1.5 格爆炸 3/1 · 单格破坏 · 16 发无限备弹',16,.3,'minecraft:fire_charge')
item('rocket','firework_star','破拆火箭','远程破拆半径 6 格 · 爆点附近最多 2 伤害 · 不点燃',2,3,'minecraft:firework_rocket')
js(P/'damage_type/rifle.json',{'exhaustion':.1,'message_id':'thrown','scaling':'never'})
for tag in ['is_projectile','bypasses_cooldown','no_knockback']:
 p=ROOT/'pvpshot/data/minecraft/tags/damage_type'/f'{tag}.json';v=json.loads(p.read_text()) if p.exists() else {'replace':False,'values':[]}
 if 'pvpshot:rifle' not in v['values']:v['values'].append('pvpshot:rifle')
 js(p,v)
protected=['bedrock','barrier','command_block','chain_command_block','repeating_command_block','structure_block','jigsaw','end_portal','end_portal_frame','nether_portal','structure_void','light','reinforced_deepslate']
js(P/'tags/block/indestructible.json',{'values':['minecraft:'+v for v in protected]})
blocks=re.findall(r'BLOCK (minecraft:\S+) \d+', (ROOT/'tools/ustc_world/block_colors.txt').read_text())
js(P/'tags/block/destructible.json',{'values':[b for b in blocks if b.split(':')[1] not in protected+['air','cave_air','void_air','water','lava']]})
js(P/'tags/entity_type/resettable.json',{'values':['minecraft:'+n for n in ['tnt','arrow','spectral_arrow','snowball','egg','fireball','small_fireball','item','area_effect_cloud','firework_rocket','trident']]})
fn('shot/load',['scoreboard objectives add pvpshot.shooter dummy','scoreboard objectives add pvpshot.velocity dummy','scoreboard players add #next pvpshot.shooter 0','scoreboard players set #95 pvpshot.cal 95','scoreboard players set #80 pvpshot.cal 80','scoreboard players set #100 pvpshot.cal 100'])
fn('shot/assign',['scoreboard players add #next pvpshot.shooter 1','scoreboard players operation @s pvpshot.shooter = #next pvpshot.shooter'])
for kind,itemid in [('fire','fire_charge'),('rocket','rocket')]:
 fn(kind+'/launch',[f'advancement revoke @s only pvpshot:use_{itemid}','execute unless score @s pvpshot.shooter matches 1.. run function pvpshot:shot/assign','scoreboard players operation #owner pvpshot.shooter = @s pvpshot.shooter',f'execute at @s rotated as @s anchored eyes positioned ^ ^ ^0.6 summon minecraft:item_display run function pvpshot:shot/init_{kind}','execute at @s run playsound minecraft:item.firecharge.use player @a[distance=..32] ~ ~ ~ 0.6 1.2','function pvpshot:regen/in_combat'])
 fn('shot/init_'+kind,['tag @s add pvpshot.shot',f'tag @s add pvpshot.{kind}_shot','scoreboard players operation @s pvpshot.shooter = #owner pvpshot.shooter','scoreboard players set @s pvpshot.age 0','scoreboard players set @s pvpshot.velocity 12000','tp @s ~ ~ ~ ~ ~', 'data merge entity @s {item:{id:"minecraft:'+('fire_charge' if kind=='fire' else 'firework_rocket')+'",count:1},billboard:"center",view_range:4f,teleport_duration:1,brightness:{block:15,sky:15},transformation:{scale:[0.5f,0.5f,0.5f]}}'])
# Same straight-flight scalar update as native LargeFireball: (v + .1) * .95, .8 in water.
fn('fire/tick',['kill @e[tag=pvpshot.fireball]','execute as @e[type=item_display,tag=pvpshot.shot] at @s rotated as @s run function pvpshot:shot/tick'])
fn('shot/tick',['scoreboard players add @s pvpshot.age 1','execute if score @s pvpshot.age matches 100.. run return run kill @s','tag @s add pvpshot.current_projectile','scoreboard players operation #owner pvpshot.shooter = @s pvpshot.shooter','execute as @a if score @s pvpshot.shooter = #owner pvpshot.shooter run tag @s add pvpshot.damage_source','execute if score @s pvpshot.age matches ..2 run tag @a[tag=pvpshot.damage_source] add pvpshot.launch_protected','scoreboard players set #rocket pvpshot.cal 0','execute if entity @s[tag=pvpshot.rocket_shot] run scoreboard players set #rocket pvpshot.cal 1','scoreboard players add @s pvpshot.velocity 1000','execute unless predicate pvpshot:in_water run scoreboard players operation @s pvpshot.velocity *= #95 pvpshot.cal','execute if predicate pvpshot:in_water run scoreboard players operation @s pvpshot.velocity *= #80 pvpshot.cal','scoreboard players operation @s pvpshot.velocity /= #100 pvpshot.cal','execute store result storage pvpshot:shot step double 0.00002 run scoreboard players get @s pvpshot.velocity','scoreboard players set #hit pvpshot.cal 0','scoreboard players set #steps pvpshot.cal 5','execute store result storage pvpshot:shot dmg int 1 run scoreboard players get #dmg.rifle pvpshot.cfg','function pvpshot:shot/step','execute if score #hit pvpshot.cal matches 1 run kill @s','tag @s remove pvpshot.current_projectile','tag @a[tag=pvpshot.damage_source] remove pvpshot.damage_source','tag @a[tag=pvpshot.launch_protected] remove pvpshot.launch_protected'])
ray=(P/'function/combat/ray_step.mcfunction').read_text().splitlines()[2:5]
ray=[s.replace('pvpshot:combat/apply_', 'pvpshot:shot/hit_') for s in ray]
fn('shot/step',['execute unless loaded ~ ~ ~ run return run kill @s','execute unless block ~ ~ ~ #pvpshot:blast_passable run return run function pvpshot:shot/block',*ray,'execute if score #hit pvpshot.cal matches 1 run return 1','execute if score #steps pvpshot.cal matches 0 run return run tp @s ~ ~ ~','scoreboard players remove #steps pvpshot.cal 1','function pvpshot:shot/advance with storage pvpshot:shot'])
fn('shot/advance',['$execute positioned ^ ^ ^$(step) run function pvpshot:shot/step'])
for pose,offset in [('standing',.9),('crouching',.75),('low',.3)]:fn('shot/hit_'+pose,[f'execute positioned ~ ~{offset} ~ run function pvpshot:shot/hit'])
fn('shot/hit',['execute if score #hit pvpshot.cal matches 1 run return 0','scoreboard players set #hit pvpshot.cal 1','execute if score #rocket pvpshot.cal matches 1 run return run function pvpshot:rocket/burst','tag @s add pvpshot.rifle_direct','function pvpshot:shot/damage with storage pvpshot:shot','function pvpshot:rifle/burst','tag @s remove pvpshot.rifle_direct'])
fn('shot/damage',['$execute if entity @a[tag=pvpshot.damage_source,limit=1] run return run damage @s $(dmg) pvpshot:rifle by @e[tag=pvpshot.current_projectile,limit=1] from @a[tag=pvpshot.damage_source,limit=1]','$damage @s $(dmg) pvpshot:rifle by @e[tag=pvpshot.current_projectile,limit=1]'])
fn('shot/block',['scoreboard players set #hit pvpshot.cal 1','execute if score #rocket pvpshot.cal matches 1 run return run function pvpshot:rocket/burst','execute positioned ^ ^ ^-0.15 run function pvpshot:rifle/burst','execute if block ~ ~ ~ #pvpshot:destructible run setblock ~ ~ ~ air'])
# Small splash uses body-centre distance and line of sight, before removing the hit block.
# Damage is never repeated on the direct victim; the carrier retains shooter credit.
fn('rifle/burst',['summon minecraft:marker ~ ~ ~ {Tags:["pvpshot.rifle_origin"]}',
 'particle minecraft:explosion ~ ~ ~ 0 0 0 0 1 normal',
 'playsound minecraft:entity.generic.explode player @a[distance=..24] ~ ~ ~ 0.2 1.8',
 'execute as @a[gamemode=!spectator,nbt=!{Health:0.0f},tag=!pvpshot.rifle_direct,distance=..3] at @s run function pvpshot:rifle/target',
 'kill @e[type=marker,tag=pvpshot.rifle_origin]'])
fn('rifle/target',[
 'execute if predicate pvpshot:low_pose positioned ~ ~0.3 ~ run return run function pvpshot:rifle/range',
 'execute if predicate pvpshot:crouching positioned ~ ~0.75 ~ run return run function pvpshot:rifle/range',
 'execute positioned ~ ~0.9 ~ run function pvpshot:rifle/range'])
fn('rifle/range',[
 'execute unless entity @e[type=marker,tag=pvpshot.rifle_origin,distance=..1.5,limit=1] run return 0',
 'data modify storage pvpshot:shot dmg set value 1',
 'execute if entity @e[type=marker,tag=pvpshot.rifle_origin,distance=..1,limit=1] run data modify storage pvpshot:shot dmg set value 3',
 'scoreboard players set #rifle.ray pvpshot.cal 18',
 'execute facing entity @e[type=marker,tag=pvpshot.rifle_origin,limit=1] feet run function pvpshot:rifle/ray'])
fn('rifle/ray',[
 'execute unless block ~ ~ ~ #pvpshot:blast_passable run return 0',
 'execute if entity @e[type=marker,tag=pvpshot.rifle_origin,distance=..0.12,limit=1] run return run function pvpshot:shot/damage with storage pvpshot:shot',
 'scoreboard players remove #rifle.ray pvpshot.cal 1',
 'execute if score #rifle.ray pvpshot.cal matches 1.. positioned ^ ^ ^0.1 run function pvpshot:rifle/ray'])
burst=['scoreboard players set #hit pvpshot.cal 1','data modify storage pvpshot:shot dmg set value 2','execute as @a[gamemode=!spectator,nbt=!{Health:0.0f},distance=..6] run function pvpshot:shot/damage with storage pvpshot:shot','particle minecraft:explosion_emitter ~ ~ ~ 0 0 0 0 1 normal','playsound minecraft:entity.generic.explode player @a[distance=..64] ~ ~ ~ 1 0.8']
for y in range(-6,7):
 for z in range(-6,7):
  q=36-y*y-z*z
  if q>=0:
   x=math.isqrt(q);burst.append(f'fill ~{-x} ~{y} ~{z} ~{x} ~{y} ~{z} air replace #pvpshot:destructible')
fn('rocket/burst',burst)
# Remove unused legacy native explosion spawning entry points.
for p in ['fire/spawn.mcfunction','fire/vector.mcfunction']:(P/'function'/p).unlink(missing_ok=True)
print('Generated rifle, demolition rocket and protected-block rules')
