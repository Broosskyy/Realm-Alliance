"""Normalize preserved transparent atlases with measured source-space sockets."""
from pathlib import Path
from PIL import Image
import json
root=Path(__file__).resolve().parents[2];assets=root/'godot/realm_alliance/assets/work712'
poses=['idle','ready','windup','attack_contact','recovery','hit']
sets={
'male':([(350,286),(388,242),(199,82),(487,145),(329,248),(224,184)],[(296,66),(321,112),(307,97),(338,96),(324,96),(214,92)],[(245,153,330,219),(266,168,349,230),(211,148,330,237),(228,164,320,224),(253,168,337,228),(181,163,306,235)],[(172,395,215,479),(318,360,383,447),(133,368,186,476),(83,361,144,462),(141,372,189,470),(129,357,181,466)],[(278,372,362,467),(340,357,419,459),(363,360,434,459),(362,361,441,439),(343,358,406,443),(299,355,366,464)]),
'female':([(334,280),(381,220),(194,67),(465,157),(385,282),(284,169)],[(286,67),(316,107),(301,82),(306,89),(328,97),(213,88)],[(233,144,302,215),(263,165,332,226),(216,131,318,210),(218,150,299,223),(261,164,337,231),(200,155,282,226)],[(156,399,195,479),(124,370,173,470),(122,366,170,472),(79,396,133,479),(126,390,172,477),(144,381,191,479)],[(271,387,349,476),(351,358,412,453),(361,347,425,452),(327,372,388,467),(361,366,421,463),(312,362,375,471)])}
meta={'schema':1,'canvas':[640,512],'pivot':[320,488],'bodies':{},'source':'built-in image_gen; preserved transparent six-pose atlases; empty gripping hands, basic cloth/leather/backpack, black face and amber eyes, brown hair. Separate weapons.'}
fpath=root/'godot/realm_alliance/assets/work711/wardrobe/fit_anchors.json';fits=json.loads(fpath.read_text());bpath=fpath.with_name('texture_bounds.json');bounds=json.loads(bpath.read_text())
for sex,(hands,heads,torsos,boots,second) in sets.items():
 im=Image.open(assets/(sex+'_source.png')).convert('RGBA');dest=assets/'adventurer'/sex;dest.mkdir(parents=True,exist_ok=True);frames={};fits['heroes']['adventurer_'+sex]={}
 for i,pose in enumerate(poses):
  cell=im.crop(((i%3)*512,(i//3)*512,(i%3+1)*512,(i//3+1)*512));bb=cell.getchannel('A').point(lambda a:255 if a>8 else 0).getbbox();s=.88;tx=320-round((torsos[i][0]+torsos[i][2])*.5*s);ty=488-round(bb[3]*s)
  canvas=Image.new('RGBA',(640,512));canvas.alpha_composite(cell.resize((451,451),Image.Resampling.LANCZOS),(tx,ty));canvas.save(dest/(pose+'.png'),optimize=True)
  def p(v):return [round(v[0]*s+tx),round(v[1]*s+ty)]
  x,y,x2,y2=torsos[i];h=p(heads[i]);hand=p(hands[i]);tor=[p((x,y)),p((x2,y+5)),p((x2-4,y2)),p((x+5,y2))];hips=[tor[3],tor[2],p((x2+14,y2+53)),p((x-18,y2+53))]
  feet=[]
  for a,b,c,d in [boots[i],second[i]]:feet.append([*p((a,b)),round((c-a)*s),round((d-b)*s)])
  frames[pose]={'hand':hand,'angle':[-28,-34,-40,-8,-25,-45][i],'head':h,'chest':p(((x+x2)/2,(y+y2)/2)),'back':p((x-9,y+10)),'hair_region':[h[0]-64,h[1]-66,h[0]+55,h[1]+22]}
  fits['heroes']['adventurer_'+sex][pose]={'torso':tor,'hips':hips,'head':[h[0],h[1]-6,78,-4],'shoulder_left':[*p((x-22,y-5)),48,42,-8],'shoulder_right':[*p((x2-12,y+4)),35,38,9],'forearm':[[hand[0]-25,hand[1]-22],[hand[0]+20,hand[1]-22],[hand[0]+25,hand[1]+22],[hand[0]-25,hand[1]+22]],'boots':feet}
  a=canvas.getchannel('A').getbbox();bounds['res://assets/work712/adventurer/'+sex+'/'+pose+'.png']=[a[0],a[1],a[2]-a[0],a[3]-a[1]]
  if i==0:canvas.crop((h[0]-75,h[1]-70,h[0]+75,h[1]+88)).save(dest/'portrait.png',optimize=True)
 meta['bodies'][sex]=frames
(assets/'character_sockets.json').write_text(json.dumps(meta,indent=2)+'\n');fpath.write_text(json.dumps(fits,indent=2)+'\n');bpath.write_text(json.dumps(bounds,indent=2)+'\n')
im=Image.open(assets/'weapons_source.png').convert('RGBA');w,h=im.size;(assets/'weapons').mkdir(exist_ok=True)
for item,box,grip in [('bow',(0,0,w//2,h),(345,630)),('staff',(w//2,0,w,h),(940-w//2,775))]:
 c=im.crop(box);s=.70;out=Image.new('RGBA',(512,1024));xy=(round(256-grip[0]*s),round((512 if item=='bow' else 620)-grip[1]*s));out.alpha_composite(c.resize((round(c.width*s),round(c.height*s)),Image.Resampling.LANCZOS),xy);out.save(assets/'weapons'/(item+'.png'),optimize=True)
