"""Exercise the real HTTP API with separate authenticated clients and a temp DB."""
import json,tempfile,threading,urllib.request,urllib.error,sys
from pathlib import Path
from realm_service import RealmService,RealmHTTPServer
checks=[]
def check(ok,label):
 checks.append({'ok':bool(ok),'label':label})
 if not ok:raise AssertionError(label)
def run():
 with tempfile.TemporaryDirectory(prefix='realm708-api-') as temp:
  service=RealmService(Path(temp)/'online.sqlite3');server=RealmHTTPServer(('127.0.0.1',0),service,temp)
  thread=threading.Thread(target=server.serve_forever,daemon=True);thread.start();base='http://127.0.0.1:'+str(server.server_port)
  def call(path,body=None,token='',origin=None):
   headers={'Content-Type':'application/json'}
   if token:headers['Authorization']='Bearer '+token
   if origin:headers['Origin']=origin
   req=urllib.request.Request(base+'/api/v1/'+path,json.dumps(body).encode() if body is not None else None,headers)
   try:
    with urllib.request.urlopen(req,timeout=20) as r:return r.status,json.load(r)
   except urllib.error.HTTPError as e:return e.code,json.load(e)
  try:
   check(call('health')[0]==200,'HTTP service boots')
   def static_status(route):
    try:
     with urllib.request.urlopen(base+route,timeout=5) as response:return response.status
    except urllib.error.HTTPError as error:return error.code
   Path(temp,'index.html').write_text('<!doctype html><title>Realm</title>')
   check(static_status('/')==200,'exported web index can be served')
   check(static_status('/online.sqlite3')==404,'database inside web root cannot be downloaded')
   Path(temp,'private.py').write_text('private=1')
   check(static_status('/private.py')==404,'backend source cannot be downloaded')
   Path(temp,'listing').mkdir()
   check(static_status('/listing/')==404,'static directory listings disabled')
   check(call('state')[0]==401,'private state requires authentication')
   check(call('register',{'name':'Weak','password':'tiny'})[0]==400,'short password rejected')
   code,a=call('register',{'name':'Alice708','password':'Alice-password-708'});check(code==200,'first account registered');at=a['token'];aid=a['state']['me']['id']
   code,b=call('register',{'name':'Bob708','password':'Bob-password-708'});check(code==200,'second account registered');bt=b['token'];bid=b['state']['me']['id']
   check(len(b['state']['leaderboard'])==2,'leaderboard contains exactly real accounts')
   check(len(b['state']['opponents'])==1 and b['state']['opponents'][0]['id']==aid,'arena opponent is actual other account')
   check(call('login',{'name':'Alice708','password':'wrong'})[0]==401,'wrong password denied')
   check(call('login',{'name':'Alice708','password':'Alice-password-708'})[0]==200,'password login succeeds')
   with service.db() as d:
    row=d.execute('select * from users where id=?',(aid,)).fetchone();check(row['password']!='Alice-password-708' and len(row['salt'])==32,'password stored as salted hash')
   check(call('register',{'name':'Alice708','password':'again-password-708'})[0]==409,'duplicate account name rejected')
   code,g=call('guild/create',{'name':'Sky708','tag':'SKY'},at);check(code==200,'create real guild');gid=g['result']['guild_id']
   check(call('guild/join',{'id':gid},bt)[0]==200,'second client joins guild')
   check(len(call('state',token=at)[1]['guild']['members'])==2,'first client sees second member')
   check(call('guild/join',{'id':gid},bt)[0]==409,'double membership rejected')
   code,fight=call('arena/fight',{'opponent':bid,'nonce':'arena-708-0001','rating':99999999,'won':True},at)
   check(code==200 and abs(fight['result']['rating_delta'])<=24,'arena rating calculated by server')
   check(len(fight['result']['rounds'])>1,'arena returns actual simulated combat actions')
   state=fight['state'];duplicate=call('arena/fight',{'opponent':bid,'nonce':'arena-708-0001'},at)
   check(duplicate[0]==200 and duplicate[1]['result']==fight['result'],'duel retry is idempotent')
   check(duplicate[1]['state']['me']['rating']==state['me']['rating'],'duel retry cannot grant repeated rating')
   check(call('arena/fight',{'opponent':bid,'nonce':'arena-708-0002'},at)[0]==429,'arena cooldown enforced')
   check(call('arena/fight',{'opponent':aid,'nonce':'arena-708-self'},at)[0]==400,'self PvP rejected')
   check(call('title',{'title':'duelist'},at)[0]==403,'unearned online title denied')
   before=call('state',token=at)[1]['boss']['hp']
   ra=call('boss/attack',{'nonce':'raid-708-alice'},at);rb=call('boss/attack',{'nonce':'raid-708-bobby'},bt)
   check(ra[0]==rb[0]==200,'two separate clients attack same boss')
   check(rb[1]['state']['boss']['hp']==before-ra[1]['result']['damage']-rb[1]['result']['damage'],'shared HP reflects both contributions')
   check(len(rb[1]['state']['boss']['contributions'])==2,'both contributors visible')
   again=call('boss/attack',{'nonce':'raid-708-bobby'},bt);check(again[1]['state']['boss']['hp']==rb[1]['state']['boss']['hp'],'boss retry cannot cause duplicate damage')
   check(call('boss/attack',{'nonce':'raid-708-fast'},bt)[0]==429,'boss attack cooldown enforced')
   backup={'version':2,'profile':{'gold':123},'checkpoint':{}}
   check(call('backup',{'revision':0,'save':backup},at)[0]==200,'private save backup created')
   check(call('backup',token=bt)[0]==404,'second account cannot read first backup')
   check(call('backup?user_id='+aid,token=bt)[0]==404,'query-string ID cannot bypass backup ownership')
   check(call('backup',{'revision':0,'save':{'version':2,'profile':{'gold':999}}},at)[0]==409,'stale cloud revision rejected')
   check(call('backup',token=at)[1]['save']['profile']['gold']==123,'conflicting write preserves existing backup')
   check(call('register',{'name':'CrossOrigin','password':'irrelevant-password'},origin='https://untrusted.example')[0]==403,'foreign browser origin rejected')
   with service.db() as d:d.execute('update bosses set hp=40');d.execute("delete from cooldowns where kind='boss'")
   killed=call('boss/attack',{'nonce':'raid-708-final'},bt)
   check(killed[0]==200 and killed[1]['state']['boss']['hp']==0,'server resolves final boss blow')
   check(call('state',token=at)[1]['me']['raid_points']==50 and killed[1]['state']['me']['raid_points']==50,'all contributors receive one reward')
   check(call('boss/attack',{'nonce':'raid-708-final'},bt)[1]['state']['me']['raid_points']==50,'boss completion retry cannot duplicate reward')
   check(call('title',{'title':'titan_slayer'},bt)[0]==200,'earned online title can be equipped')
   check(call('guild/leave',{},at)[0]==200,'guild owner can leave')
   check(call('state',token=bt)[1]['guild']['role']=='owner','guild ownership transfers to remaining member')
   guest=call('guest',{'name':'Guest708'})[1];gt=guest['token'];guest_id=guest['state']['me']['id']
   upgrade=call('account/upgrade',{'name':'Permanent708','password':'permanent-password'},gt)
   check(upgrade[0]==200 and upgrade[1]['state']['me']['id']==guest_id and not upgrade[1]['state']['me']['guest'],'guest upgrades in place without losing identity')
   check(call('login',{'name':'Permanent708','password':'permanent-password'})[0]==200,'upgraded guest supports durable password login')
   restored=RealmService(service.database);check(restored.state(bid)['guild']['id']==gid,'service restart preserves memberships')
   check(restored.state(bid)['me']['title']=='titan_slayer','service restart preserves online progression')
   check(call('logout',{},at)[0]==200 and call('state',token=at)[0]==401,'logout invalidates current bearer token')
  finally:server.shutdown();server.server_close();thread.join(timeout=5)
if __name__=='__main__':
 try:run()
 finally:
  destination=Path(sys.argv[1]) if len(sys.argv)>1 else Path('backend_checks_708.json');destination.write_text(json.dumps({'checks':checks},indent=2))
 print(f'Online HTTP: {sum(x["ok"] for x in checks)}/{len(checks)} checks')
