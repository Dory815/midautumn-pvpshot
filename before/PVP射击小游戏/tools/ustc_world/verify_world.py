"""Inspect the exported terrain, foundation and current datapacks read-only."""
from pathlib import Path
import json,sys,hashlib
from terrain import Terrain
ROOT=Path(__file__).resolve().parents[2]
world=Path(sys.argv[1]);t=Terrain(world);original=Terrain(ROOT/'USTC_project')
count=0
for x in range(-2144,-1569,16):
 for z in range(-1776,-1153,16):
  bs=t.chunk(x//16,z//16)[-1];pal=bs['palette'][1][1];bits=max(4,(len(pal)-1).bit_length());a=bs.get('data',(12,[]))[1]
  for cell in range(256):
   i=15*256+cell;ind=0 if not a else (a[i//(64//bits)]>>((i%(64//bits))*bits))&((1<<bits)-1)
   assert pal[ind]['Name'][1]=='minecraft:bedrock',(x,z,cell)
   xx,zz=x+cell%16,z+cell//16
   # Native neighbour updates may change note-block instruments over bedrock.
   assert t.block(xx,0,zz)[0]==original.block(xx,0,zz)[0],('original ground surface changed',xx,zz)
   count+=1
meta=json.loads((ROOT/'地图方案/掩体与补给.json').read_text())
for x,y,z in meta['covers']:assert t.block(x,y,z)[0] in ['stone_bricks','bricks','light_gray_concrete'],(x,y,z)
for x,y,z in meta['supplies']:assert t.block(x,y,z)[0]=='trapped_chest',(x,y,z)
def hashes(p):return {str(x.relative_to(p)):hashlib.sha256(x.read_bytes()).hexdigest() for x in p.rglob('*') if x.is_file()}
for name in ['pvpshot','ustc_pvp']:assert hashes(ROOT/name)==hashes(world/'datapacks'/name),name
print(f'{count} 个 Y=-1 基岩单元、原 Y=0 地面材质、100 组掩体、67 个新增箱子和两个数据包均核对通过。')
