"""REALM 708: standalone reference online service, Python stdlib + SQLite.
Server-owned Arena/ranking/raid state; opaque private backups of local PvE saves.
Start behind HTTPS for remote use. No external dependencies or demo players.
"""
import argparse,hashlib,hmac,json,secrets,sqlite3,threading,time,unicodedata
from pathlib import Path
from contextlib import contextmanager
from http.server import SimpleHTTPRequestHandler,ThreadingHTTPServer
from urllib.parse import urlsplit

class APIError(Exception):
 def __init__(self,status,message):self.status,self.message=status,message

def name(value,maximum=24):
 value=unicodedata.normalize('NFKC',str(value)).strip()
 if not 3<=len(value)<=maximum or any(not(c.isalnum() or c in ' _-') for c in value):raise APIError(400,f'Name: 3–{maximum} Buchstaben, Zahlen, Leerzeichen oder _-.')
 return value

def hashed(password,salt):return hashlib.pbkdf2_hmac('sha256',password.encode(),bytes.fromhex(salt),600000).hex()

class RealmService:
 def __init__(self,database):
  self.database=str(database);self.rate={};self.lock=threading.Lock();Path(self.database).parent.mkdir(parents=True,exist_ok=True)
  with self.db() as d:d.executescript('''
pragma journal_mode=WAL;
create table if not exists users(id text primary key,name text not null unique collate nocase,salt text not null,password text not null,guest integer not null,created real not null,seen real not null);
create table if not exists sessions(token text primary key,user_id text not null references users(id),expires real not null);
create table if not exists players(user_id text primary key references users(id),rating integer not null default 1000,wins integer not null default 0,losses integer not null default 0,raid_points integer not null default 0,title text not null default 'wanderer');
create table if not exists guilds(id text primary key,name text not null unique collate nocase,tag text not null unique collate nocase,owner text not null references users(id));
create table if not exists members(user_id text primary key references users(id),guild_id text not null references guilds(id),role text not null);
create index if not exists guild_members on members(guild_id);
create table if not exists bosses(id text primary key,hp integer not null,max_hp integer not null);
create table if not exists contributions(boss_id text not null,user_id text not null,damage integer not null default 0,rewarded integer not null default 0,primary key(boss_id,user_id));
create table if not exists cooldowns(user_id text not null,kind text not null,ready real not null,primary key(user_id,kind));
create table if not exists receipts(user_id text not null,kind text not null,nonce text not null,result text not null,primary key(user_id,kind,nonce));
create table if not exists backups(user_id text primary key,revision integer not null,data text not null,updated real not null);
''')
 @contextmanager
 def db(self):
  d=sqlite3.connect(self.database,timeout=10,isolation_level=None);d.row_factory=sqlite3.Row;d.execute('pragma foreign_keys=ON')
  try:yield d
  finally:d.close()
 def throttle(self,key,limit=180):
  with self.lock:
   now=time.time();values=[x for x in self.rate.get(key,[]) if x>now-60]
   if len(values)>=limit:raise APIError(429,'Zu viele Versuche. Bitte kurz warten.')
   values.append(now);self.rate[key]=values
   if len(self.rate)>5000:self.rate={k:v for k,v in self.rate.items() if v and v[-1]>now-60}
 def identify(self,token):
  with self.db() as d:r=d.execute('select user_id from sessions where token=? and expires>?',(hashlib.sha256(token.encode()).hexdigest(),time.time())).fetchone()
  if not r:raise APIError(401,'Bitte anmelden oder als Gast verbinden.')
  return r['user_id']
 def auth(self,kind,b,ip):
  self.throttle(('auth',ip),20)
  with self.db() as d:
   d.execute('begin immediate')
   try:
    if kind=='login':
     n=name(b.get('name',''));p=str(b.get('password',''));r=d.execute('select * from users where name=?',(n,)).fetchone();digest=hashed(p,r['salt'] if r else '00'*16)
     if not r or r['guest'] or not hmac.compare_digest(digest,r['password']):raise APIError(401,'Name oder Passwort stimmt nicht.')
     uid=r['id']
    else:
     guest=kind=='guest';n=name(b.get('name','Wanderer'));p=str(b.get('password',''));salt=secrets.token_hex(16);uid=secrets.token_hex(16)
     if guest:n=n[:18]+' '+secrets.token_hex(2)
     if not guest and not 10<=len(p)<=256:raise APIError(400,'Passwort: 10–256 Zeichen.')
     d.execute('insert into users values(?,?,?,?,?,?,?)',(uid,n,salt,'' if guest else hashed(p,salt),int(guest),time.time(),time.time()));d.execute('insert into players(user_id) values(?)',(uid,))
    token=secrets.token_urlsafe(32);d.execute('insert into sessions values(?,?,?)',(hashlib.sha256(token.encode()).hexdigest(),uid,time.time()+30*86400));d.execute('commit')
   except sqlite3.IntegrityError:d.execute('rollback');raise APIError(409,'Dieser Name ist bereits vergeben.')
   except Exception:d.execute('rollback');raise
  return {'token':token,'state':self.state(uid)}
 def profile(self,r):return {k:r[k] for k in ['id','name','guest','rating','wins','losses','raid_points','title']}|{'level':1+r['raid_points']//100+r['wins']//5}
 def boss(self,d):
  bid='sky-titan-'+time.strftime('%Y-%m-%d',time.gmtime());d.execute('insert or ignore into bosses values(?,?,?)',(bid,6000,6000));return dict(d.execute('select * from bosses where id=?',(bid,)).fetchone())
 def state(self,uid):
  with self.db() as d:
   d.execute('update users set seen=? where id=?',(time.time(),uid));me=self.profile(d.execute('select u.*,p.* from users u join players p on p.user_id=u.id where u.id=?',(uid,)).fetchone())
   leaders=[self.profile(r) for r in d.execute('select u.*,p.* from users u join players p on p.user_id=u.id order by rating desc,raid_points desc,u.created limit 50')]
   opponents=[self.profile(r) for r in d.execute('select u.*,p.* from users u join players p on p.user_id=u.id where u.id<>? order by abs(p.rating-?) limit 5',(uid,me['rating']))]
   g=d.execute('select g.*,m.role from members m join guilds g on g.id=m.guild_id where m.user_id=?',(uid,)).fetchone();guild=dict(g) if g else None
   if guild:guild['members']=[dict(r) for r in d.execute('select u.id,u.name,m.role,u.seen from members m join users u on u.id=m.user_id where m.guild_id=?',(g['id'],))]
   guilds=[dict(r) for r in d.execute('select g.id,g.name,g.tag,count(m.user_id) as members from guilds g left join members m on m.guild_id=g.id group by g.id limit 20')]
   boss=self.boss(d);boss['contributions']=[dict(r) for r in d.execute('select u.name,c.damage from contributions c join users u on u.id=c.user_id where c.boss_id=? order by damage desc limit 20',(boss['id'],))]
   online=[dict(r) for r in d.execute('select id,name from users where seen>? order by seen desc limit 30',(time.time()-90,))];backup=d.execute('select revision,updated from backups where user_id=?',(uid,)).fetchone()
   return {'me':me,'guild':guild,'guilds':guilds,'leaderboard':leaders,'opponents':opponents,'boss':boss,'online':online,'backup':dict(backup) if backup else {'revision':0},'server_time':time.time(),'api_version':1}
 def cooldown(self,d,uid,kind,seconds):
  r=d.execute('select ready from cooldowns where user_id=? and kind=?',(uid,kind)).fetchone()
  if r and r['ready']>time.time():raise APIError(429,'Aktion lädt noch auf. Bitte kurz warten.')
  d.execute('insert into cooldowns values(?,?,?) on conflict(user_id,kind) do update set ready=excluded.ready',(uid,kind,time.time()+seconds))
 def request(self,method,path,b,token='',ip='local'):
  if method=='GET' and path=='/api/v1/health':return {'ok':True,'api_version':1,'service':'REALM ALLIANCE'}
  if method=='POST' and path in ['/api/v1/register','/api/v1/login','/api/v1/guest']:return self.auth(path.rsplit('/',1)[1],b,ip)
  uid=self.identify(token);self.throttle(('api',uid))
  if method=='GET' and path=='/api/v1/state':return self.state(uid)
  if method=='GET' and path=='/api/v1/backup':
   with self.db() as d:r=d.execute('select * from backups where user_id=?',(uid,)).fetchone()
   if not r:raise APIError(404,'Noch keine Sicherung vorhanden.')
   return {'revision':r['revision'],'updated':r['updated'],'save':json.loads(r['data'])}
  if method!='POST':raise APIError(404,'Unbekannte Aktion.')
  with self.db() as d:
   d.execute('begin immediate')
   try:
    result=self.mutate(d,uid,path,b,token);d.execute('commit')
   except APIError:d.execute('rollback');raise
   except sqlite3.IntegrityError:d.execute('rollback');raise APIError(409,'Name oder Kürzel bereits vergeben.')
   except Exception:d.execute('rollback');raise
  return {'result':result,'state':self.state(uid)}
 def mutate(self,d,uid,path,b,token):
  if path=='/api/v1/logout':d.execute('delete from sessions where token=?',(hashlib.sha256(token.encode()).hexdigest(),));return {'logged_out':True}
  if path=='/api/v1/account/upgrade':
   if not d.execute('select guest from users where id=?',(uid,)).fetchone()['guest']:raise APIError(409,'Konto bereits gesichert.')
   n=name(b.get('name',''));p=str(b.get('password',''));salt=secrets.token_hex(16)
   if not 10<=len(p)<=256:raise APIError(400,'Passwort: 10–256 Zeichen.')
   d.execute('update users set name=?,salt=?,password=?,guest=0 where id=?',(n,salt,hashed(p,salt),uid));return {'upgraded':True}
  if path=='/api/v1/guild/create':
   if d.execute('select 1 from members where user_id=?',(uid,)).fetchone():raise APIError(409,'Du gehörst bereits einer Familie an.')
   gid=secrets.token_hex(8);d.execute('insert into guilds values(?,?,?,?)',(gid,name(b.get('name',''),30),name(b.get('tag',''),5).upper(),uid));d.execute('insert into members values(?,?,?)',(uid,gid,'owner'));return {'guild_id':gid}
  if path=='/api/v1/guild/join':
   gid=str(b.get('id',''))
   if not d.execute('select 1 from guilds where id=?',(gid,)).fetchone():raise APIError(404,'Familie nicht gefunden.')
   if d.execute('select 1 from members where user_id=?',(uid,)).fetchone():raise APIError(409,'Du gehörst bereits einer Familie an.')
   if d.execute('select count(*) from members where guild_id=?',(gid,)).fetchone()[0]>=30:raise APIError(409,'Diese Familie ist voll.')
   d.execute('insert into members values(?,?,?)',(uid,gid,'member'));return {'joined':True}
  if path=='/api/v1/guild/leave':
   r=d.execute('select * from members where user_id=?',(uid,)).fetchone()
   if not r:raise APIError(409,'Du gehörst keiner Familie an.')
   gid=r['guild_id'];d.execute('delete from members where user_id=?',(uid,))
   if r['role']=='owner':
    successor=d.execute('select user_id from members where guild_id=? order by user_id limit 1',(gid,)).fetchone()
    if successor:d.execute("update members set role='owner' where user_id=?",(successor['user_id'],));d.execute('update guilds set owner=? where id=?',(successor['user_id'],gid))
    else:d.execute('delete from guilds where id=?',(gid,))
   return {'left':True}
  if path in ['/api/v1/arena/fight','/api/v1/boss/attack']:
   kind='arena' if path.endswith('fight') else 'boss';nonce=str(b.get('nonce',''))
   if not 8<=len(nonce)<=80:raise APIError(400,'Ungültige Aktionskennung.')
   cached=d.execute('select result from receipts where user_id=? and kind=? and nonce=?',(uid,kind,nonce)).fetchone()
   if cached:return json.loads(cached['result'])
   me=d.execute('select * from players where user_id=?',(uid,)).fetchone()
   if kind=='arena':
    other=str(b.get('opponent',''));op=d.execute('select * from players where user_id=?',(other,)).fetchone()
    if not op or other==uid:raise APIError(400,'Wähle einen anderen echten Spieler.')
    self.cooldown(d,uid,'arena',15);level=lambda r:1+r['raid_points']//100+r['wins']//5
    hp=[150+10*level(me),150+10*level(op)];attack=[15+2*level(me),15+2*level(op)];rounds=[]
    for i in range(30):
     side=i%2;damage=attack[side]+secrets.randbelow(7)-3;hp[1-side]-=damage;rounds.append({'attacker':side,'damage':damage})
     if hp[1-side]<=0:break
    won=(hp[0]>hp[1]) if min(hp)>0 else hp[0]>0;expected=1/(1+10**(max(-4000,min(4000,op['rating']-me['rating']))/400));rating=max(100,me['rating']+round(24*(int(won)-expected)));delta=rating-me['rating']
    d.execute('update players set rating=?,wins=wins+?,losses=losses+? where user_id=?',(rating,int(won),int(not won),uid));d.execute('update players set rating=max(100,rating-?),wins=wins+?,losses=losses+? where user_id=?',(delta,int(not won),int(won),other));result={'won':won,'rating_delta':delta,'rounds':rounds,'opponent':other}
   else:
    boss=self.boss(d)
    if boss['hp']<=0:raise APIError(409,'Himmelstitan besiegt. Morgen erscheint er erneut.')
    self.cooldown(d,uid,'boss',1.2);damage=min(boss['hp'],40+5*(me['wins']//5+me['raid_points']//100));d.execute('update bosses set hp=hp-? where id=?',(damage,boss['id']));d.execute('insert into contributions values(?,?,?,0) on conflict(boss_id,user_id) do update set damage=damage+excluded.damage',(boss['id'],uid,damage))
    if damage==boss['hp']:
     for r in d.execute('select * from contributions where boss_id=? and rewarded=0',(boss['id'],)).fetchall():d.execute('update players set raid_points=raid_points+50 where user_id=?',(r['user_id'],))
     d.execute('update contributions set rewarded=1 where boss_id=?',(boss['id'],))
    result={'damage':damage,'remaining_hp':boss['hp']-damage}
   d.execute('insert into receipts values(?,?,?,?)',(uid,kind,nonce,json.dumps(result)));return result
  if path=='/api/v1/title':
   title=str(b.get('title',''));r=d.execute('select * from players where user_id=?',(uid,)).fetchone()
   if title not in ['wanderer','duelist','titan_slayer']:raise APIError(400,'Unbekannter Titel.')
   if (title=='duelist' and r['wins']<5) or (title=='titan_slayer' and r['raid_points']<50):raise APIError(403,'Titel noch nicht verdient.')
   d.execute('update players set title=? where user_id=?',(title,uid));return {'title':title}
  if path=='/api/v1/backup':
   save=b.get('save');rev=b.get('revision')
   if not isinstance(save,dict) or save.get('version')!=2 or not isinstance(save.get('profile'),dict):raise APIError(400,'Ungültiger Spielstand.')
   raw=json.dumps(save,allow_nan=False,separators=(',',':'))
   if len(raw.encode())>400000:raise APIError(413,'Spielstand zu groß.')
   current=d.execute('select revision from backups where user_id=?',(uid,)).fetchone();current=int(current['revision']) if current else 0
   if type(rev) is not int or rev!=current:raise APIError(409,'Neuere Cloud-Sicherung vorhanden. Erst aktualisieren.')
   d.execute('insert into backups values(?,?,?,?) on conflict(user_id) do update set revision=excluded.revision,data=excluded.data,updated=excluded.updated',(uid,current+1,raw,time.time()));return {'revision':current+1}
  raise APIError(404,'Unbekannte Aktion.')

class RealmHTTPServer(ThreadingHTTPServer):
 daemon_threads=True
 def __init__(self,address,service,web_root,allowed_origins=()):
  self.service=service;self.web_root=str(Path(web_root).resolve());self.allowed_origins=set(allowed_origins);super().__init__(address,RealmHandler)
class RealmHandler(SimpleHTTPRequestHandler):
 extensions_map=SimpleHTTPRequestHandler.extensions_map|{'.wasm':'application/wasm','.js':'application/javascript'}
 def __init__(self,*args,**kwargs):super().__init__(*args,directory=args[2].web_root,**kwargs)
 def log_message(self,*args):pass
 def origin_allowed(self):
  origin=self.headers.get('Origin','');own=('https' if self.headers.get('X-Forwarded-Proto')=='https' else 'http')+'://'+self.headers.get('Host','')
  return not origin or origin==own or origin in self.server.allowed_origins
 def end_headers(self):
  self.send_header('X-Content-Type-Options','nosniff');self.send_header('Cache-Control','no-store' if self.path.startswith('/api/') else 'no-cache');self.send_header('Referrer-Policy','no-referrer');origin=self.headers.get('Origin','')
  if origin in self.server.allowed_origins:self.send_header('Access-Control-Allow-Origin',origin);self.send_header('Vary','Origin')
  super().end_headers()
 def do_OPTIONS(self):
  if not self.origin_allowed():return self.send_error(403)
  self.send_response(204);self.send_header('Access-Control-Allow-Headers','Authorization, Content-Type');self.send_header('Access-Control-Allow-Methods','GET, POST, OPTIONS');self.end_headers()
 def send_head(self):
  candidate=Path(self.translate_path(self.path)).resolve();root=Path(self.server.web_root)
  if candidate==root:candidate=root/'index.html'
  if not candidate.is_relative_to(root) or candidate.suffix.lower() not in {'.html','.js','.wasm','.pck','.png','.webp','.ico','.css','.svg','.woff','.woff2'} or not candidate.is_file():
   self.send_error(404);return None
  if candidate==Path(self.server.service.database).resolve():self.send_error(404);return None
  return super().send_head()
 def do_GET(self):return self.api('GET') if self.path.startswith('/api/') else super().do_GET()
 def do_POST(self):return self.api('POST')
 def api(self,method):
  try:
   if not self.origin_allowed():raise APIError(403,'Dieser Ursprung ist nicht freigegeben.')
   length=int(self.headers.get('Content-Length','0'))
   if not 0<=length<=524288:raise APIError(413,'Anfrage zu groß.')
   self.connection.settimeout(15);b=json.loads(self.rfile.read(length),parse_constant=lambda v:(_ for _ in ()).throw(ValueError())) if length else {}
   if not isinstance(b,dict):raise APIError(400,'Objekt erwartet.')
   a=self.headers.get('Authorization','');token=a[7:] if a.startswith('Bearer ') else '';result=self.server.service.request(method,urlsplit(self.path).path,b,token,self.client_address[0]);code=200
  except APIError as e:code=e.status;result={'error':e.message}
  except (ValueError,UnicodeError):code=400;result={'error':'Ungültige Anfrage.'}
  except Exception:code=500;result={'error':'Dienstfehler. Bitte erneut versuchen.'}
  raw=json.dumps(result,ensure_ascii=False,allow_nan=False).encode();self.send_response(code);self.send_header('Content-Type','application/json; charset=utf-8');self.send_header('Content-Length',str(len(raw)));self.end_headers();self.wfile.write(raw)

def main():
 p=argparse.ArgumentParser();p.add_argument('--host',default='127.0.0.1');p.add_argument('--port',type=int,default=8765);p.add_argument('--database',default=str(Path.home()/'.realm-alliance'/'online708.sqlite3'));p.add_argument('--web-root',default='.');p.add_argument('--allow-origin',action='append',default=[]);a=p.parse_args();s=RealmHTTPServer((a.host,a.port),RealmService(a.database),a.web_root,a.allow_origin);print(f'REALM ALLIANCE: http://{a.host}:{s.server_port}',flush=True)
 try:s.serve_forever()
 except KeyboardInterrupt:pass
 finally:s.server_close()
if __name__=='__main__':main()
