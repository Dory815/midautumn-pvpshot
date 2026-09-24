#!/usr/bin/env python3
"""Inspect the saved Anvil chunks and draw a top-down map from actual block data."""
import argparse
from collections import deque
from pathlib import Path
import struct
import zlib

from nbt import Reader, read


def chunks(folder):
    for path in folder.glob('*.mca'):
        data = path.read_bytes()
        for i in range(1024):
            location = int.from_bytes(data[4*i:4*i+4], 'big')
            if not location:
                continue
            offset = (location >> 8) * 4096
            size = int.from_bytes(data[offset:offset+4], 'big')
            assert data[offset+4] == 2, 'Expected vanilla zlib chunk compression'
            r = Reader(zlib.decompress(data[offset+5:offset+4+size]))
            assert r.number('b') == 10
            r.string()
            yield r.payload(10)


def load_blocks(world):
    result = {}
    for chunk in chunks(world/'dimensions/minecraft/overworld/region'):
        cx,cz = chunk['xPos'][1],chunk['zPos'][1]
        if not (-4 <= cx <= 3 and -3 <= cz <= 3):
            continue
        for section in chunk['sections'][1][1]:
            sy = section['Y'][1]
            if sy not in (4,5):
                continue
            state = section['block_states'][1]
            palette = [p['Name'][1].removeprefix('minecraft:') for p in state['palette'][1][1]]
            bits = max(4,(len(palette)-1).bit_length())
            per_long = 64//bits
            longs = state.get('data',(12,[]))[1]
            for y in range(16):
                if sy*16+y > 80:
                    break
                for z in range(16):
                    for x in range(16):
                        index=y*256+z*16+x
                        p=0 if not longs else (longs[index//per_long] >> (index%per_long*bits)) & ((1<<bits)-1)
                        result[cx*16+x,sy*16+y,cz*16+z]=palette[p]
    return result


def verify(world,blocks):
    level=read(world/'level.dat')[1][1]['Data'][1]
    assert level['DataVersion'][1] == 4903
    assert level['spawn'][1]['pos'][1] == [0,65,-42]
    assert level['DataPacks'][1]['Enabled'][1][1] == ['vanilla','file/pvpshot','file/pvp_test']
    assert not (world/'players').exists()
    entities=[]
    for chunk in chunks(world/'dimensions/minecraft/overworld/entities'):
        entities.extend(chunk.get('Entities',(9,(10,[])))[1][1])
    tags=[e.get('Tags',(9,(8,[])))[1][1] for e in entities]
    for name,count in [('pvpshot.arena',1),('pvpshot.point',3),('pvpshot.spawn.red',1),('pvpshot.spawn.blue',1)]:
        assert sum(name in t for t in tags)==count,(name,tags)
    assert sum(e.get('id',(8,''))[1]=='minecraft:text_display' for e in entities)>=20
    floor={(x,z) for x in range(-55,56) for z in range(-47,48)
           if blocks.get((x,64,z),'air')!='air' and
           blocks.get((x,65,z),'air')=='air' and blocks.get((x,66,z),'air')=='air'}
    pending=deque([(0,-42)]); reachable={(0,-42)}
    while pending:
        x,z=pending.popleft()
        for p in [(x-1,z),(x+1,z),(x,z-1),(x,z+1)]:
            if p in floor and p not in reachable:
                reachable.add(p);pending.append(p)
    for p in [(-47,0),(47,0),(0,-24),(0,0),(0,24),(-30,-24),(30,-24),(-30,24),(30,24),(-40,42),(40,42)]:
        assert p in reachable, f'Unreachable map destination: {p}'
    print('PASS saved 26.2 metadata, enabled datapacks, clean player state, all markers and labels')
    print('PASS walking routes connect lobby, both bases, all three points, four pads and firing range')


def draw(blocks,path):
    from PIL import Image, ImageDraw, ImageFont
    colors={'smooth_stone':'#adb7bd','polished_andesite':'#7f8d99','light_gray_concrete':'#919da8',
        'deepslate_bricks':'#344258','polished_deepslate':'#253349','stone_bricks':'#5c6e81',
        'smooth_stone_slab':'#758799','tinted_glass':'#465571','bricks':'#876357',
        'red_terracotta':'#ae4c4e','blue_terracotta':'#416ea3','red_concrete':'#ed5959',
        'blue_concrete':'#4e9ce9','orange_terracotta':'#b89252','gold_block':'#ffe174',
        'glass':'#b8e5f1','white_wool':'#eff2f0','white_concrete':'#d4e0e5','sea_lantern':'#b4eeeb',
        'chest':'#d3aa65','trapped_chest':'#e4b272','command_block':'#dbb779','stone_button':'#8995a4'}
    scale=8;left,top=48,130
    image=Image.new('RGB',(1000,990),'#121d30');d=ImageDraw.Draw(image)
    font_path='/System/Library/Fonts/PingFang.ttc'
    if not Path(font_path).exists():
        font_path='/System/Library/Fonts/STHeiti Medium.ttc'
    font=lambda s:ImageFont.truetype(font_path,s)
    d.text((48,28),'交火试验场',fill='#eaf3ff',font=font(34))
    d.text((49,78),'113 × 97 格  ·  红蓝对称基地  ·  三点占领  ·  部署试射走廊',fill='#a7b9d0',font=font(17))
    for z in range(-48,49):
        for x in range(-56,57):
            name='air';height=64
            for y in range(79,63,-1):
                v=blocks.get((x,y,z),'air')
                if v not in ('air','stone_button'):
                    name=v;height=y;break
            px,py=left+(x+56)*scale,top+(z+48)*scale
            color=colors.get(name,'#acb8c5')
            d.rectangle((px,py,px+scale-1,py+scale-1),fill=color)
            if height>64 and name!='tinted_glass':
                d.line((px,py+scale-1,px+scale-1,py+scale-1),fill='#263750')
    def label(x,z,text):
        px,py=left+(x+56.5)*scale,top+(z+48.5)*scale
        ft=font(16);bbox=d.textbbox((0,0),text,font=ft);w=bbox[2];h=bbox[3]-bbox[1]
        d.rounded_rectangle((px-w/2-7,py-h/2-6,px+w/2+7,py+h/2+7),radius=5,fill='#132037')
        d.text((px-w/2,py-h/2-bbox[1]),text,font=ft,fill='#f0f5fd')
    for x,z,text in [(0,-42,'出生大厅 / 控制按钮'),(-47,0,'红队'),(47,0,'蓝队'),
        (0,-24,'A'),(0,0,'B'),(0,24,'C'),(-30,-24,'部署区'),(30,-24,'部署区'),
        (-30,24,'部署区'),(30,24,'部署区'),(0,42,'部署试射走廊')]:
        label(x,z,text)
    d.text((48,928),'地图由存档实际方块数据绘制；北在上方。',font=font(17),fill='#a7b9d0')
    d.text((48,953),'右键使用红色 / 橙色染料部署；大厅可补装备、切换模式和重置场地。',font=font(16),fill='#a7b9d0')
    image.save(path)


if __name__=='__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument('world',type=Path)
    parser.add_argument('--map',type=Path)
    args=parser.parse_args()
    blocks=load_blocks(args.world)
    verify(args.world,blocks)
    if args.map:
        draw(blocks,args.map)
