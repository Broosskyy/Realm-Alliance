"""Mechanical extraction and rig placement of imagegen alpha cutouts; no repainting."""
from pathlib import Path
from PIL import Image
import hashlib,json
ROOT=Path(__file__).resolve().parents[2]
INPUT=Path(__file__).resolve().parent
MANIFEST={'schema':1,'provider':'built-in imagegen','date':'2026-10-19','policy':'Original RGBA retained; mechanical crop/resample/rig placement only. No recoloring or generated replacement by code.','assets':{}}
SOURCES={id:id+'/source.png' for id in ['stone_sentry','cinder_colossus','schattenjager']}
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def cut_alpha(im,rect):
 cell=im.crop(rect);bbox=cell.getchannel('A').point(lambda a:255 if a>12 else 0).getbbox()
 assert bbox
 bbox=(max(0,bbox[0]-3),max(0,bbox[1]-3),min(cell.width,bbox[2]+3),min(cell.height,bbox[3]+3))
 return cell.crop(bbox),bbox
for id in ['stone_sentry','cinder_colossus']:
 src=INPUT/SOURCES[id];im=Image.open(src).convert('RGBA');out=ROOT/'assets/expansion702'/id;out.mkdir(parents=True,exist_ok=True)
 prod=ROOT/'production/polish702'/id;prod.mkdir(parents=True,exist_ok=True)
 data={'source_sha256':sha(src),'canvas':[736,736],'ground':[368,704],'poses':{}}
 packed=Image.new('RGBA',(1792,1792))
 for i,pose in enumerate(['idle','attack','hit','defeated']):
  rect=((i%2)*768,(i//2)*512,(i%2+1)*768,(i//2+1)*512);cut,bbox=cut_alpha(im,rect);scale=.92
  size=(round(cut.width*scale),round(cut.height*scale));sprite=cut.resize(size,Image.Resampling.LANCZOS)
  x=round(368+(bbox[0]-384)*scale);y=704-size[1]
  assert x>=0 and x+size[0]<736 and y>=0,(id,pose,x,size)
  canvas=Image.new('RGBA',(736,736));canvas.alpha_composite(sprite,(x,y));dest=out/(pose+'.png');canvas.save(dest)
  packed.alpha_composite(canvas,((i%2)*896+80,(i//2)*896+80))
  data['poses'][pose]={'cell':rect,'crop':bbox,'scale':scale,'offset':[x,y],'sha256':sha(dest)}
 packed.save(prod/'production_sheet.png');MANIFEST['assets'][id]=data
# Source rows are intentionally separated at the actual transparent gutters,
# rather than cutting through feet on an assumed equal-height grid.
id='schattenjager';src=INPUT/SOURCES[id];im=Image.open(src).convert('RGBA');out=ROOT/'assets/expansion702'/id;out.mkdir(parents=True,exist_ok=True);prod=ROOT/'production/polish702'/id;prod.mkdir(parents=True,exist_ok=True)
# hand / chest / head / back measured on the eight original cutouts.
SPECS={
'idle':((0,0,512,430),(395,265),(315,205),(337,112),(276,197)),
'ready':((512,0,1024,430),(913,276),(790,240),(840,173),(748,231)),
'windup':((0,430,512,822),(273,456),(330,623),(378,548),(282,618)),
'attack_contact':((512,430,1024,822),(984,600),(826,623),(868,548),(775,626)),
'recovery':((0,822,512,1220),(433,1056),(316,1011),(367,935),(270,1010)),
'hit':((512,822,1024,1220),(895,991),(785,1002),(750,916),(745,1012)),
'defeated':((0,1220,560,1536),(534,1466),(310,1430),(436,1420),(290,1430)),
'run':((560,1220,1024,1536),(970,1354),(820,1375),(922,1307),(783,1370))}
data={'source_sha256':sha(src),'canvas':[640,512],'ground':[320,488],'poses':{}};packed=Image.new('RGBA',(1536,2560))
for i,(pose,(rect,hand,chest,head,back)) in enumerate(SPECS.items()):
 cut,bbox=cut_alpha(im,rect);scale=.98;sw,sh=round(cut.width*scale),round(cut.height*scale)
 x=round(430-(chest[0]-rect[0]-bbox[0])*scale);y=488-sh
 if pose=='defeated':x=620-sw
 assert x>=0 and x+sw<=640 and y>=0,(pose,x,sw,y,sh)
 canvas=Image.new('RGBA',(640,512));canvas.alpha_composite(cut.resize((sw,sh),Image.Resampling.LANCZOS),(x,y));dest=out/(pose+'.png');canvas.save(dest)
 def point(p):return [round(x+(p[0]-rect[0]-bbox[0])*scale),round(y+(p[1]-rect[1]-bbox[1])*scale)]
 data['poses'][pose]={'cell':rect,'crop':bbox,'scale':scale,'offset':[x,y],'hand':point(hand),'chest':point(chest),'head':point(head),'back':point(back),'sha256':sha(dest)}
 packed.alpha_composite(canvas,((i%2)*768+64,(i//2)*640+64))
packed.save(prod/'production_sheet.png');portrait=im.crop((253,25,412,180));pc=Image.new('RGBA',(256,256));portrait.thumbnail((224,224),Image.Resampling.LANCZOS);pc.alpha_composite(portrait,((256-portrait.width)//2,(256-portrait.height)//2));pc.save(out/'portrait.png');data['portrait_sha256']=sha(out/'portrait.png');MANIFEST['assets'][id]=data
(ROOT/'production/polish702/manifest.json').write_text(json.dumps(MANIFEST,indent=2)+'\n')
print(json.dumps({k:{'poses':len(v['poses']),'canvas':v['canvas']} for k,v in MANIFEST['assets'].items()},indent=2))
