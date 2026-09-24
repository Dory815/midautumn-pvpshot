from pathlib import Path
import sys,zlib,re,json
from PIL import Image
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools/test_world'));from nbt import Reader
root=Path(sys.argv[5])/'dimensions/minecraft/overworld/region';out=Path(sys.argv[6]);out.mkdir(parents=True,exist_ok=True)
colors={}
for line in (Path(__file__).with_name('block_colors.txt')).read_text().splitlines():
 m=re.search(r'BLOCK minecraft:(\S+) (\d+)',line)
 if m:
  v=int(m[2]);colors[m[1]]=((v>>16)&255,(v>>8)&255,v&255)
xmin,zmin,xmax,zmax=map(int,sys.argv[1:5]);w,h=xmax-xmin+1,zmax-zmin+1
image=Image.new('RGB',(w,h),(42,48,50));pixels=image.load();heights=Image.new('I',(w,h),-64);hp=heights.load();signs=[];counts={};built=[]
for rx in range(xmin//512,xmax//512+1):
 for rz in range(zmin//512,zmax//512+1):
  path=root/f'r.{rx}.{rz}.mca'
  if not path.exists():continue
  raw=path.read_bytes()
  for i in range(1024):
   loc=int.from_bytes(raw[4*i:4*i+4],'big')
   if not loc:continue
   ox,oz=(rx*32+i%32)*16,(rz*32+i//32)*16
   if ox>xmax or oz>zmax or ox+15<xmin or oz+15<zmin:continue
   off=(loc>>8)*4096;size=int.from_bytes(raw[off:off+4],'big');r=Reader(zlib.decompress(raw[off+5:off+4+size]));r.number('b');r.string();c=r.payload(10)
   sections={}
   for s in c.get('sections',(9,(10,[])))[1][1]:
    if 'block_states' not in s:continue
    bs=s['block_states'][1];pal=[p['Name'][1].removeprefix('minecraft:') for p in bs['palette'][1][1]];bits=max(4,(len(pal)-1).bit_length());sections[s['Y'][1]]=(pal,bs.get('data',(12,[]))[1],bits)
   hm=c.get('Heightmaps',(10,{}))[1].get('WORLD_SURFACE',(12,[]))[1]
   if not hm:continue
   cy=c.get('yPos',(3,-4))[1]*16
   nbuild=0
   for lz in range(16):
    for lx in range(16):
     x,z=ox+lx,oz+lz
     if not(xmin<=x<=xmax and zmin<=z<=zmax):continue
     ind=lz*16+lx;y=((hm[ind//7]>>((ind%7)*9))&511)+cy-1
     if y//16 not in sections:continue
     pal,arr,bits=sections[y//16];ind=(y%16)*256+lz*16+lx
     name=pal[0 if not arr else (arr[ind//(64//bits)]>>((ind%(64//bits))*bits))&((1<<bits)-1)]
     color=colors.get(name,(180,180,180))
     if name=='water':color=(65,115,155)
     if 'leaves' in name:color=(75,125,60)
     pixels[x-xmin,z-zmin]=color;hp[x-xmin,z-zmin]=y;counts[name]=counts.get(name,0)+1
     if y>10:nbuild+=1
   if nbuild>10:built.append([ox,oz,nbuild])
   for e in c.get('block_entities',(9,(10,[])))[1][1]:
    if e.get('id',(8,''))[1].endswith('sign'):
     signs.append({k:v[1] for k,v in e.items() if k in ['x','y','z','front_text','back_text','Text1','Text2','Text3','Text4']})
  print('rendered',path.name,flush=True)
image.save(out/'top.png');heights.save(out/'height.tiff')
(out/'meta.json').write_text(json.dumps({'bounds':[xmin,zmin,xmax,zmax],'blocks':counts,'signs':signs,'built':built},ensure_ascii=False,default=str))
print('complete',w,h,'signs',len(signs),flush=True)
