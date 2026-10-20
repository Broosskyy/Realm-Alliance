// Use the excluded tests/review702.tscn scene for QA; never ship that scene.
const { chromium } = require('playwright');
const fs = require('fs'), path = require('path'), http = require('http');
const arg = (name, fallback) => { const i = process.argv.indexOf(name); return i < 0 ? fallback : process.argv[i + 1]; };
const root = path.resolve(arg('--web-root', 'build708/qa'));
const shots = path.resolve(arg('--screenshots', '/tmp/realm708-review'));
const report = path.resolve(arg('--report', 'browser_checks_708.json'));
const checks = [], errors = [];
const check = (ok, label) => { checks.push({ ok: !!ok, label }); console.log(ok?'PASS':'FAIL', label); };
const mime = { '.html':'text/html', '.js':'application/javascript', '.wasm':'application/wasm', '.png':'image/png' };
let browser, secondBrowser, server, page;
(async () => {
  fs.mkdirSync(shots, { recursive: true });
  const {spawn}=require('child_process'),os=require('os');
  const temporary=fs.mkdtempSync(path.join(os.tmpdir(),'realm708-browser-'));
  const child=spawn('python',[path.resolve(__dirname,'../backend/realm_service.py'),'--port','0','--database',path.join(temporary,'online.sqlite3'),'--web-root',root]);
  const port=await new Promise((resolve,reject)=>{let log='';child.stdout.on('data',v=>{log+=v;const m=log.match(/127\.0\.0\.1:(\d+)/);if(m)resolve(Number(m[1]));});child.on('error',reject);child.on('exit',c=>reject(Error('Backend exited '+c)));});
  server={address:()=>({port}),close:fn=>{child.once('exit',()=>{fs.rmSync(temporary,{recursive:true,force:true});if(fn)fn();});child.kill();}};
  browser = await chromium.launch({ executablePath: path.resolve(arg('--browser', 'tools/headless-shell/chrome-headless-shell-linux64/chrome-headless-shell')),
    args: ['--no-sandbox','--no-zygote','--single-process','--disable-dev-shm-usage','--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader'] });
  const context = await browser.newContext({ viewport: { width:390, height:844 }, hasTouch:true, isMobile:true });
  page = await context.newPage();
  page.on('pageerror', error => errors.push(error.message));
  page.on('console', message => { if (/SCRIPT ERROR|Parse Error|Invalid call|Cannot call method/.test(message.text())) errors.push(message.text()); });
  await page.goto('http://127.0.0.1:' + server.address().port);
  await page.waitForFunction(() => !!window.realmQA, null, { timeout:90000 });
  const cmd = async value => {
    await page.evaluate(value => { window.realmQAState = null; window.realmQA(value); }, value);
    await page.waitForFunction(() => window.realmQAState !== null);
    await page.waitForTimeout(110);
    return page.evaluate(() => window.realmQAState);
  };
  const state = () => cmd('pause');
  const point = async rect => {
    const s = await state(), vp = page.viewportSize();
    return { x:(rect.x + rect.width/2) * vp.width/s.viewport[0], y:(rect.y + rect.height/2) * vp.height/s.viewport[1] };
  };
  const tap = async (find, label) => {
    const s = await state(), button = s.buttons.find(find);
    if (!button) throw Error('Missing button: ' + label);
    const p = await point(button); await page.touchscreen.tap(p.x, p.y); return state();
  };
  const text = value => tap(b => b.text === value, value);
  const name = value => tap(b => b.name === value, value);
  const cdp = await context.newCDPSession(page);
  const swipe = async () => {
    const s = await state(), vp = page.viewportSize();
    const list = s.scrolls.filter(v => v.max > v.page + 5).sort((a,b) => b.height-a.height)[0];
    if (!list) return false;
    const sx=vp.width/s.viewport[0], sy=vp.height/s.viewport[1];
    const x=Math.min(vp.width-30, Math.max(30,(list.x+list.width*.7)*sx));
    const bottom=Math.min(vp.height-85,(list.y+list.height)*sy-25), top=Math.max(90,list.y*sy+80);
    await cdp.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[{x,y:bottom}]});
    for(let i=1;i<=12;i++) { await cdp.send('Input.dispatchTouchEvent',{type:'touchMove',touchPoints:[{x,y:bottom+(top-bottom)*i/12}]}); await page.waitForTimeout(16); }
    await cdp.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]}); await page.waitForTimeout(220);
    return true;
  };
  const q=async(p,value='pause')=>{
    await p.evaluate(value=>{window.realmQAState=null;window.realmQA(value);},value);await p.waitForFunction(()=>window.realmQAState!==null);await p.waitForTimeout(80);return p.evaluate(()=>window.realmQAState);
  };
  const sessions=new WeakMap();
  const drag=async(p,up=false)=>{
    const s=await q(p),vp=p.viewportSize();const list=s.scrolls.filter(v=>v.max>v.page+5).sort((a,b)=>b.height-a.height)[0];if(!list)return;
    let session=sessions.get(p);if(!session){session=await p.context().newCDPSession(p);sessions.set(p,session);}
    const sx=vp.width/s.viewport[0],sy=vp.height/s.viewport[1],x=Math.min(vp.width-30,(list.x+list.width*.7)*sx);
    const bottom=Math.min(vp.height-85,(list.y+list.height)*sy-25),top=Math.max(90,list.y*sy+80),a=up?top:bottom,b=up?bottom:top;
    await session.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[{x,y:a}]});for(let i=1;i<=12;i++){await session.send('Input.dispatchTouchEvent',{type:'touchMove',touchPoints:[{x,y:a+(b-a)*i/12}]});await p.waitForTimeout(16);}await session.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});await p.waitForTimeout(220);
  };
  const click=async(p,id)=>{
    let s=await q(p),b;for(let i=0;i<12;i++){b=s.buttons.find(b=>b.name===id);if(b)break;await drag(p,i>=6);s=await q(p);}if(!b)throw Error('Missing '+id);
    const vp=p.viewportSize();await p.touchscreen.tap((b.x+b.width/2)*vp.width/s.viewport[0],(b.y+b.height/2)*vp.height/s.viewport[1]);return q(p);
  };
  const fill=async(p,id,value)=>{
    const s=await q(p),f=s.fields.find(f=>f.name===id);if(!f)throw Error('Missing field '+id);
    const vp=p.viewportSize();await p.touchscreen.tap((f.x+f.width/2)*vp.width/s.viewport[0],(f.y+f.height/2)*vp.height/s.viewport[1]);await p.keyboard.type(value);await p.keyboard.press('Tab');
  };
  const settled=async p=>{for(let i=0;i<100;i++){const s=await q(p);if(!s.online.busy)return s;await p.waitForTimeout(100);}throw Error('Online timeout');};
  const community=async(p,tab)=>{await q(p,'close');await q(p,'tab:Mehr');await q(p,'open:community');if(tab!=='Konto')await click(p,'Community_'+tab);return q(p);};
  const signup=async(p,user)=>{await community(p,'Konto');await fill(p,'RealmUsername',user);await fill(p,'RealmPassword','Test-Only-Password-708');await click(p,'RealmRegister');return settled(p);};
  let s;
  if(!process.argv.includes('--only-interface') && !process.argv.includes('--only-chest') && !process.argv.includes('--only-raid')){
  s=await signup(page,'Atlas708');check(s.online.connected,'real UI creates authenticated account');const alice=s.online.state.me.id;
  secondBrowser=await chromium.launch({executablePath:path.resolve(arg('--browser','tools/headless-shell/chrome-headless-shell-linux64/chrome-headless-shell')),args:['--no-sandbox','--no-zygote','--single-process','--disable-dev-shm-usage','--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader']}); const secondContext=await secondBrowser.newContext({viewport:{width:390,height:844},hasTouch:true,isMobile:true});const second=await secondContext.newPage();
  second.on('pageerror',e=>errors.push(e.message));second.on('console',m=>{if(/SCRIPT ERROR|Parse Error|Invalid call/.test(m.text()))errors.push(m.text());});
  await second.goto('http://127.0.0.1:'+port);await second.waitForFunction(()=>!!window.realmQA,null,{timeout:90000});
  let t=await signup(second,'Beta708');check(t.online.connected && t.online.state.me.id!==alice,'second independent browser session has separate account');const bob=t.online.state.me.id;
  await community(page,'Familie');await fill(page,'GuildName','Himmelsbund');await fill(page,'GuildTag','HIM');await click(page,'GuildCreate');s=await settled(page);
  check(s.online.state.guild?.members.length===1,'UI creates guild with real owner');const gid=s.online.state.guild.id;
  await community(second,'Familie');await click(second,'CommunityRefresh');await settled(second);await click(second,'GuildJoin_'+gid);t=await settled(second);
  check(t.online.state.guild.members.length===2,'second browser joins same guild');await click(page,'CommunityRefresh');s=await settled(page);check(s.online.state.guild.members.length===2,'first browser sees shared membership');
  await page.screenshot({path:path.join(shots,'guild-two-players.png')});
  await community(page,'Raid');await click(page,'RaidAttack');s=await settled(page);const firstHP=s.online.state.boss.hp;
  await community(second,'Raid');await click(second,'RaidAttack');t=await settled(second);check(t.online.state.boss.hp<firstHP,'second browser damages same boss');
  await page.waitForTimeout(2300);s=await q(page);check(s.online.state.boss.hp===t.online.state.boss.hp,'first browser polls shared boss HP');check(s.online.state.boss.contributions.length===2,'raid displays both real contributors');
  await page.screenshot({path:path.join(shots,'raid-two-players.png')}); await secondBrowser.close();secondBrowser=null;
  await community(page,'Arena');await click(page,'ArenaFight_'+bob);s=await settled(page);check(s.online.result.rounds?.length>1,'real UI runs server-owned PvP duel');check(Math.abs(s.online.result.rating_delta)<=24,'PvP rating comes from server');
  await page.screenshot({path:path.join(shots,'arena-result.png')});await community(page,'Rangliste');s=await q(page);check(s.online.state.leaderboard.length===2 && s.online.state.leaderboard.every(x=>['Atlas708','Beta708'].includes(x.name)),'ranking has real players without demo entries');await page.screenshot({path:path.join(shots,'leaderboard.png')});
  await community(page,'Konto');await click(page,'RealmBackup');s=await settled(page);check(s.online.state.backup.revision===1,'UI stores versioned private cloud backup');
  await community(page,'Titel');s=await q(page);check(s.buttons.some(b=>b.name==='TitleEquip_wanderer'),'local title collection is visible');await page.screenshot({path:path.join(shots,'titles.png')});
  }
  if(process.argv.includes('--only-raid')){
    s=await signup(page,'AtlasRaid708');check(s.online.connected,'focused raid has real authenticated browser account');
    const other=await (await fetch('http://127.0.0.1:'+port+'/api/v1/register',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({name:'BetaRaid708',password:'Test-Only-Password-708'})})).json();
    await community(page,'Raid');await click(page,'RaidAttack');
    for(let i=0;i<30;i++){s=await q(page);if(s.online.state.boss.hp<6000)break;await page.waitForTimeout(150);}
    check(s.online.state.boss.hp<6000,'browser raid touch reaches server during automatic polling');
    const otherAttack=await (await fetch('http://127.0.0.1:'+port+'/api/v1/boss/attack',{method:'POST',headers:{'Content-Type':'application/json','Authorization':'Bearer '+other.token},body:JSON.stringify({nonce:'focused-raid-708-beta'})})).json();
    for(let i=0;i<40;i++){s=await q(page);if(s.online.state.boss.hp===otherAttack.state.boss.hp && s.online.state.boss.contributions.length===2)break;await page.waitForTimeout(150);}
    check(s.online.state.boss.hp===otherAttack.state.boss.hp,'first browser polls shared boss HP');check(s.online.state.boss.contributions.length===2,'raid displays both real contributors');await page.screenshot({path:path.join(shots,'raid-confirmed.png')});
  }
  if(!process.argv.includes('--only-online') && (!process.argv.includes('--only-raid') || process.argv.includes('--only-chest'))){
  const reach=async id=>{for(let i=0;i<12;i++){s=await state();if(s.buttons.some(b=>b.name===id))return;await swipe();}throw Error('Cannot reach '+id);};
  await cmd('fixture:mastery');
  for(const vp of (process.argv.includes('--only-chest') ? [] : process.argv.includes('--only-wide') ? [{width:960,height:540}] : [{width:320,height:568},{width:390,height:844},{width:430,height:932},{width:960,height:540}])){
    await page.setViewportSize(vp);await page.waitForTimeout(220);await cmd('close');await cmd('tab:Wesen');
    s=await state();if(s.collection_detail)await text('< Sammlung');await text('Helden');await name('HeroCard_realmwachter');await reach('HeroDevelopment');await name('HeroDevelopment');
    s=await state();let profile=JSON.stringify(s.profile),run=s.run_id,hp=s.enemy_hp;
    await name('RankPreview_5');s=await state();check(JSON.stringify(s.profile)===profile && s.run_id===run && s.enemy_hp===hp,'rank preview is cosmetic only '+vp.width);await page.screenshot({path:path.join(shots,'mastery-preview-'+vp.width+'.png')});
    await reach('HeroTrain');s=await state();let oldXp=s.profile.hero_roster.owned.realmwachter.xp;await name('HeroTrain');s=await state();check(s.profile.hero_roster.owned.realmwachter.xp>oldXp,'individual training through touch '+vp.width);
    await reach('HeroAscend');s=await state();const oldRank=s.profile.hero_mastery.heroes.realmwachter?.rank||0;await name('HeroAscend');s=await state();check(s.profile.hero_mastery.heroes.realmwachter.rank===oldRank+1,'individual ascension through touch '+vp.width);
    await name('SheetBack');await cmd('tab:Mehr');s=await state();const entry=s.buttons.find(b=>b.name==='Action_community');check(entry && entry.height*vp.height/s.viewport[1]>=44,'community entry has mobile target '+vp.width);await page.screenshot({path:path.join(shots,'more-'+vp.width+'.png')});
  }
  await page.setViewportSize({width:390,height:844});await page.waitForTimeout(200);await cmd('close');await cmd('fixture:loot');await cmd('tab:Beute');await cmd('open:item:chest:boss_chest');await text('Öffnen');s=await state();check(s.windows.some(w=>w.title==='Wächtertruhe geöffnet'),'real chest reward opens animated reveal');
  await cmd('reveal:0.05');await page.screenshot({path:path.join(shots,'chest-closed.png')});await cmd('reveal:1.2');await page.screenshot({path:path.join(shots,'chest-revealed.png')});const count=s.profile.chests.sealed.length;await text('Einsammeln');s=await state();check(s.profile.chests.sealed.length===count,'closing reveal cannot consume another chest');
  }
  check(errors.length===0,'no browser exceptions or Godot script errors');fs.writeFileSync(report,JSON.stringify({checks,errors},null,2));console.log(JSON.stringify({passed:checks.filter(x=>x.ok).length,total:checks.length,errors}));
  if(secondBrowser){await secondBrowser.close();secondBrowser=null;}await browser.close();await new Promise(r=>server.close(r));process.exitCode=checks.every(x=>x.ok)?0:1;
})().catch(async error=>{console.error(error);if(page){await page.screenshot({path:path.join(shots,'failure.png')}).catch(()=>{});fs.writeFileSync(report+'.state.json',JSON.stringify(await page.evaluate(()=>window.realmQAState).catch(()=>null),null,2));}fs.writeFileSync(report,JSON.stringify({checks,errors,error:String(error)},null,2));if(secondBrowser)await secondBrowser.close();if(browser)await browser.close();if(server)server.close();process.exitCode=1;});
