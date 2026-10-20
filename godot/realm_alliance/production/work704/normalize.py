from pathlib import Path
from PIL import Image
from scipy import ndimage
import numpy as np,io,json,hashlib
ROOT=Path(__file__).resolve().parents[2];SOURCE=Path(__file__).parent/'sources';OUT=ROOT/'assets/work704'
def save(im,p):
 p.parent.mkdir(parents=True,exist_ok=True);buffer=io.BytesIO();im.save(buffer,format='PNG',optimize=True);payload=buffer.getvalue();p.write_bytes(payload);assert hashlib.sha256(p.read_bytes()).digest()==hashlib.sha256(payload).digest()
def bodies(im,count,columns):
 pixels=np.array(im);labels,n=ndimage.label(pixels[:,:,3]>35);counts=np.bincount(labels.ravel());counts[0]=0;objects=ndimage.find_objects(labels);ids=sorted(np.argsort(counts)[-count:],key=lambda k:objects[k-1][0].start);ordered=[]
 for row in range(count//columns):ordered+=sorted(ids[row*columns:(row+1)*columns],key=lambda k:objects[k-1][1].start)
 result=[]
 for k in ordered:
  sy,sx=objects[k-1];patch=pixels[sy.start:sy.stop,sx.start:sx.stop].copy();mask=ndimage.binary_dilation(labels==k,iterations=3);patch[:,:,3][~mask[sy.start:sy.stop,sx.start:sx.stop]]=0
  result.append((Image.fromarray(patch),[sx.start,sy.start,sx.stop,sy.stop]))
 return result
manifest={'schema':1,'golem':{}}
im=Image.open(SOURCE/'golem.png').convert('RGBA');parts=bodies(im,6,3);factor=610/parts[0][0].height
for name,(crop,box) in zip(['idle','breathe','windup','attack','hit','defeated'],parts):
 crop=crop.resize((round(crop.width*factor),round(crop.height*factor)),Image.Resampling.LANCZOS);assert crop.width<896 and crop.height<736;canvas=Image.new('RGBA',(896,768));position=(448-crop.width//2,736-crop.height);canvas.alpha_composite(crop,position);save(canvas,OUT/'golem'/(name+'.png'));manifest['golem'][name]={'source_rect':box,'position':position,'scale':factor}
p=SOURCE/'icons.png'
if p.exists():
 im=Image.open(p).convert('RGBA')
 for i,name in enumerate(['shop','quests','events','achievements','dungeons','journey']):
  cell=im.crop((i%2*512,i//2*512,i%2*512+512,i//2*512+512));box=cell.getchannel('A').point(lambda a:255 if a>35 else 0).getbbox();cell=cell.crop(box);cell.thumbnail((232,232),Image.Resampling.LANCZOS);canvas=Image.new('RGBA',(256,256));canvas.alpha_composite(cell,((256-cell.width)//2,(256-cell.height)//2));save(canvas,OUT/'ui'/(name+'.png'))
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2))
print('Normalized',len(list(OUT.rglob('*.png'))),'assets')

p=SOURCE/'armor.png'
if p.exists():
 im=Image.open(p).convert('RGBA');parts=bodies(im,6,2);factor=388/parts[0][0].height
 hands=[(420,315),(954,274),(310,544),(984,752),(443,1354),(921,1263)]
 heads=[(363,132),(862,196),(366,652),(866,687),(373,1166),(814,1110)]
 chests=[(355,247),(826,313),(355,769),(816,806),(330,1290),(834,1230)]
 meta={}
 for i,(name,(crop,box)) in enumerate(zip(['idle','ready','windup','attack_contact','recovery','hit'],parts)):
  crop=crop.resize((round(crop.width*factor),round(crop.height*factor)),Image.Resampling.LANCZOS);assert crop.width<620 and crop.height<480,(name,crop.size);canvas=Image.new('RGBA',(640,512));position=(320-crop.width//2,488-crop.height);canvas.alpha_composite(crop,position);save(canvas,OUT/'guardian_astral'/(name+'.png'))
  convert=lambda point:[round(position[0]+(point[0]-box[0])*factor,2),round(position[1]+(point[1]-box[1])*factor,2)]
  meta[name]={'source_rect':box,'position':position,'hand':convert(hands[i]),'head':convert(heads[i]),'chest':convert(chests[i])}
 (OUT/'armor_sockets.json').write_text(json.dumps(meta,indent=2))
