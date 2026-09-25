"""Generate campus-specific controls, presets, supplies, and asynchronous block reset."""
from pathlib import Path
import json,math
ROOT=Path(__file__).resolve().parents[2]
POINTS={'A':(-1990,28,-1535,'西侧楼顶'),'B':(-1857,2,-1541,'中央院落'),'C':(-1710,29,-1535,'东侧楼顶'),'D':(-1676,2,-1660,'北侧院落'),'E':(-2080,2,-1378,'球场西北入口')}
from balance_v7 import ADVANCED,extend
from balance_v8 import regions as roof_regions, extend as extend_v8
BASES={'red':(-2110,2,-1490),'blue':(-1590,2,-1525)}
LOBBY=(-2130,9,-1800)
GYM=[(-1930,2,-1310),(-1865,2,-1300),(-1790,2,-1300),(-1760,2,-1260),(-1760,2,-1190),(-1835,2,-1180),(-1910,2,-1190),(-1955,2,-1260)]
SUPPLIES=[(-2015,2,-1510),(-1835,2,-1515),(-1655,2,-1510),(-1660,2,-1680),(-2060,2,-1380)]
EXTRA=json.loads((ROOT/'地图方案/掩体与补给.json').read_text())
SUPPLIES += [tuple(v) for v in EXTRA['supplies']]
COVERS=EXTRA['covers']
BOUNDS=(-2144,-1776,-1569,-1153)
ANCHORS=set()
for x,y,z,r in [(LOBBY[0],LOBBY[1],LOBBY[2],20), *[(x,y,z,10) for x,y,z in BASES.values()], *[(x,y,z,10) for x,y,z,name in POINTS.values()], *[(x,y,z,2) for x,y,z in GYM+SUPPLIES], *[(x,y,z,3) for x,y,z,k in ADVANCED], *[(POINTS[k][0],2,-1560,14) for k in ['A','C']]]:
 for cx in range((x-r)//16,(x+r)//16+1):
  for cz in range((z-r)//16,(z+r)//16+1):ANCHORS.add((cx*16,cz*16))

def protection_regions():
 regions=[]
 def add(x0,y0,z0,x1,y1,z1,label):regions.append(((x0,y0,z0,x1,y1,z1),label))
 x,y,z=LOBBY;add(x-18,y-1,z-6,x+18,y+6,z+10,'lobby')
 for team,(x,y,z) in BASES.items():add(x-8,y-1,z-8,x+8,y+6,z+8,'base_'+team)
 for key,(x,y,z,name) in POINTS.items():
  add(x-1,y-2,z-1,x+1,y+1,z+1,'point_'+key+'_core')
  add(x+4,y,z+4,x+6,y+4,z+4,'point_'+key+'_flag')
  for i in range(16):
   dx=round(9*math.cos(i*math.pi/8));dz=round(9*math.sin(i*math.pi/8))
   add(x+dx,y-1,z+dz,x+dx,y-1,z+dz,'point_'+key+'_ring_'+str(i))
 for i,(x,y,z) in enumerate(GYM+SUPPLIES):add(x-1,y-1,z-1,x+1,y+1,z+1,'cache_'+str(i))
 for x,y,z,k in ADVANCED:add(x-1,y-1,z-1,x+1,y+2,z+1,'advanced_'+k)
 return regions+roof_regions()

def make_pack(path,test_controls=1):
 path=Path(path)
 def js(p,v):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
 def fn(name,lines):
  p=path/'data/ustc_pvp/function'/(name+'.mcfunction');p.parent.mkdir(parents=True,exist_ok=True);p.write_text('\n'.join(lines)+'\n')
 def label(x,y,z,text,tag,color='yellow'):
  return f'summon text_display {x} {y} {z} '+json.dumps({'Tags':['ustc.decor',tag],'text':{'text':text,'color':color},'billboard':'center','background':1073741824,'line_width':260,'shadow':True},ensure_ascii=False,separators=(',',':'))
 def marker(x,y,z,tags,data=None):return f'summon marker {x} {y} {z} '+json.dumps({'Tags':tags,'data':data or {}},ensure_ascii=False,separators=(',',':'))
 def block(x,y,z,name):return f'setblock {x} {y} {z} minecraft:{name}'
 def fill(x,y,z,x2,y2,z2,name):return f'fill {min(x,x2)} {min(y,y2)} {min(z,z2)} {max(x,x2)} {max(y,y2)} {max(z,z2)} minecraft:{name}'
 def button(x,y,z,text,func,color='white'):
  command=f'execute as @p[distance=..5] at @s run function ustc_pvp:{func}'
  return [block(x,y,z,'polished_deepslate'),block(x,y+1,z,'command_block[facing=south]{Command:'+json.dumps(command)+',TrackOutput:0b}'),block(x,y+1,z+1,'stone_button[face=wall,facing=south]'),label(x+.5,y+3,z+.5,text,'ustc.control',color)]
 js(path/'pack.mcmeta',{'pack':{'description':'科大中区：三点/五点占领、团队死斗、基地与体育馆补给','min_format':[107,1],'max_format':107}})
 js(path/'data/minecraft/tags/function/load.json',{'replace':True,'values':['pvpshot:load','ustc_pvp:load']})
 js(path/'data/minecraft/tags/function/tick.json',{'replace':True,'values':['pvpshot:tick','ustc_pvp:tick']})
 js(path/'data/ustc_pvp/dimension/template.json',{'type':'minecraft:overworld','generator':{'type':'minecraft:flat','settings':{'biome':'minecraft:the_void','layers':[],'features':False,'lakes':False,'structure_overrides':[]}}})
 # An explicit override is applied by the core before any player can initialize.
 p=path/'data/pvpshot/function/cfg/override.mcfunction';p.parent.mkdir(parents=True,exist_ok=True);p.write_text('function ustc_pvp:configure\n')
 fn('configure',['scoreboard players set #discover.enabled pvpshot.cfg 0','scoreboard players set #arena.auto pvpshot.cfg 0','scoreboard players set #point.radius pvpshot.cfg 9','scoreboard players set #point.height pvpshot.cfg 3','scoreboard players set #chest.interval pvpshot.cfg 1200','scoreboard players set #tdm.max pvpshot.cfg 60','scoreboard players set #cap.max pvpshot.cfg 1000',f'scoreboard players set #test.controls pvpshot.cfg {test_controls}','scoreboard players set #mobility.speed pvpshot.cfg 0','scoreboard players set #mobility.jump pvpshot.cfg 0'])
 objectives=['ustc.deaths','ustc.init','ustc.clock','ustc.owner_old','ustc.y','ustc.join','ustc.mode','ustc.mobility','pvp_reset','pvp_kit','pvp_lobby']
 fn('load',[*[f'scoreboard objectives add {s} '+('trigger' if s in ['ustc.join','ustc.mode','ustc.mobility','pvp_reset','pvp_kit','pvp_lobby'] else 'dummy') for s in objectives],
 'bossbar add ustc_pvp:points {text:"科大中区",color:"white"}','bossbar set ustc_pvp:points color white',
 'execute unless data storage ustc_pvp:state {prepared:1b} run return 0','scoreboard players set #protection.active ustc.clock 1','scoreboard players set #protection.edit ustc.clock 0',
 'function ustc_pvp:anchors','schedule function ustc_pvp:resume 5t replace'])
 fn('anchors',[f'forceload add {x} {z}' for x,z in sorted(ANCHORS)])
 fn('resume',['execute if score #reset.active ustc.clock matches 1 run return run function ustc_pvp:reset/load_batch',
 'execute unless score #preset ustc.clock matches 0..5 run scoreboard players set #preset ustc.clock 5',
 'function ustc_pvp:apply_preset'])
 build=['gamerule minecraft:send_command_feedback false','gamerule minecraft:command_block_output false','gamerule minecraft:log_admin_commands false','gamerule minecraft:spawn_mobs false','gamerule minecraft:advance_time false','gamerule minecraft:advance_weather false','gamerule minecraft:natural_health_regeneration false','gamerule minecraft:keep_inventory true','gamerule minecraft:respawn_radius 0','gamerule minecraft:show_advancement_messages false','gamerule minecraft:command_blocks_work true','gamerule minecraft:fire_spread_radius_around_player 0','gamerule minecraft:random_tick_speed 0','time set noon','weather clear','difficulty normal',f'setworldspawn {LOBBY[0]} {LOBBY[1]} {LOBBY[2]} 0 0','function ustc_pvp:anchors']
 build+=['kill @e[tag=ustc.decor]','kill @e[tag=ustc.marker]',marker(*LOBBY,['ustc.marker','pvpshot.arena'])]
 # Elevated staging lobby outside the reset rectangle.
 lx,ly,lz=LOBBY
 build += [fill(lx-17,ly-1,lz-5,lx+17,ly-1,lz+9,'smooth_stone'),fill(lx-17,ly,lz-5,lx+17,ly+5,lz+9,'air')]
 for x,name,func,color in [(-14,'加入红队','join_red','red'),(-7,'加入蓝队','join_blue','blue'),(0,'三点占领','control/three','yellow'),(7,'五点占领','control/five','gold'),(14,'团队死斗','control/deathmatch','aqua')]:build+=button(lx+x,ly,lz-4,name,func,color)
 for x,name,func in [(-14,'重置战场','reset/request'),(-7,'补齐装备','kit'),(0,'领取速度 V','control/mobility_0'),(7,'领取跳跃 V','control/mobility_1'),(14,'补充奖励箱','control/refill')]:build+=button(lx+x,ly,lz+7,name,func)
 build += [fill(lx-18,ly,lz-6,lx+18,ly,lz-6,'stone_brick_wall'),fill(lx-18,ly,lz+10,lx+18,ly,lz+10,'stone_brick_wall'),fill(lx-18,ly,lz-6,lx-18,ly,lz+10,'stone_brick_wall'),fill(lx+18,ly,lz-6,lx+18,ly,lz+10,'stone_brick_wall')]
 build += [label(lx+.5,ly+5,lz+2.5,'科大中区对战场\n选择队伍进入；顶部显示比分\n三点 / 五点 / 团队死斗','ustc.lobby','aqua')]
 for team,(x,y,z) in BASES.items():
  name='红队' if team=='red' else '蓝队';front=1 if team=='red' else -1
  build += [fill(x-8,y-1,z-8,x+8,y-1,z+8,team+'_terracotta'),fill(x-8,y,z-8,x+8,y+4,z+8,'air'),fill(x-front*8,y,z-8,x-front*8,y+2,z+8,'stone_bricks')]
  for dz in [-8,8]:
   for a,b in [(-8,-3),(3,8)]:build.append(fill(x+a,y,z+dz,x+b,y+2,z+dz,'stone_bricks'))
  for dz in [-2,0,2]:build.append(marker(x+.5,y,z+dz+.5,['ustc.marker','pvpshot.spawn.'+team]))
  build += [label(x+.5,y+6,z+.5,name+'基地','ustc.base.'+team,team)]  # 2026-09-25 起不再生成基地 base_menu 按钮（作者要求）
 point_build=[]
 for key,(x,y,z,name) in POINTS.items():
  point_build += [fill(x-1,y,z-1,x+1,y+1,z+1,'air'),fill(x-1,y-2,z-1,x+1,y-2,z+1,'iron_block'),block(x,y-1,z,'beacon'),block(x,y,z,'white_stained_glass'),marker(x+.5,y,z+.5,['ustc.marker','ustc.point','ustc.point.'+key],{'label':key+' · '+name}),label(x+.5,y+6,z+.5,key+' · '+name,'ustc.label.'+key)]
  for i in range(16):
   dx=round(9*math.cos(i*math.pi/8));dz=round(9*math.sin(i*math.pi/8));point_build.append(block(x+dx,y-1,z+dz,'cut_copper'))
  point_build += [fill(x+4,y,z+4,x+4,y+4,z+4,'polished_blackstone_wall'),fill(x+5,y+3,z+4,x+6,y+4,z+4,'white_wool')]
 fn('points/build',point_build)
 build += ['function ustc_pvp:points/build']
 # Split eight gym caches over both sides, front and rear; five smaller field caches.
 for i,(x,y,z) in enumerate(GYM+SUPPLIES):
  gym=i<len(GYM);tag=f'ustc.cache.{i}';title=('体育馆补给 ' if gym else '战地补给 ')+str(i+1 if gym else i-len(GYM)+1)
  build += [fill(x-1,y-1,z-1,x+1,y-1,z+1,'smooth_stone'),block(x,y,z,'trapped_chest[facing=north]'),marker(x+.5,y,z+.5,['ustc.marker','pvpshot.chest',tag]+(['ustc.gym','pvpshot.chest.rich'] if gym else [])),label(x+.5,y+3,z+.5,title,tag+'.label','green')]
 fn('build',['scoreboard players set #protection.edit ustc.clock 1',*build,'scoreboard players set #preset ustc.clock 5','scoreboard players set #reset.active ustc.clock 0','data modify storage ustc_pvp:state prepared set value 1b','function ustc_pvp:apply_preset','function ustc_pvp:refill','scoreboard players set #protection.active ustc.clock 1','scoreboard players set #protection.edit ustc.clock 0'])
 terms=[]
 for bounds,label_name in protection_regions():
  x0,y0,z0,x1,y1,z1=bounds
  terms.append({'condition':'minecraft:location_check','predicate':{'dimension':'minecraft:overworld','position':{'x':{'min':x0,'max':x1+0.99999},'y':{'min':y0,'max':y1+0.99999},'z':{'min':z0,'max':z1+0.99999}}}})
 js(path/'data/ustc_pvp/predicate/protected.json',{'condition':'minecraft:any_of','terms':terms})
 p=path/'data/pvpshot/function/protection/check.mcfunction';p.parent.mkdir(parents=True,exist_ok=True)
 p.write_text('scoreboard players set #protected pvpshot.cal 0\nexecute if score #protection.active ustc.clock matches 1 if predicate ustc_pvp:protected run scoreboard players set #protected pvpshot.cal 1\n')
 repairs=['scoreboard players set #protection.edit ustc.clock 1']
 for line in build+point_build:
  if not line.startswith(('fill ','setblock ')):continue
  if 'minecraft:trapped_chest[' in line:
   _,x,y,z,_=line.split(' ',4)
   repairs.append(f'execute positioned {x} {y} {z} unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache')
  else:repairs.append(line)
 fn('protection/cache',['setblock ~ ~ ~ minecraft:trapped_chest[facing=north]','function pvpshot:chest/refill_one'])
 fn('protection/repair',repairs+['scoreboard players set #protection.active ustc.clock 1','scoreboard players set #protection.edit ustc.clock 0'])
 fn('apply_preset',['tag @e[tag=ustc.point] remove pvpshot.point','execute if score #preset ustc.clock matches 3..5 run tag @e[tag=ustc.point.A] add pvpshot.point','execute if score #preset ustc.clock matches 3..5 run tag @e[tag=ustc.point.B] add pvpshot.point','execute if score #preset ustc.clock matches 3..5 run tag @e[tag=ustc.point.C] add pvpshot.point','execute if score #preset ustc.clock matches 5 run tag @e[tag=ustc.point.D] add pvpshot.point','execute if score #preset ustc.clock matches 5 run tag @e[tag=ustc.point.E] add pvpshot.point','scoreboard players set #mode pvpshot.cfg 1','execute if score #preset ustc.clock matches 0 run scoreboard players set #mode pvpshot.cfg 0','scoreboard players set #cap.max pvpshot.cfg 600','execute if score #preset ustc.clock matches 5 run scoreboard players set #cap.max pvpshot.cfg 1000','execute as @e[tag=ustc.point] at @s run function pvpshot:point/reset','scoreboard players set @e[tag=ustc.point] ustc.owner_old -1','function pvpshot:match/restart','function ustc_pvp:hud','execute as @a[team=pvpshot.red] run function ustc_pvp:spawn','execute as @a[team=pvpshot.blue] run function ustc_pvp:spawn','function ustc_pvp:advanced/refill'])
 for name,n in [('three',3),('five',5),('deathmatch',0)]:
  fn('preset/'+name,['execute if score #reset.active ustc.clock matches 1 run return 0',f'scoreboard players set #preset ustc.clock {n}','function ustc_pvp:apply_preset','tellraw @a {text:"已切换模式并开启新局。恢复地形请使用重置战场。",color:"gold"}'])
  fn('control/'+name,['execute unless score #test.controls pvpshot.cfg matches 1 run return 0','function ustc_pvp:preset/'+name])
 fn('spawn',['effect clear @s','function pvpshot:player/respawn','function ustc_pvp:mobility/apply'])
 fn('welcome',['scoreboard players set @s ustc.init 1','function ustc_pvp:lobby','tellraw @s {text:"欢迎来到科大中区。大厅选队；/trigger ustc.join set 1 红队、set 2 蓝队。",color:"aqua"}'])
 fn('lobby',['scoreboard players set @s pvp_lobby 0',f'tp @s {lx+.5} {ly} {lz+2.5} 180 0',f'spawnpoint @s {lx} {ly} {lz+2} 180 0'])
 fn('base_menu',['function ustc_pvp:kit','tellraw @s {text:"/trigger pvp_kit 补装备；/trigger pvp_lobby 返回大厅。",color:"green"}'])
 for team in ['red','blue']:
  fn('join_'+team,['execute if score #reset.active ustc.clock matches 1 run return 0','scoreboard players set @s ustc.join 0',f'team join pvpshot.{team} @s','gamemode survival @s','function pvpshot:player/score_init','function ustc_pvp:spawn'])
 fn('kit',['scoreboard players set @s pvp_kit 0','execute unless score #test.controls pvpshot.cfg matches 1 run return 0','function ustc_pvp:test_kit','function ustc_pvp:mobility/apply'])
 test_kit=['clear @s','function pvpshot:ammo/reset','function pvpshot:regen/in_combat']
 for loot in ['cannon_dye','turret_dye','fire_charge','grenade','pickaxe','egg','bow','crossbow','trident','snowball','rocket','speed','wind','pearl','harming','slow','blind','heal','linger','tnt','shield']:
  test_kit.append(f'loot give @s loot pvpshot:item/{loot}')
  if loot=='pickaxe':test_kit.append('function pvpshot:kit/blocks')
 js(path/'data/ustc_pvp/item_modifier/deploy_count.json',{'function':'minecraft:set_count','count':16})
 test_kit += ['item modify entity @s hotbar.0 ustc_pvp:deploy_count','item modify entity @s hotbar.1 ustc_pvp:deploy_count','give @s minecraft:arrow 36','effect give @s minecraft:instant_health 1 10 true','effect give @s minecraft:saturation 1 10 true','tellraw @s {text:"全套测试装备：1 TNT 炮 / 2 炮塔 / 3 火焰弹 / 4 手雷 / 5 铁镐 / 6 队色陶瓦。",color:"green"}']
 fn('test_kit',test_kit)
 fn('control/refill',['execute unless score #test.controls pvpshot.cfg matches 1 run return 0','function ustc_pvp:refill'])
 fn('refill',['function pvpshot:chest/refill_all',*[f'execute positioned {x} {y} {z} run function ustc_pvp:refill_gym' for x,y,z in GYM]])
 fn('refill_gym',['execute unless block ~ ~ ~ minecraft:trapped_chest run return 0','function pvpshot:chest/refill_one'])
 # Twice-scale architecture: Jump II restores a roughly doubled step capability.
 for n,speed,jump in [(0,0,0),(1,0,2),(2,0,2)]:
  fn('mobility/profile_'+str(n),[f'scoreboard players set #mobility.speed pvpshot.cfg {speed}',f'scoreboard players set #mobility.jump pvpshot.cfg {jump}','execute as @a run effect clear @s minecraft:jump_boost','execute as @a[gamemode=survival,team=!,scores={pvpshot.live=1..}] run function ustc_pvp:mobility/apply'])
  fn('control/mobility_'+str(n),['execute unless score #test.controls pvpshot.cfg matches 1 run return 0','function ustc_pvp:mobility/profile_'+str(n)])
 fn('mobility/apply',['execute unless entity @s[team=pvpshot.red] unless entity @s[team=pvpshot.blue] run return 0','execute if score #mobility.jump pvpshot.cfg matches 2 run effect give @s minecraft:jump_boost 3 1 true'])
 fn('tick',['execute unless data storage ustc_pvp:state {prepared:1b} run return 0','execute as @a unless score @s ustc.init matches 1 run function ustc_pvp:welcome','execute as @a[scores={ustc.join=1}] run function ustc_pvp:join_red','execute as @a[scores={ustc.join=2..}] run function ustc_pvp:join_blue','execute as @a[scores={pvpshot.live=1..}] unless score @s ustc.deaths = @s pvpshot.deaths run function ustc_pvp:mobility/apply','execute as @a[scores={pvpshot.live=1..}] run scoreboard players operation @s ustc.deaths = @s pvpshot.deaths','execute as @a[scores={pvp_lobby=1..}] run function ustc_pvp:lobby','execute as @a[scores={pvp_kit=1..}] run function ustc_pvp:kit','execute as @a[scores={pvp_reset=1..}] run function ustc_pvp:reset/request','execute as @a[scores={ustc.mode=3}] run function ustc_pvp:control/three','execute as @a[scores={ustc.mode=5}] run function ustc_pvp:control/five','execute as @a[scores={ustc.mode=1}] run function ustc_pvp:control/deathmatch','scoreboard players set @a[scores={ustc.mode=1..}] ustc.mode 0',*[f'scoreboard players enable @a {s}' for s in ['ustc.join','ustc.mode','pvp_reset','pvp_kit','pvp_lobby']],
 'scoreboard players add #tick ustc.clock 1','execute if score #tick ustc.clock matches 20.. run function ustc_pvp:second','execute if score #reset.active ustc.clock matches 1 as @a[gamemode=survival] run function ustc_pvp:lobby'])
 fn('second',['scoreboard players set #tick ustc.clock 0','execute if score #reset.cooldown ustc.clock matches 1.. run scoreboard players remove #reset.cooldown ustc.clock 1','execute as @a[gamemode=survival,team=!,scores={pvpshot.live=1..}] run function ustc_pvp:mobility/apply','execute if score #chest.timer pvpshot.chest matches 0..19 run function ustc_pvp:refill','function ustc_pvp:hud'])
 hud=['bossbar set ustc_pvp:points players @a','execute if score #reset.active ustc.clock matches 1 run return 0','bossbar set ustc_pvp:points max 1','bossbar set ustc_pvp:points value 0','bossbar set ustc_pvp:points visible true','execute if score #preset ustc.clock matches 0 run bossbar set ustc_pvp:points visible false']
 for key,(x,y,z,name) in POINTS.items():
  lower=key.lower();hud += [f'data modify storage ustc_pvp:hud {lower} set value "gray"',f'execute if entity @e[tag=ustc.point.{key},tag=pvpshot.point,scores={{pvpshot.owner=1}}] run data modify storage ustc_pvp:hud {lower} set value "red"',f'execute if entity @e[tag=ustc.point.{key},tag=pvpshot.point,scores={{pvpshot.owner=2}}] run data modify storage ustc_pvp:hud {lower} set value "blue"',f'execute as @e[tag=ustc.point.{key}] unless score @s ustc.owner_old = @s pvpshot.owner run function ustc_pvp:flag/{key.lower()}']
  flag=['data modify storage ustc_pvp:flag owner set value "中立"','data modify storage ustc_pvp:flag color set value "gray"','execute if score @s pvpshot.owner matches 1 run data modify storage ustc_pvp:flag owner set value "红队"','execute if score @s pvpshot.owner matches 1 run data modify storage ustc_pvp:flag color set value "red"','execute if score @s pvpshot.owner matches 2 run data modify storage ustc_pvp:flag owner set value "蓝队"','execute if score @s pvpshot.owner matches 2 run data modify storage ustc_pvp:flag color set value "blue"','execute unless entity @s[tag=pvpshot.point] run data modify storage ustc_pvp:flag owner set value "本模式停用"',f'data modify storage ustc_pvp:flag key set value "{key}"',f'data modify storage ustc_pvp:flag label set value "{key} · {name}"','function ustc_pvp:flag/text with storage ustc_pvp:flag','scoreboard players operation @s ustc.owner_old = @s pvpshot.owner']
  fn('flag/'+lower,flag)
 hud+=['execute if score #preset ustc.clock matches 3 run function ustc_pvp:hud_three with storage ustc_pvp:hud','execute if score #preset ustc.clock matches 5 run function ustc_pvp:hud_five with storage ustc_pvp:hud'];fn('hud',hud)
 fn('flag/text',['$data modify entity @e[type=text_display,tag=ustc.label.$(key),limit=1] text set value {text:"$(label) · $(owner)",color:"$(color)"}'])
 for preset,keys in [('three','ABC'),('five','ABCDE')]:fn('hud_'+preset,['$bossbar set ustc_pvp:points name '+json.dumps([{'text':('三点' if preset=='three' else '五点')+'  |  ','color':'white'}]+[{'text':k+'   ','color':'$('+k.lower()+')'} for k in keys]+[{'text':'灰：中立 · 红/蓝：所属队伍','color':'gray'}],ensure_ascii=False,separators=(',',':'))])
 # New cover is rebuilt per loaded chunk, so it does not add permanent chunk tickets.
 overlays={}
 for i,(x,y,z) in enumerate(COVERS):
  material=['stone_bricks','bricks','light_gray_concrete'][i%3]
  cells={(x+dx,y+dy,z+dz) for dx in range(-1,2) for dy in range(3) for dz in range(-1,2)} if i%3==0 else {(x+dx,y+dy,z) for dx in range(-2,3) for dy in range(2)}|{(x+2,y+dy,z+dz) for dy in range(2) for dz in [1,2]}
  for a,b,c in sorted(cells):overlays.setdefault((a//16*16,c//16*16),[]).append(block(a,b,c,material))
 for (x,z),lines in overlays.items():fn(f'terrain/c_{x}_{z}',lines)
 # Copy original block snapshots from a private dimension, loading only eight chunks at a time.
 x0,z0,x1,z1=BOUNDS;tiles=[(x,z) for x in range(x0,x1+1,16) for z in range(z0,z1+1,16)];batches=[tiles[i:i+8] for i in range(0,len(tiles),8)]
 for i,batch in enumerate(batches):
  load=[];copy=['scoreboard players set #batch.ready ustc.clock 1'];release=[]
  for x,z in batch:
   for dim in ['minecraft:overworld','ustc_pvp:template']:
    load.append(f'execute in {dim} run forceload add {x} {z}')
    copy.append(f'execute in {dim} unless loaded {x} 0 {z} run scoreboard players set #batch.ready ustc.clock 0')
    release.append(f'execute in {dim} run forceload remove {x} {z}')
  copy += ['execute if score #batch.ready ustc.clock matches 0 run return run schedule function ustc_pvp:reset/copy_batch 2t replace']
  for x,z in batch:
   for low,high in [(-16,55),(56,127)]:
    copy += [f'execute store success score #copied ustc.clock run clone from ustc_pvp:template {x} {low} {z} {x+15} {high} {z+15} to minecraft:overworld {x} {low} {z} replace force','execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1']
   # Restore the immutable floor and new cover after restoring original blocks.
   copy += [f'fill {x} -1 {z} {x+15} -1 {z+15} minecraft:bedrock']
   if (x,z) in overlays:copy.append(f'function ustc_pvp:terrain/c_{x}_{z}')
   for selector in ['type=#pvpshot:resettable','tag=pvpshot.shot','tag=pvpshot.machine','tag=pvpshot.field']:
    copy.append(f'kill @e[{selector},x={x},y=-16,z={z},dx=15,dy=272,dz=15]')
  copy += release+['function ustc_pvp:reset/advance'];fn(f'reset/batch_{i}/load',load+['schedule function ustc_pvp:reset/copy_batch 2t replace']);fn(f'reset/batch_{i}/copy',copy)
 fn('reset/request',['scoreboard players set @s pvp_reset 0','execute unless score #test.controls pvpshot.cfg matches 1 run return run tellraw @s {text:"服务器已关闭玩家重置入口。",color:"red"}','execute if score #reset.active ustc.clock matches 1 run return run tellraw @s {text:"战场正在恢复，请等待顶部进度完成。",color:"yellow"}','execute if score #reset.cooldown ustc.clock matches 1.. run return run tellraw @s [{text:"重置冷却中，剩余 "},{score:{name:"#reset.cooldown",objective:"ustc.clock"}},{text:" 秒。",color:"yellow"}]','function ustc_pvp:reset/start'])
 cleanup=['kill @e[tag=pvpshot.shot]','function pvpshot:field/clear']+[f'kill @e[type=minecraft:{typ},x={x0},y=-16,z={z0},dx={x1-x0},dy=272,dz={z1-z0}]' for typ in ['tnt','arrow','snowball','egg','fireball','small_fireball','item','area_effect_cloud']]
 fn('reset/start',['execute if score #reset.active ustc.clock matches 1 run return 0','scoreboard players set #reset.active ustc.clock 1','scoreboard players set #reset.index ustc.clock 0','scoreboard players set #reset.errors ustc.clock 0','scoreboard players set #match.state pvpshot.cal 0','execute as @a run function ustc_pvp:lobby','kill @e[tag=pvpshot.machine]',*cleanup,'bossbar set ustc_pvp:points visible true',f'bossbar set ustc_pvp:points max {len(batches)}','tellraw @a {text:"正在分批恢复中区战场，请在大厅等待。顶部显示恢复进度。",color:"yellow"}','function ustc_pvp:reset/load_batch'])
 fn('reset/load_batch',[f'execute if score #reset.index ustc.clock matches {len(batches)}.. run return run function ustc_pvp:reset/finish','execute store result storage ustc_pvp:reset batch int 1 run scoreboard players get #reset.index ustc.clock','function ustc_pvp:reset/load_macro with storage ustc_pvp:reset'])
 fn('reset/load_macro',['$function ustc_pvp:reset/batch_$(batch)/load'])
 fn('reset/copy_batch',['execute store result storage ustc_pvp:reset batch int 1 run scoreboard players get #reset.index ustc.clock','function ustc_pvp:reset/copy_macro with storage ustc_pvp:reset'])
 fn('reset/copy_macro',['$function ustc_pvp:reset/batch_$(batch)/copy'])
 fn('reset/advance',['scoreboard players add #reset.index ustc.clock 1','execute store result bossbar ustc_pvp:points value run scoreboard players get #reset.index ustc.clock',f'bossbar set ustc_pvp:points name [{{text:"恢复战场："}},{{score:{{name:"#reset.index",objective:"ustc.clock"}}}},{{text:" / {len(batches)} 批"}}]',f'execute if score #reset.index ustc.clock matches {len(batches)}.. run return run function ustc_pvp:reset/finish','function ustc_pvp:reset/load_batch'])
 # Rebuild gameplay objects without overwriting the selected mode.
 fn('reset/finish',['function ustc_pvp:anchors','schedule function ustc_pvp:reset/finish_ready 2t replace'])
 fn('reset/finish_ready',['scoreboard players set #anchors.ready ustc.clock 1',*[f'execute unless loaded {x} 0 {z} run scoreboard players set #anchors.ready ustc.clock 0' for x,z in sorted(ANCHORS)],'execute if score #anchors.ready ustc.clock matches 0 run return run schedule function ustc_pvp:reset/finish_ready 2t replace','scoreboard players operation #restore.preset ustc.clock = #preset ustc.clock',*cleanup,'function ustc_pvp:build','scoreboard players operation #preset ustc.clock = #restore.preset ustc.clock','function ustc_pvp:apply_preset','function ustc_pvp:refill','scoreboard players set #reset.cooldown ustc.clock 15','execute if score #reset.errors ustc.clock matches 1.. run tellraw @a {text:"部分区域恢复失败，请查看服务端日志。",color:"red"}','execute if score #reset.errors ustc.clock matches 0 run tellraw @a {text:"中区战场已恢复：建筑、道路、据点、基地及补给箱已复原，新局开始。",color:"green"}'])
 extend(path,POINTS)
 extend_v8(path,POINTS)
 return {'points':POINTS,'bases':BASES,'lobby':LOBBY,'gym':GYM,'supplies':SUPPLIES,'bounds':BOUNDS,'reset_batches':len(batches),'covers':COVERS,'foundation_y':-1,'supply_total':len(GYM+SUPPLIES),'advanced':ADVANCED,'balance_revision':8}
if __name__=='__main__':
 p=ROOT/'ustc_pvp';meta=make_pack(p);(ROOT/'地图方案/实际点位.json').write_text(json.dumps(meta,ensure_ascii=False,indent=2)+'\n');print('Generated',p,meta['reset_batches'],'reset batches')
