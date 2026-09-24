"""Generate the v7 weapon items and server gameplay controls after base generators."""
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[1]; P=ROOT/'pvpshot/data/pvpshot'
def js(path,obj):path.parent.mkdir(parents=True,exist_ok=True);path.write_text(json.dumps(obj,ensure_ascii=False,indent=2)+'\n')
def fn(name,lines):p=P/'function'/f'{name}.mcfunction';p.parent.mkdir(parents=True,exist_ok=True);p.write_text('\n'.join(lines)+'\n')
def append(name,line):
 p=P/'function'/f'{name}.mcfunction';s=p.read_text();
 if line not in s:p.write_text(s.rstrip()+'\n'+line+'\n')
def item(id,base,title,lore,count=1,seconds=None,model=None,extra=None,action=None):
 c={'minecraft:custom_data':{'pvpshot':{'weapon':id}},'minecraft:item_name':{'text':title,'italic':False},'minecraft:lore':[{'text':lore,'italic':False,'color':'gray'}]}
 if model:c['minecraft:item_model']='minecraft:'+model
 if seconds is not None:c.update({'minecraft:consumable':{'consume_seconds':.05,'animation':'none','has_consume_particles':False},'minecraft:use_cooldown':{'seconds':seconds,'cooldown_group':'pvpshot:'+id}})
 c.update(extra or {})
 js(P/'loot_table/item'/f'{id}.json',{'type':'minecraft:generic','pools':[{'rolls':1,'entries':[{'type':'minecraft:item','name':'minecraft:'+base,'functions':[{'function':'minecraft:set_count','count':count},{'function':'minecraft:set_components','components':c}]}]}]})
 if action:
  js(P/'advancement'/f'use_{id}.json',{'criteria':{'use':{'trigger':'minecraft:consume_item','conditions':{'item':{'items':'minecraft:'+base,'predicates':{'minecraft:custom_data':{'pvpshot':{'weapon':id}}}}}}},'rewards':{'function':'pvpshot:v7/use_'+id}})
  fn('v7/use_'+id,[f'advancement revoke @s only pvpshot:use_{id}',action])
 return c

