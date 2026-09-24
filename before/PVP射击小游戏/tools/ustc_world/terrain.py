"""Read-only Anvil inspection for campus routing and placement checks."""
from pathlib import Path
from functools import lru_cache
from collections import deque
import sys,zlib,json
import numpy as np
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'test_world'))
from nbt import Reader
ROOT=Path(__file__).resolve().parents[2]
class Terrain:
 def __init__(self,world): self.folder=Path(world)/'dimensions/minecraft/overworld/region'
 @lru_cache(maxsize=8)
 def region(self,rx,rz): return (self.folder/f'r.{rx}.{rz}.mca').read_bytes()
 @lru_cache(maxsize=32)
 def chunk(self,cx,cz):
  raw=self.region(cx//32,cz//32);i=(cz%32)*32+cx%32;loc=int.from_bytes(raw[i*4:i*4+4],'big')
  if not loc:return {}
  off=(loc>>8)*4096;n=int.from_bytes(raw[off:off+4],'big');assert raw[off+4]==2
  r=Reader(zlib.decompress(raw[off+5:off+4+n]));r.number('b');r.string();c=r.payload(10)
  return {s['Y'][1]:s['block_states'][1] for s in c['sections'][1][1] if 'block_states' in s}
 def block(self,x,y,z):
  bs=self.chunk(x//16,z//16).get(y//16)
  if not bs:return 'air',{}
  pal=bs['palette'][1][1];bits=max(4,(len(pal)-1).bit_length());a=bs.get('data',(12,[]))[1];i=(y%16)*256+(z%16)*16+x%16
  p=pal[0 if not a else (a[i//(64//bits)]>>((i%(64//bits))*bits))&((1<<bits)-1)]
  return p['Name'][1].removeprefix('minecraft:'),{k:v[1] for k,v in p.get('Properties',(10,{}))[1].items()}
 def describe(self,x,z,ys=range(0,9)):return [(y,*self.block(x,y,z)) for y in ys]
 def walkgrid(self,bounds):
  x0,z0,x1,z1=bounds;grid=np.zeros((z1-z0+1,x1-x0+1),np.uint8)
  # Conservative ground-floor routing: 2-block clearance; doors may be opened.
  transparent={'air','cave_air','void_air','short_grass','tall_grass','fern','large_fern','dead_bush','torch','wall_torch','redstone_wire','tripwire','string','light'}
  def passable(n):return n in transparent or n.endswith(('_door','_sign','_wall_sign','_button','_pressure_plate','_banner','_wall_banner','_carpet')) or n=='vine'
  for cz in range(z0//16,z1//16+1):
   for cx in range(x0//16,x1//16+1):
    bs=self.chunk(cx,cz).get(0)
    if not bs:continue
    pal=bs['palette'][1][1];bits=max(4,(len(pal)-1).bit_length());a=bs.get('data',(12,[]))[1]
    idx=np.arange(16*256,dtype=np.uint64)
    ids=np.zeros((16,16,16),np.uint16) if not a else ((np.array([v&((1<<64)-1) for v in a],dtype=np.uint64)[idx//(64//bits)]>>((idx%(64//bits))*bits))&((1<<bits)-1)).astype(np.uint16).reshape(16,16,16)
    names=[p['Name'][1].removeprefix('minecraft:') for p in pal];pa=np.array([passable(n) for n in names]);support=np.array([not passable(n) and n not in ['water','lava'] for n in names])
    openfeet=np.zeros((16,16),np.uint8)
    for feet in range(1,5):
     ok=pa[ids[feet]]&pa[ids[feet+1]]&support[ids[feet-1]]
     openfeet=np.where((openfeet==0)&ok,feet,openfeet)
    lx,lz=max(x0,cx*16),max(z0,cz*16);hx,hz=min(x1,cx*16+15),min(z1,cz*16+15)
    grid[lz-z0:hz-z0+1,lx-x0:hx-x0+1]=openfeet[lz-cz*16:hz-cz*16+1,lx-cx*16:hx-cx*16+1]
  return grid

def routes(world,out):
 bounds=(-2150,-1790,-1570,-1170);t=Terrain(world);g=t.walkgrid(bounds);x0,z0,_,_=bounds
 from make_pack import POINTS,BASES,GYM
 points={**{k.title():(x,z) for k,(x,y,z) in BASES.items()},**{k:(x,z) for k,(x,y,z,label) in POINTS.items()},'Gym':(-1930,-1313)}
 def nearest(x,z):
  vals=[(a*a+b*b,x+a,z+b) for a in range(-12,13) for b in range(-12,13) if 0<=z+b-z0<g.shape[0] and 0<=x+a-x0<g.shape[1] and g[z+b-z0,x+a-x0]]
  _,x,z=min(vals);return x,z
 points={k:nearest(*p) for k,p in points.items()};result={}
 for name,(x,z) in points.items():
  start=(z-z0,x-x0);dist=np.full(g.shape,-1,np.int32);dist[start]=0;q=deque([start])
  while q:
   a,b=q.popleft()
   for aa,bb in [(a-1,b),(a+1,b),(a,b-1),(a,b+1)]:
    if 0<=aa<g.shape[0] and 0<=bb<g.shape[1] and g[aa,bb] and dist[aa,bb]<0 and abs(int(g[aa,bb])-int(g[a,b]))<=1:
     dist[aa,bb]=dist[a,b]+1;q.append((aa,bb))
  result[name]={k:int(dist[zz-z0,xx-x0]) for k,(xx,zz) in points.items()}
 out.mkdir(parents=True,exist_ok=True);np.save(out/'walkgrid.npy',g);(out/'routes.json').write_text(json.dumps({'bounds':bounds,'points':points,'distances':result,'method':'Ground-floor cardinal BFS, doors assumed open, full blocks conservatively occupied; not live-client travel.'},ensure_ascii=False,indent=2));print(json.dumps(result,ensure_ascii=False,indent=2))
if __name__=='__main__':routes(Path(sys.argv[1]) if len(sys.argv)>1 else ROOT/'USTC_project',ROOT/'地图方案')
