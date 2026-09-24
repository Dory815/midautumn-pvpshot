"""Select added cover on existing clear floor; never cut original roads or walls."""
from pathlib import Path
import json
from terrain import Terrain
ROOT=Path(__file__).resolve().parents[2]
t=Terrain(ROOT/'USTC_project')
fixed=[(-2110,-1490),(-1590,-1525),(-2035,-1545),(-1857,-1541),(-1676,-1535),(-1676,-1660),(-2080,-1378)]
old=[(-1930,-1310),(-1865,-1300),(-1790,-1300),(-1760,-1260),(-1760,-1190),(-1835,-1180),(-1910,-1190),(-1955,-1260),(-2015,-1510),(-1835,-1515),(-1655,-1510),(-1660,-1680),(-2060,-1380)]
def clear(x,z,rx=3,rz=2):
 for dx in range(-rx,rx+1):
  for dz in range(-rz,rz+1):
   if t.block(x+dx,1,z+dz)[0] in ['air','water','lava']:return False
   for y in range(2,5):
    if t.block(x+dx,y,z+dz)[0] not in ['air','short_grass','tall_grass']:return False
 return True
covers=[]
for zi,z in enumerate(range(-1738,-1180,28)):
 for x in range(-2120+(zi%2)*14,-1599,28):
  if any((x-a)**2+(z-b)**2<18**2 for a,b in fixed):continue
  if any(abs(x-a)<7 and abs(z-b)<7 for a,b in old):continue
  if clear(x,z):covers.append([x,2,z])
# Retain the original stops, then fill gaps toward 80 total supply boxes.
extra=[]
for i,(x,y,z) in enumerate(covers):
 if i%3!=0:continue
 for dx,dz in [(0,5),(5,0),(0,-5),(-5,0)]:
  a,b=x+dx,z+dz
  if clear(a,b,1,1) and all((a-c)**2+(b-d)**2>18**2 for c,d in old+[(q[0],q[2]) for q in extra]):
   extra.append([a,2,b]);break
 if len(extra)>=35:break
for x,y,z in covers:
 if len(extra)>=67:break
 for dx,dz in [(0,5),(5,0),(0,-5),(-5,0)]:
  a,b=x+dx,z+dz
  if clear(a,b,1,1) and all((a-c)**2+(b-d)**2>18**2 for c,d in old+[(q[0],q[2]) for q in extra]):
   extra.append([a,2,b]);break
assert len(extra)==67, len(extra)
out={'covers':covers,'supplies':extra,'source':'USTC_project read-only geometry; new cover only in clear floor volumes'}
(ROOT/'地图方案/掩体与补给.json').write_text(json.dumps(out,ensure_ascii=False,indent=2)+'\n');print('cover groups',len(covers),'new supply boxes',len(extra))