def build():
 # Rifle keeps its established hit/splash/ammunition implementation.
 p=P/'loot_table/item/fire_charge.json';v=json.loads(p.read_text());v['pools'][0]['entries'][0]['functions'][-1]['components']['minecraft:use_cooldown']['seconds']=.3;js(p,v)
 for id,title in [('speed','疾行 V'),('jump','跳跃 V')]:
  item(id,'potion',title+' · 45 秒','奖励药水 · 出生不再自带移动效果',extra={'minecraft:potion_contents':{'custom_color':3407871 if id=='speed' else 8453888,'custom_effects':[{'id':'minecraft:'+('speed' if id=='speed' else 'jump_boost'),'amplifier':4,'duration':900}]}})
 item('egg','wheat_seeds','鸡蛋冲锋枪','10 发/秒 · 近距 4 HP / 远端 1 HP · 无爆炸 · 48 发',48,.1,'egg',extra={'minecraft:consumable':{'consume_seconds':3600,'animation':'none','has_consume_particles':False}},action='function pvpshot:smg/launch')
 fn('smg/launch',['execute unless score @s pvpshot.shooter matches 1.. run function pvpshot:shot/assign','scoreboard players operation #owner pvpshot.shooter = @s pvpshot.shooter','execute at @s rotated as @s anchored eyes positioned ^ ^ ^0.6 summon item_display run function pvpshot:smg/init','function pvpshot:regen/in_combat'])
 fn('smg/init',['function pvpshot:shot/init_fire','tag @s remove pvpshot.fire_shot','tag @s add pvpshot.smg_shot','data modify entity @s item set value {id:"minecraft:egg",count:1}','data modify entity @s transformation.scale set value [0.25f,0.25f,0.25f]'])
 # Route a direct SMG hit without invoking the rifle blast or block removal.
 for name,needle,line in [('shot/hit','tag @s add pvpshot.rifle_direct','execute if entity @e[tag=pvpshot.current_projectile,tag=pvpshot.smg_shot,limit=1] run return run function pvpshot:shot/damage with storage pvpshot:shot'),('shot/block','execute positioned ^ ^ ^-0.15','execute if entity @s[tag=pvpshot.smg_shot] run return 0')]:
  p=P/'function'/f'{name}.mcfunction';s=p.read_text()
  if line not in s:s=s.replace(needle,line+'\n'+needle)
  p.write_text(s)
 p=P/'function/shot/tick.mcfunction';s=p.read_text();line='execute if entity @s[tag=pvpshot.smg_shot] if score @s pvpshot.age matches 17.. run return run kill @s'
 if line not in s:s=s.replace('tag @s add pvpshot.current_projectile',line+'\ntag @s add pvpshot.current_projectile')
 line='execute if entity @s[tag=pvpshot.smg_shot] run data modify storage pvpshot:shot dmg set value 4\nexecute if entity @s[tag=pvpshot.smg_shot] if score @s pvpshot.age matches 9.. run data modify storage pvpshot:shot dmg set value 1'
 if line not in s:s=s.replace('function pvpshot:shot/step',line+'\nfunction pvpshot:shot/step')
 p.write_text(s)
 # Legacy eggs lose their former fragment explosion too.
 p=P/'function/combat/impact.mcfunction';p.write_text('\n'.join(l for l in p.read_text().splitlines() if 'fragment/burst' not in l)+'\n')
 for name,title,lore in [('bow','近炸弓','原版弹道 · 20 格后 0.75 格近炸触发 / 2.5 格范围 · 直击 3–18 HP'),('crossbow','狙击重弩','装填 3 秒 · 20 格内 4 HP · 20 格起致命直击 · 无穿透 / 可被盾挡')]:
  p=P/'loot_table/item'/f'{name}.json';v=json.loads(p.read_text());c=v['pools'][0]['entries'][0]['functions'][0]['components'];c['minecraft:item_name']={'text':title,'italic':False};c['minecraft:lore']=[{'text':lore,'italic':False,'color':'gray'}];c['minecraft:enchantments']={} if name=='bow' else {'pvpshot:crossbow_power':1};js(p,v)
 p=P/'enchantment/crossbow_power.json';v=json.loads(p.read_text());v['description']={'text':'重弩慢装填'};v['effects']={'minecraft:crossbow_charge_time':{'type':'minecraft:set','value':3.0}};v['slots']=['mainhand','offhand'];js(p,v)
 wind=item('wind','wind_charge','风暴弹','8 格冲击范围 · 强击退 · 直击仅 0.1 HP · 不破坏地形',4,extra={'minecraft:enchantments':{'pvpshot:wind':1}})
 v=json.loads((P/'enchantment/turret_hit.json').read_text());v['description']='wind projectile';v['effects']['minecraft:projectile_spawned'][0]['effect']['function']='pvpshot:v7/wind';v['supported_items']='minecraft:wind_charge';v['slots']=['mainhand','offhand'];js(P/'enchantment/wind.json',v);fn('v7/wind',['tag @s add pvpshot.wind'])
 for mode in ['normal','cook']:
  cooked=mode=='cook';components={'minecraft:custom_data':{'pvpshot':{'weapon':'cooked_grenade' if cooked else 'grenade'}},'minecraft:item_name':{'text':'温雷手雷' if cooked else '手雷','italic':False},'minecraft:lore':[{'text':'按住右键开始 2 秒引信，松开投出；超时手中爆炸' if cooked else '右键投掷 · 2 秒引信；/trigger pvp_cook 切换温雷','italic':False,'color':'gray'}],'minecraft:consumable':{'consume_seconds':3600 if cooked else .05,'animation':'none','has_consume_particles':False},'minecraft:use_cooldown':{'seconds':2,'cooldown_group':'pvpshot:grenade'}}
  js(P/'item_modifier'/f'grenade_{mode}.json',{'function':'minecraft:set_components','components':components})
 item('fighter','paper','战斗机出动许可','右键启用：机炮 24 / 炸弹 4 / 助推 12 · 需要 3 个空格',1,1,'elytra',action='scoreboard players set @s pvpshot.flight 1')
 item('plane_elytra','elytra','战斗机鞘翅','两种弹药都耗尽后自动退出；/trigger pvp_land 安全退出',extra={'minecraft:unbreakable':{},'minecraft:enchantment_glint_override':True})
 item('plane_gun','flint','战斗机机炮','爆炸弹 · 可破坏地形 · 限 24 发',24,.25,'fire_charge',action='scoreboard players set @s pvpshot.airgun 1')
 item('plane_bomb','magma_cream','战斗机炸弹','向下投放原版 TNT · 落地爆炸 · 限 4 枚',4,1,'tnt',action='scoreboard players set @s pvpshot.airbomb 1')
 item('plane_boost','firework_rocket','战斗机助推','飞行中使用 · 限 12 发',12,extra={'minecraft:fireworks':{'flight_duration':1,'explosions':[]}})
 fn('v7/load',[*[f'scoreboard objectives add {o} dummy' for o in ['pvpshot.flight','pvpshot.gun','pvpshot.bomb','pvpshot.airgun','pvpshot.airbomb']], 'scoreboard objectives add pvp_cook trigger','scoreboard objectives add pvp_land trigger'])
 fn('v7/tick',['scoreboard players enable @a pvp_cook','scoreboard players enable @a pvp_land','execute as @e[type=tnt,tag=pvpshot.airbomb,nbt={OnGround:1b}] run data modify entity @s fuse set value 0'])
 append('load','function pvpshot:v7/load');append('tick','function pvpshot:v7/tick')
 p=P/'function/chest/refill_one.mcfunction';s=p.read_text();line='loot insert ~ ~ ~ loot pvpshot:item/jump'
 if line not in s:s=s.replace('loot insert ~ ~ ~ loot pvpshot:item/speed','loot insert ~ ~ ~ loot pvpshot:item/speed\n'+line)
 p.write_text(s)
if __name__=='__main__':build()
