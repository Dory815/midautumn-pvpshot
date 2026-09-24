#!/usr/bin/env python3
"""Build and verify a playable vanilla 26.2 PvP save using Mojang's GameTest engine.

Requires an existing Java 25 JDK and official server jar; downloads nothing.
Only a dedicated temporary work directory is regenerated. Installation is separate.
"""
import argparse
import importlib.util
import json
from pathlib import Path
import re
import shutil
import subprocess
import time
import zipfile

from nbt import read, write

ROOT = Path(__file__).resolve().parents[2]
TITLE = 'PVP交火试验场 · 26.2'
FOLDER = 'PVP_Test_Arena_26.2'


def save_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + '\n')


def make_pack(pack):
    save_json(pack / 'pack.mcmeta', {'pack': {'description': '交火试验场：装备、分队、场地重置', 'min_format': [107, 1], 'max_format': 107}})
    base = pack / 'data/pvp_test'

    def function(name, lines):
        path = base / 'function' / (name + '.mcfunction')
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text('\n'.join(lines) + '\n')

    function('load', ['scoreboard objectives add pvp_test.init dummy',
        'scoreboard objectives add pvp_test.deaths dummy',
        'scoreboard objectives add pvp_kit trigger',
        'scoreboard objectives add pvp_lobby trigger',
        'scoreboard objectives add pvp_reset trigger',
        'scoreboard players set #reset.wait pvp_test.init 0',
        'forceload add -56 -48 56 48',
        'schedule function pvp_test:patch_controls 1t replace',
        'tellraw @a {text:"新版：无限备弹雪球＋手雷＋铁镐；脱战 5 秒自动回血。/trigger pvp_kit 领取新版装备；/trigger pvp_reset 重置场地。",color:"yellow"}'])
    function('tick', [
        'execute as @a unless score @s pvp_test.init matches 1 at @s run function pvp_test:welcome',
        'execute as @a[nbt=!{Health:0.0f}] unless score @s pvp_test.deaths = @s pvpshot.deaths at @s run function pvp_test:respawn_kit',
        'execute as @a[scores={pvp_kit=1..}] at @s run function pvp_test:kit',
        'execute as @a[scores={pvp_lobby=1..}] at @s run function pvp_test:lobby',
        'execute if score #reset.wait pvp_test.init matches 1.. run scoreboard players remove #reset.wait pvp_test.init 1',
        'execute as @a[scores={pvp_reset=1..}] at @s run function pvp_test:request_reset',
        'scoreboard players enable @a pvp_kit', 'scoreboard players enable @a pvp_lobby',
        'scoreboard players enable @a pvp_reset'])
    save_json(pack / 'data/minecraft/tags/function/load.json', {'values': ['pvp_test:load']})
    save_json(pack / 'data/minecraft/tags/function/tick.json', {'values': ['pvp_test:tick']})
    save_json(base / 'item_modifier/deploy_count.json', {'function': 'minecraft:set_count', 'count': 16})
    kit = ['clear @s', 'scoreboard players set @s pvp_kit 0', 'function pvpshot:ammo/reset', 'function pvpshot:regen/in_combat']
    for loot in ['cannon_dye', 'turret_dye', 'snowball', 'grenade', 'pickaxe', 'egg', 'bow', 'crossbow', 'trident',
                 'fire_charge', 'wind', 'pearl', 'harming', 'slow', 'blind', 'heal', 'linger', 'tnt', 'shield']:
        kit.append(f'loot give @s loot pvpshot:item/{loot}')
    kit += ['item modify entity @s hotbar.0 pvp_test:deploy_count',
            'item modify entity @s hotbar.1 pvp_test:deploy_count',
            'give @s minecraft:arrow 36',
            'attribute @s minecraft:max_health base set 20',
            'effect give @s minecraft:instant_health 1 10 true',
            'effect give @s minecraft:saturation 1 10 true',
            'tellraw @s {text:"装备已补齐：1 TNT 炮 / 2 炮塔 / 3 无限雪球 / 4 手雷 / 5 铁镐。雪球打空 2 秒换弹；脱战 5 秒快速回血。",color:"green"}']
    function('kit', kit)
    function('respawn_kit', ['function pvp_test:kit', 'scoreboard players operation @s pvp_test.deaths = @s pvpshot.deaths'])
    function('welcome', ['execute unless score @s pvpshot.init matches 1 run function pvpshot:player/init',
        'scoreboard players set @s pvp_test.init 1', 'team join pvpshot.red @s',
        'gamemode survival @s', 'function pvp_test:lobby', 'function pvp_test:respawn_kit',
        'tellraw @s {text:"欢迎来到交火试验场！出生大厅按钮可选红/蓝队、补装备、切换创造。/trigger pvp_kit 随时补给；/trigger pvp_lobby 返回大厅。",color:"aqua"}',
        'tellraw @s {text:"20 HP（10 心），开启友伤。冰霜雪球 6 伤＋短迟缓，破片鸡蛋直击 3、周围 2。TNT 按原版距离、方块遮挡和护甲结算。/trigger pvp_reset 重置核心区。",color:"yellow"}'])
    function('lobby', ['scoreboard players set @s pvp_lobby 0', 'tp @s 0.5 65 -41.5 0 0',
        'spawnpoint @s 0 65 -42 0 0'])
    for team, x, yaw in [('red', -47, -90), ('blue', 47, 90)]:
        function('team_' + team, [f'team join pvpshot.{team} @s', 'gamemode survival @s',
            f'tp @s {x + .5} 65 0.5 {yaw} 0', f'spawnpoint @s {x} 65 0 {yaw} 0',
            'function pvp_test:kit', 'effect give @s minecraft:resistance 2 4 true'])
    function('creative', ['gamemode creative @s', 'tellraw @s {text:"已切换创造模式，可飞行查看场地。测试扣血前请按生存模式按钮。",color:"aqua"}'])
    function('survival', ['gamemode survival @s', 'function pvp_test:kit'])

    lines = []
    def cmd(text):
        lines.append(text)
    def fill(x1,y1,z1,x2,y2,z2,block):
        # Split along X, staying below the vanilla command modification limit.
        low, high = min(x1,x2), max(x1,x2)
        y1,y2 = min(y1,y2),max(y1,y2)
        z1,z2 = min(z1,z2),max(z1,z2)
        width = max(1,32768 // ((y2-y1+1)*(z2-z1+1)))
        for x in range(low,high+1,width):
            cmd(f'fill {x} {y1} {z1} {min(x+width-1,high)} {y2} {z2} minecraft:{block}')
    def block(x,y,z,name):
        cmd(f'setblock {x} {y} {z} minecraft:{name}')
    def label(x,y,z,text,color='white',scale=1.0):
        component=json.dumps({'text':text,'color':color},ensure_ascii=False,separators=(',',':'))
        cmd(f'summon minecraft:text_display {x} {y} {z} {{Tags:["pvp_test.decor"],text:{component},billboard:"center",'
            f'background:1073741824,line_width:240,alignment:"center",view_range:0.8f,shadow:1b,'
            f'transformation:{{scale:[{scale}f,{scale}f,{scale}f],translation:[0f,0f,0f],'
            f'left_rotation:[0f,0f,0f,1f],right_rotation:[0f,0f,0f,1f]}}}}')
    def button(x,z,name,func,color='white'):
        command=f'execute as @p[distance=..5] at @s run function pvp_test:{func}'
        block(x,65,z,'polished_deepslate')
        block(x,66,z,'command_block[facing=south]{Command:'+json.dumps(command)+',TrackOutput:0b}')
        block(x,67,z,'polished_deepslate')
        block(x,66,z+1,'stone_button[face=wall,facing=south]')
        label(x+.5,68.1,z+.7,name,color,.7)
    def marker(x,y,z,*tags):
        cmd(f'summon minecraft:marker {x} {y} {z} '+json.dumps({'Tags':list(tags)},separators=(',',':')))

    cmd('gamerule minecraft:send_command_feedback false')
    cmd('gamerule minecraft:command_block_output false')
    cmd('gamerule minecraft:log_admin_commands false')
    cmd('gamerule minecraft:spawn_mobs false')
    cmd('gamerule minecraft:spawn_patrols false')
    cmd('gamerule minecraft:spawn_wandering_traders false')
    cmd('gamerule minecraft:advance_time false')
    cmd('gamerule minecraft:advance_weather false')
    cmd('gamerule minecraft:natural_health_regeneration false')
    cmd('gamerule minecraft:keep_inventory true')
    cmd('gamerule minecraft:respawn_radius 0')
    cmd('gamerule minecraft:show_advancement_messages false')
    cmd('gamerule minecraft:command_blocks_work true')
    cmd('time set noon'); cmd('weather clear'); cmd('difficulty normal')
    cmd('setworldspawn 0 65 -42 0 0')
    for tag in ['pvp_test.decor','pvpshot.arena','pvpshot.point','pvpshot.spawn.red','pvpshot.spawn.blue','pvpshot.chest','pvpshot.machine']:
        cmd(f'kill @e[type=!minecraft:player,tag={tag}]')
    for entity in ['tnt','arrow','snowball','egg','small_fireball','fireball','item','area_effect_cloud','chicken']:
        cmd(f'kill @e[type=minecraft:{entity},x=-57,y=60,z=-49,dx=114,dy=30,dz=98]')
    fill(-56,65,-48,56,80,48,'air')
    fill(-56,63,-48,56,63,48,'bedrock')
    fill(-56,64,-48,56,64,48,'light_gray_concrete')
    fill(-53,64,-34,53,64,34,'smooth_stone')
    # Three connected routes, with clear cross-map firing lanes.
    for z in [-24,0,24]:
        fill(-45,64,z-3,45,64,z+3,'polished_andesite')
        for x in range(-40,41,8):
            fill(x,64,z-4,x+2,64,z-4,'white_concrete')
            fill(x,64,z+4,x+2,64,z+4,'white_concrete')
    fill(-4,64,-38,4,64,34,'polished_andesite')
    for x in [-56,56]:
        fill(x,65,-48,x,68,48,'deepslate_bricks')
        fill(x,69,-48,x,70,48,'tinted_glass')
    for z in [-48,48]:
        fill(-56,65,z,56,68,z,'deepslate_bricks')
        fill(-56,69,z,56,70,z,'tinted_glass')
    for x in range(-48,49,16):
        for z in [-34,34]:
            block(x,64,z,'sea_lantern')
    # Low internal dividers protect the lobby and the separate deployment range.
    for z in [-36,36]:
        fill(-54,65,z,-5,67,z,'stone_bricks')
        fill(5,65,z,54,67,z,'stone_bricks')
    # Bases use terracotta; only the single spawn core is red/blue concrete.
    for sign, team, color in [(-1,'red','red'),(1,'blue','blue')]:
        fill(sign*43,64,-11,sign*53,64,11,team+'_terracotta')
        block(sign*47,64,0,team+'_concrete')
        marker(sign*47+.5,65,.5,'pvpshot.spawn.'+team)
        label(sign*48,70,.5,'红队基地' if sign<0 else '蓝队基地',color,1.25)
        for z1,z2 in [(-11,-3),(3,11)]:
            fill(sign*41,65,z1,sign*41,68,z2,'stone_bricks')
            fill(sign*41,69,z1,sign*41,69,z2,'smooth_stone_slab[type=bottom]')
        button(sign*49,-10,'补齐装备','kit','green')
        button(sign*45,-10,'返回大厅','lobby','aqua')
        for i,tier in enumerate(['leather','golden','chainmail','iron','diamond']):
            x,z=sign*51,6-i*2
            block(x,65,z,'chest[facing='+('east' if sign<0 else 'west')+']')
            for slot,piece in enumerate(['helmet','chestplate','leggings','boots']):
                cmd(f'item replace block {x} 65 {z} container.{slot} with minecraft:{tier}_{piece}')
        label(sign*51,68,3,'护甲柜\n皮革 / 金 / 锁链 / 铁 / 钻石','yellow',.75)
    # Staggered cover blocks and climbable two-block platforms.
    for sign in [-1,1]:
        for z in [-11,11]:
            fill(sign*16,65,z-3,sign*21,66,z+3,'stone_bricks')
            fill(sign*15,65,z-2,sign*15,65,z+2,'polished_andesite')
            fill(sign*18,67,z+2,sign*21,68,z+3,'deepslate_bricks')
        for z in [-9,9]:
            fill(sign*7,65,z-1,sign*10,67,z+1,'deepslate_bricks')
        for z in [-18,18]:
            fill(sign*12,65,z-1,sign*14,66,z+1,'bricks')
        for z in [-24,24]:
            x=sign*30
            fill(x-5,64,z-5,x+5,64,z+5,'orange_terracotta')
            fill(x-4,64,z-4,x+4,64,z+4,'smooth_stone')
            label(x,69,z,'部署区\n朝向中央，右键放炮','gold',.7)
        # Breakable cover offsets from the main lane; rebuilding resets it.
        for z in [-6,6]:
            fill(sign*28,65,z,sign*30,66,z,'white_wool')
    # Exactly three capture cores, not entire gold floors.
    for z, name in [(-24,'A'),(0,'B'),(24,'C')]:
        fill(-2,64,z-2,2,64,z+2,'orange_terracotta')
        block(0,64,z,'gold_block')
        marker(.5,65,z+.5,'pvpshot.point')
        label(.5,70,z+.5,name+' 占领点','yellow',1.1)
    # Refillable trapped-chest supplies, clear of every deployment pad.
    for x,z in [(-22,-4),(22,4)]:
        block(x,65,z,'trapped_chest[facing=south]')
        marker(x+.5,65,z+.5,'pvpshot.chest')
        cmd(f'execute positioned {x} 65 {z} run function pvpshot:chest/refill_one')
    # South range offers a long, unobstructed space for placement and shell flight.
    fill(-50,64,39,50,64,45,'smooth_stone')
    for x in [-40,40]:
        fill(x-4,64,38,x+4,64,46,'orange_terracotta')
        fill(x-3,64,39,x+3,64,45,'smooth_stone')
    fill(-1,65,41,1,67,43,'glass')
    label(.5,71,42,'部署试射走廊\n两端相向放炮 · 中央玻璃可炸毁','gold',.9)
    # Lobby: readily visible controls and all instructions are in-world.
    for x,name,func,color in [(-24,'加入红队','team_red','red'),(-16,'加入蓝队','team_blue','blue'),
        (-8,'补齐装备','kit','green'),(0,'生存模式','survival','yellow'),(8,'创造模式','creative','aqua'),
        (16,'重置核心区','request_reset','gold'),
        (24,'重置全场\n清空炮台 / 修复掩体','reset','gold')]:
        button(x,-46,name,func,color)
    label(.5,72,-38.5,'交火试验场\n26.2 · 三点占领 · 多方块武器测试','aqua',1.3)
    label(-18,68,-39,'红色染料 = TNT 炮\n橙色染料 = 炮塔\n面朝空地，按右键部署','white',.9)
    label(18,68,-39,'20 HP = 10 颗心 · 开启友伤\n雪球 16 发＋无限备弹 / 手雷＋铁镐\n脱战 5 秒快速回血 · TNT 原版结算','white',.85)
    marker(.5,65,-41.5,'pvpshot.arena')
    cmd('scoreboard players set Red pvpshot.score 0')
    cmd('scoreboard players set Blue pvpshot.score 0')
    function('build', lines)
    function('reset', ['tp @a 0.5 65 -41.5 0 0', 'function pvp_test:build',
        'effect clear @a', 'effect give @a minecraft:fire_resistance 8 0 true',
        'execute as @a run function pvp_test:kit',
        'tellraw @a {text:"场地已重置：炮台与弹药实体已清除，掩体和护甲柜已恢复，比分归零。",color:"gold"}'])

    # Clip static construction commands to the combat core. Lobby and bases stay intact.
    core=[]
    bounds=((-38,38),(63,80),(-34,34))
    for line in lines:
        fields=line.split(' ',7)
        if fields[0]=='fill':
            start=list(map(int,fields[1:4]));end=list(map(int,fields[4:7]))
            lo=[max(start[i],bounds[i][0]) for i in range(3)]
            hi=[min(end[i],bounds[i][1]) for i in range(3)]
            if all(lo[i]<=hi[i] for i in range(3)):
                core.append('fill '+' '.join(map(str,lo+hi))+' '+fields[7])
        elif fields[0]=='setblock':
            pos=list(map(int,fields[1:4]))
            if all(bounds[i][0]<=pos[i]<=bounds[i][1] for i in range(3)):
                core.append(line)
        elif fields[0]=='summon':
            pos=list(map(float,fields[2:5]))
            if all(bounds[i][0]<=pos[i]<=bounds[i][1]+1 for i in range(3)):
                core.append(line)
        elif line.startswith('execute positioned ') and 'chest/refill_one' in line:
            core.append(line)
    function('build_core',core)
    function('reset_core',[
        'scoreboard players set #reset.wait pvp_test.init 100',
        'execute as @e[tag=pvpshot.turret,x=-56,y=60,z=-48,dx=112,dy=256,dz=96] at @s rotated as @s run function pvpshot:turret/unpower',
        'execute as @e[tag=pvpshot.cannon,x=-56,y=60,z=-48,dx=112,dy=256,dz=96] at @s rotated as @s run function pvpshot:cannon/unpower',
        'kill @e[tag=pvpshot.machine,x=-56,y=60,z=-48,dx=112,dy=256,dz=96]',
        'execute as @a[team=pvpshot.red] run tp @s -47.5 65 0.5 -90 0',
        'execute as @a[team=pvpshot.blue] run tp @s 47.5 65 0.5 90 0',
        'execute as @a[team=] run function pvp_test:lobby',
        *[f'kill @e[type=minecraft:{kind},x=-56,y=60,z=-48,dx=112,dy=256,dz=96]' for kind in ['tnt','arrow','snowball','egg','small_fireball','fireball','item','area_effect_cloud']],
        *[f'kill @e[tag={tag},x=-38,y=63,z=-34,dx=76,dy=18,dz=68]' for tag in ['pvp_test.decor','pvpshot.point','pvpshot.machine','pvpshot.chest']],
        'function pvp_test:build_core',
        'scoreboard players set Red pvpshot.score 0','scoreboard players set Blue pvpshot.score 0',
        'scoreboard players set #point.clock pvpshot.cal 0',
        'effect clear @a', 'effect give @a minecraft:fire_resistance 8 0 true',
        'execute as @a run function pvp_test:kit',
        'effect give @a minecraft:resistance 2 4 true',
        'tellraw @a {text:"核心作战区已恢复，比分归零，双方回到基地并补齐装备。大厅及基地建筑保留。",color:"gold"}'])
    function('request_reset',[
        'scoreboard players set @s pvp_reset 0',
        'execute if score #reset.wait pvp_test.init matches 1.. run return run tellraw @s {text:"重置冷却中，请稍后重试。",color:"yellow"}',
        'function pvp_test:reset_core'])
    # Upgrade an already-open test world without rebuilding its terrain on /reload.
    controls=[]
    start=len(lines)
    button(16,-46,'重置核心区','request_reset','gold')
    controls.extend(lines[start:])
    controls.insert(0,'kill @e[type=minecraft:text_display,tag=pvp_test.decor,x=16.5,y=68.1,z=-45.3,distance=..0.2]')
    controls.append('kill @e[type=minecraft:text_display,tag=pvp_test.decor,x=18,y=68,z=-39,distance=..0.2]')
    start=len(lines)
    label(18,68,-39,'20 HP = 10 颗心 · 开启友伤\n雪球 16 发＋无限备弹 / 手雷＋铁镐\n脱战 5 秒快速回血 · TNT 原版结算','white',.85)
    controls.extend(lines[start:])
    function('patch_controls',controls)


def package_world(source, output):
    target = output / FOLDER
    if target.exists():
        raise RuntimeError(f'Refusing to replace an existing output save: {target}')
    shutil.copytree(source,target)
    shutil.rmtree(target / 'players', ignore_errors=True)
    shutil.rmtree(target / 'datapacks/worldbuild', ignore_errors=True)
    (target / 'session.lock').unlink(missing_ok=True)
    (target / 'level.dat_old').unlink(missing_ok=True)
    # Remove the remote GameTest laboratory regions; keep the four regions covering the map.
    for path in (target / 'dimensions').rglob('*.mca'):
        match = re.fullmatch(r'r\.(-?\d+)\.(-?\d+)\.mca',path.name)
        if match and (int(match[1]) not in [-1,0] or int(match[2]) not in [-1,0]):
            path.unlink()
    root = read(target / 'level.dat')
    data = root[1][1]['Data'][1]
    data['LevelName'] = (8,TITLE)
    data['GameType'] = (3,0)
    data['LastPlayed'] = (4,int(time.time()*1000))
    data['allowCommands'] = (1,1)
    data['enabled_features'] = (9,(8,['minecraft:vanilla']))
    data['DataPacks'] = (10,{'Enabled':(9,(8,['vanilla','file/pvpshot','file/pvp_test'])), 'Disabled':(9,(8,[]))})
    data['spawn'] = (10,{'pos':(11,[0,65,-42]),'pitch':(5,0.),'yaw':(5,0.),'dimension':(8,'minecraft:overworld')})
    data.pop('singleplayer_uuid',None)
    write(target / 'level.dat',root)
    # No saved scheduled test events or fake-player data are part of the released world.
    for filename in ['scheduled_events.dat','stopwatches.dat','scoreboard.dat']:
        (target / 'data/minecraft' / filename).unlink(missing_ok=True)
    # Both packs initialize their own objectives on load. Do not ship mock-player names or UUIDs.
    (target / 'data/pvpshot/command_storage.dat').unlink(missing_ok=True)
    return target


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--java-home',type=Path,required=True)
    parser.add_argument('--server-jar',type=Path,required=True)
    parser.add_argument('--work-dir',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    args = parser.parse_args()
    work=args.work_dir.resolve(); work.mkdir(parents=True,exist_ok=True)
    if (args.output / FOLDER).exists():
        raise RuntimeError('Output world already exists; choose a fresh output directory.')
    jars=[]
    with zipfile.ZipFile(args.server_jar) as archive:
        for name in archive.namelist():
            if name.endswith('.jar') and name.startswith(('META-INF/versions/','META-INF/libraries/')):
                path=work / 'jars' / name
                path.parent.mkdir(parents=True,exist_ok=True)
                if not path.exists(): path.write_bytes(archive.read(name))
                jars.append(str(path))
    cp=':'.join(jars)
    classes=work/'classes'; classes.mkdir(exist_ok=True)
    subprocess.run([str(args.java_home/'bin/javac'),'-encoding','UTF-8','-cp',cp,'-d',str(classes),
                    str(ROOT/'tools/test_world/BuildWorld.java')],check=True)
    packs=work/'packs'; packs.mkdir(exist_ok=True)
    for name in ['pvpshot','pvp_test','worldbuild']:
        if (packs/name).exists(): shutil.rmtree(packs/name)
    shutil.copytree(ROOT/'pvpshot',packs/'pvpshot')
    make_pack(packs/'pvp_test')
    buildpack=packs/'worldbuild'
    save_json(buildpack/'pack.mcmeta',{'pack':{'description':'Offline map builder','min_format':[107,1],'max_format':107}})
    spec=importlib.util.spec_from_file_location('structures',ROOT/'tools/build_structures.py')
    builder=importlib.util.module_from_spec(spec);spec.loader.exec_module(builder)
    builder.ROOT=buildpack/'data/worldbuild'
    (builder.ROOT/'structure').mkdir(parents=True,exist_ok=True)
    builder.write_structure('empty',[1,1,1],{(0,0,0):('smooth_stone',{})})
    save_json(builder.ROOT/'test_instance/arena.json',{'type':'minecraft:function','environment':'minecraft:default',
        'structure':'worldbuild:empty','function':'worldbuild:arena','max_ticks':200,'sky_access':True})
    command=[str(args.java_home/'bin/java'),'-Xms256M','-Xmx1G','-cp',str(classes)+':'+cp,
        'BuildWorld','--packs',str(packs),'--tests','worldbuild:*','--universe',str(work/'generated-world'),
        '--report',str(work/'report.xml')]
    print('Building and checking the playable world...',flush=True)
    with (work/'build.log').open('w') as log:
        result=subprocess.run(command,cwd=work,stdout=log,stderr=subprocess.STDOUT,timeout=180)
    log=(work/'build.log').read_text()
    print(log)
    if result.returncode or re.search(r'Couldn.t parse|Failed to load|/ERROR\]|Serialization errors',log):
        raise SystemExit('World generation or validation failed; nothing packaged.')
    args.output.mkdir(parents=True,exist_ok=True)
    target=package_world(work/'generated-world/gametestworld',args.output)
    shutil.copy2(work/'build.log',args.output/'场地构建验证.log')
    print('Playable world:',target)


if __name__=='__main__':
    main()
