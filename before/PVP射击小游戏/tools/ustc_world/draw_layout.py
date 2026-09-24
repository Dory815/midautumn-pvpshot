from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import sys
ROOT=Path(__file__).resolve().parents[2]
from make_pack import POINTS,BASES,GYM,SUPPLIES,COVERS,ADVANCED
base=Image.open(sys.argv[1])
out=ROOT/'地图方案'
fontfile='/System/Library/Fonts/PingFang.ttc'
font=lambda n:ImageFont.truetype(fontfile,n)
background='#101925';white='#ecf2f7';muted='#afbdcc';gold='#ffdc77'
W,H=1510,1140;im=Image.new('RGB',(W,H),background);d=ImageDraw.Draw(im)
d.text((42,26),'科大中区 · 三点 / 五点部署图',font=font(32),fill=white)
d.text((44,75),'基于测试存档实际方块；北在上方。金圈为据点，绿色为奖励箱，紫色为独立高级箱，米色为掩体。',font=font(19),fill=muted)
x0,z0,x1,z1=-2180,-1800,-1560,-1170
mapw,maph=682,693
points={k:(x,z,label) for k,(x,y,z,label) in POINTS.items()}
for left,title,active in [(44,'三点版 · A / B / C','ABC'),(785,'五点版 · A / B / C / D / E','ABCDE')]:
 top=173;d.text((left,122),title,font=font(24),fill=white)
 tile=base.crop((x0+2560,z0+2048,x1+2560,z1+2048)).resize((mapw,maph),Image.Resampling.NEAREST)
 im.paste(tile,(left,top));d.rectangle((left,top,left+mapw,top+maph),outline='#66778a',width=2)
 def pos(x,z):return left+(x-x0)/(x1-x0)*mapw,top+(z-z0)/(z1-z0)*maph
 # Candidate bases are tentative and not walked or balanced yet.
 for x,z,label,color in [(-2110,-1490,'红方基地','#ff6b70'),(-1590,-1525,'蓝方基地','#6bb6ff')]:
  px,py=pos(x,z);d.rectangle((px-8,py-8,px+8,py+8),fill=color,outline=white,width=2)
  tx=px-14 if label.startswith('红') else px-146
  ty=py+(15 if label.startswith('红') else 66)
  d.rounded_rectangle((tx-4,ty,tx+148,ty+27),radius=4,fill=background)
  d.text((tx,ty+1),label,font=font(17),fill=color)
 for x,y,z in COVERS:
  px,py=pos(x,z);d.rectangle((px-2,py-2,px+2,py+2),fill='#e6cfac')
 for x,y,z in GYM+SUPPLIES:
  px,py=pos(x,z);d.rectangle((px-4,py-4,px+4,py+4),fill='#66ff9c',outline=background,width=1)
 for i,(x,y,z,label) in enumerate(ADVANCED):
  px,py=pos(x,z);d.rectangle((px-7,py-7,px+7,py+7),fill='#cd8bff',outline=white,width=2)
  d.text((px+10,py-14),'R'+str(i+1),font=font(19),fill='#f3d7ff')
 for key in active:
  x,z,label=points[key];label='球场西北侧' if key=='E' else label;px,py=pos(x,z)
  d.ellipse((px-24,py-24,px+24,py+24),outline=gold,width=3)
  d.ellipse((px-15,py-15,px+15,py+15),fill=background,outline=gold,width=1)
  bb=d.textbbox((0,0),key,font=font(22));d.text((px-(bb[2]-bb[0])/2,py-17),key,font=font(22),fill=gold)
  tx=px-44;ty=py+30;d.rounded_rectangle((tx-5,ty-2,tx+93,ty+26),radius=4,fill=background)
  d.text((tx,ty),label,font=font(17),fill=gold)
 d.text((left+14,top+13),'N ↑',font=font(19),fill=white)
 a,b=pos(x0+25,z1-25),pos(x0+125,z1-25);d.line((a,b),fill=white,width=4)
 d.text((a[0],a[1]-26),'100 格',font=font(17),fill=white)
 text=['建筑间穿插：两侧据点 + 中间主争夺点。','目标 600 分；A/C 楼顶点，设弹射器与水池。'] if active=='ABC' else ['保留三点骨架，增加北、南两翼的转点路线。','目标 1000 分；80 普通箱 + 2 独立高级箱。']
 for j,t in enumerate(text):d.text((left,890+j*32),t,font=font(19),fill=muted)
d.line((44,985,W-44,985),fill='#33455a',width=2)
d.text((44,1004),'默认五点；大厅可切三点 / 五点 / 团队死斗。比分与归属在屏幕顶部。',font=font(21),fill=white)
d.text((44,1041),'保留道路与围栏，使用爆炸、镐子和队色陶瓦开路；重置战场可恢复原校园。',font=font(19),fill=muted)
d.text((44,1077),'地图范围：X -2180…-1560，Z -1800…-1170。第八轮布局；高级箱到双方基地距离差小于 1 格。',font=font(17),fill=muted)
im.save(out/'科大中区-部署图.png')
