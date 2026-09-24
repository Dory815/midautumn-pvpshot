"""Revision 8 overlay. Run after the rifle, field, structures and v7 generators."""
from build_balance_v7 import *
from build_structures import write_structure

def change(name,old,new):
 p=P/'function'/f'{name}.mcfunction';s=p.read_text();p.write_text(s.replace(old,new))
def lore(id,text):
 p=P/'loot_table/item'/f'{id}.json';v=json.loads(p.read_text())
 for f in v['pools'][0]['entries'][0]['functions']:
  if f['function']=='minecraft:set_components':f['components']['minecraft:lore']=[{'text':text,'italic':False,'color':'gray'}]
 js(p,v)
def build():
 change('shot/init_fire','pvpshot.velocity 12000','pvpshot.velocity 18000')
 if 'execute unless entity @s[tag=pvpshot.fire_shot]' not in (P/'function/shot/tick.mcfunction').read_text():change('shot/tick','scoreboard players add @s pvpshot.velocity 1000','execute unless entity @s[tag=pvpshot.fire_shot] run scoreboard players add @s pvpshot.velocity 1000\nexecute if entity @s[tag=pvpshot.fire_shot] run scoreboard players add @s pvpshot.velocity 1500')
 append('smg/init','scoreboard players set @s pvpshot.velocity 12000')
 item('egg','brick','鸡蛋冲锋枪','按住右键 · 约 6.7 发/秒 · 近距 4 HP / 远端 1 HP · 48 发',48,None,'egg',extra={'minecraft:consumable':{'consume_seconds':3600,'animation':'none','has_consume_particles':False}})
 # No completion callback: all ammunition and cadence are handled by the server tick.
 for f in [P/'advancement/use_egg.json',P/'function/v7/use_egg.mcfunction']:
  if f.exists():f.unlink()
 item('shotgun','nether_brick','霰弹枪','10 弹丸 × 3 HP · 8 格后衰减 · 射程 24 格 · 间隔 1.2 秒',12,1.2,'netherite_hoe',action='scoreboard players set @s pvpshot.shotgun 1')
 for id,base,title,desc,cd in [('orbital380','echo_shard','轨道 380 打击','一次性 · 瞄准地面标记 · 3 秒警告后 24 发区域炮击',2),('eagle500','nether_star','飞鹰 500 炸弹','一次性 · 瞄准位置标记 · 4 秒后投下一枚大型炸弹',2),('airburst','prismarine_shard','空爆火箭筒','一次性 · 12 格后近敌引爆 · 最远 90 格空爆 · 爆后溅射 6-8 枚 TNT',2)]:
  item(id,base,title,desc,1,cd,'firework_rocket' if id=='airburst' else base,action='scoreboard players set @s pvpshot.heavy '+str(['orbital380','eagle500','airburst'].index(id)+1))
 item('bunker','gray_dye','大型掩体生成器','11 × 5 × 9 多方块掩体 · 双层墙体 / 射击孔 / 两侧入口',1,2,'gray_dye',action='function pvpshot:deploy/bunker')
 blocks={(x,y,z):('air',{}) for x in range(11) for y in range(5) for z in range(9)}
 for x,y,z in blocks:
  if y in (0,4) or x in (0,1,9,10) or z in (0,1,7,8):blocks[x,y,z]=('deepslate_bricks',{})
  if y in (1,2) and z in (3,4,5) and x in (0,1,9,10):blocks[x,y,z]=('air',{})
  if y==2 and x in (3,5,7) and z in (0,1,7,8):blocks[x,y,z]=('air',{})
 write_structure('large_bunker',[11,5,9],blocks)
 checks=['scoreboard players set #place.ok pvpshot.cal 1']
 for x,y,z in blocks:
  checks.extend([f'execute positioned ^{x} ^{y} ^{z} if block ~ ~ ~ #pvpshot:indestructible run scoreboard players set #place.ok pvpshot.cal 0',f'execute positioned ^{x} ^{y} ^{z} run function pvpshot:protection/check','execute if score #protected pvpshot.cal matches 1 run scoreboard players set #place.ok pvpshot.cal 0'])
 fn('deploy/check_bunker',checks)
 source=(P/'function/deploy/cannon.mcfunction').read_text().replace('tnt_cannon','large_bunker').replace('"cannon"','"bunker"').replace('item/cannon_dye','item/bunker')
 fn('deploy/bunker',source.splitlines());fn('bunker/load',['kill @s'])
 # Nine native TNT rounds and 18 triple-arrow bursts. No synthetic damage for TNT.
 fn('cannon/tick',[f'execute if score @s pvpshot.age matches {n} run function pvpshot:cannon/fire' for n in range(20,181,20)]+[f'execute if score @s pvpshot.age matches {n+4}..{n+6} run function pvpshot:cannon/capture' for n in range(20,181,20)]+[f'execute if score @s pvpshot.age matches {n+6} run function pvpshot:cannon/unpower' for n in range(20,181,20)]+['execute if score @s pvpshot.age matches 200.. run kill @s'])
 fn('cannon/load',['item replace block ^1 ^1 ^3 container.0 with minecraft:tnt 9'])
 change('turret/tick','20..120','20..360');change('turret/tick','140..','380..')
 for p in (P/'function/turret').glob('ammo_*.mcfunction'):p.write_text(p.read_text().replace('] 6','] 18'))
 change('cfg/default','#dmg.turret pvpshot.cfg 4','#dmg.turret pvpshot.cfg 7')
 fn('v8/load',[f'scoreboard objectives add {o} dummy' for o in ['pvpshot.shotgun','pvpshot.heavy','pvpshot.airtime']]+['scoreboard players set #dmg.turret pvpshot.cfg 7'])
 append('load','function pvpshot:v8/load')
 append('match/restart','scoreboard players add #ordnance.epoch pvpshot.cal 1')
 p=P/'function/match/prepare.mcfunction';p.write_text(p.read_text().replace('scoreboard players add #ordnance.epoch pvpshot.cal 1\n',''))
 lore('cannon_dye','自动连射 9 发原版 TNT · 1 秒间隔 · 自行承担近距爆炸风险')
 lore('turret_dye','18 轮 × 3 箭 · 单箭 7 HP · 自动连射 18 秒')
 lore('fire_charge','提速 50% · 直击 6 HP / 近炸 3–1 HP · 16 发 / 无限换弹')
 lore('bow','原版弹道 · 20 格后近炸 · 直击最高 24 HP / 范围 12–6 HP')
 lore('crossbow','每人限 1 把 · 直线弹道 · 装填 3 秒 · 20 格内 4 HP / 远距致命')
 lore('fighter','30 秒限时 · 机炮 24 / 炸弹 4 / 助推 12 · 两种弹药耗尽提前退出')
 lore('plane_elytra','启用 30 秒强制退出 · 保留安全缓降 · /trigger pvp_land 主动退出')
 item('shield','shield','轻型盾牌','正面减伤 50% · 96 耐久 · 举盾延迟 0.35 秒',extra={'minecraft:max_damage':96,'minecraft:damage':0,'minecraft:blocks_attacks':{'block_delay_seconds':.35,'disable_cooldown_scale':1.5,'damage_reductions':[{'horizontal_blocking_angle':90,'base':0,'factor':.5}],'item_damage':{'threshold':0,'base':1,'factor':1},'block_sound':'minecraft:item.shield.block','disable_sound':'minecraft:item.shield.break'}})
 p=P/'loot_table/item/rocket.json';v=json.loads(p.read_text());v['pools'][0]['entries'][0]['functions'][0]['count']=1;js(p,v)
 change('field/affect','minecraft:slowness 1 1','minecraft:slowness 1 3');change('field/affect','damage @s 1 pvpshot:field','damage @s 2 pvpshot:field')
 lore('snowball','霜蚀区域：半径 3 格 / 5 秒 · 迟缓 IV · 每秒 2 HP · 重叠不叠加')
 for id,base,title,effects in [('harming','splash_potion','伤害 II',[('instant_damage',1,1)]),('slow','splash_potion','强效迟缓 IV',[('slowness',3,300)]),('blind','splash_potion','致盲压制',[('blindness',0,160),('weakness',1,240)]),('linger','lingering_potion','迟缓凋零云',[('slowness',3,400),('wither',1,160)])]:
  item(id,base,title,'投掷药水 · 效果受命中位置及原版持续时间缩放',1,extra={'minecraft:potion_contents':{'custom_color':5580659,'custom_effects':[{'id':'minecraft:'+e,'amplifier':amp,'duration':duration} for e,amp,duration in effects]}})
 # Clear positive potion effects at the shared combat gate, with Slow Falling exempt.
 fn('v8/clear_buffs',[f'effect clear @s minecraft:{e}' for e in ['speed','jump_boost','strength','resistance','regeneration','absorption','fire_resistance','invisibility','haste','health_boost','luck','night_vision','water_breathing','dolphins_grace']])
 append('regen/in_combat','function pvpshot:v8/clear_buffs')
 p=P/'advancement/combat_use.json';v=json.loads(p.read_text());v['rewards']['function']='pvpshot:regen/aim';js(p,v)
 fn('regen/aim',['advancement revoke @s only pvpshot:combat_use','scoreboard players set @s pvpshot.quiet 0','function pvpshot:regen/stop'])
 for id in ['shotgun','orbital380','eagle500','airburst','bunker','plane_gun','plane_bomb']:append('v7/use_'+id,'function pvpshot:regen/in_combat')
 # Expand normal supply with the two non-rare additions; heavy equipment only in special crates.
 append('chest/refill_one','loot insert ~ ~ ~ loot pvpshot:item/shotgun')
 append('chest/refill_rich','loot insert ~ ~ ~ loot pvpshot:item/bunker')
 append('chest/refill_one','execute store result score #bunker.roll pvpshot.cal run random value 1..4')
  append('chest/refill_one','execute if score #bunker.roll pvpshot.cal matches 1 run loot insert ~ ~ ~ loot pvpshot:item/bunker')
  for name in ['chest/refill_one','chest/refill_rich']:
   p=P/'function'/f'{name}.mcfunction'
   s=p.read_text().replace('loot insert ~ ~ ~ loot pvpshot:item/rocket\n','')
   if 'rocket.roll' not in s and name=='chest/refill_one':
    s=s.replace('loot insert ~ ~ ~ loot pvpshot:item/grenade','execute store result score #rocket.roll pvpshot.cal run random value 1..2\nexecute if score #rocket.roll pvpshot.cal matches 1 run loot insert ~ ~ ~ loot pvpshot:item/rocket\nloot insert ~ ~ ~ loot pvpshot:item/grenade',1)
   p.write_text(s)
if __name__=='__main__':build()
