// Use the excluded tests/review702.tscn scene for QA; never ship that scene.
const { chromium } = require(process.env.REALM_PLAYWRIGHT || 'playwright');
const fs = require('fs'), path = require('path'), http = require('http');
const arg = (name, fallback) => { const i = process.argv.indexOf(name); return i < 0 ? fallback : process.argv[i + 1]; };
const root = path.resolve(arg('--web-root', 'build711/qa'));
const shots = path.resolve(arg('--screenshots', '/tmp/realm711-review'));
const report = path.resolve(arg('--report', 'browser_checks_711.json'));
const checks = [], errors = [];
const check = (ok, label) => { checks.push({ ok: !!ok, label }); console.log(ok?'PASS':'FAIL', label);fs.writeFileSync(report,JSON.stringify({checks,errors},null,2)); };
const mime = { '.html':'text/html', '.js':'application/javascript', '.wasm':'application/wasm', '.png':'image/png' };
let browser, secondBrowser, server, page;
(async () => {
  fs.mkdirSync(shots, { recursive: true });
  const {spawn}=require('child_process'),os=require('os');
  const temporary=fs.mkdtempSync(path.join(os.tmpdir(),'realm708-browser-'));
  const child=spawn('python',[path.resolve(__dirname,'../backend/realm_service.py'),'--port','0','--database',path.join(temporary,'online.sqlite3'),'--web-root',root]);
  const port=await new Promise((resolve,reject)=>{let log='';child.stdout.on('data',v=>{log+=v;const m=log.match(/127\.0\.0\.1:(\d+)/);if(m)resolve(Number(m[1]));});child.on('error',reject);child.on('exit',c=>reject(Error('Backend exited '+c)));});
  server={address:()=>({port}),close:fn=>{child.once('exit',()=>{fs.rmSync(temporary,{recursive:true,force:true});if(fn)fn();});child.kill();}};
  browser = await chromium.launch({ executablePath: path.resolve(arg('--browser', process.env.REALM_BROWSER || '/vercel/browser-tools/chrome')),
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
  let s=await state();
  check(s.actual_hero==='runenpaladin'&&!s.profile.wardrobe.active,'fresh starter and no starter costume');
  await cmd('tab:Wesen');await cmd('open:equipment');await click(page,'EquipmentTab_costume');s=await state();
  check(s.buttons.some(b=>b.name==='CostumeClaim_forest_path'&&b.disabled),'milestone initially locked');
  await cmd('close');await cmd('fixture711:rich');
  for(const vp of [{width:320,height:568},{width:390,height:844},{width:430,height:932},{width:960,height:540}]){
    await page.setViewportSize(vp);await page.waitForTimeout(150);await cmd('close');await cmd('tab:Wesen');await cmd('open:equipment');await click(page,'EquipmentTab_costume');s=await state();
    const snapshot=JSON.stringify(s.profile),gold=s.profile.gold,shards=s.profile.shards;
    check(s.hero_rigs.filter(r=>r.name==='EquipmentComparisonHero').some(r=>r.costume==='forest_path'&&r.costume_visible),'actual costume preview '+vp.width);
    check(JSON.stringify((await state()).profile)===snapshot,'preview does not mutate profile '+vp.width);
    if(!s.profile.wardrobe.owned.forest_path)await click(page,'CostumeClaim_forest_path');
    s=await state();if(s.profile.wardrobe.active!=='forest_path')await click(page,'CostumeEquip_forest_path');s=await state();
    check(s.profile.wardrobe.active==='forest_path'&&s.profile.gold===gold&&s.profile.shards===shards,'free claim and real touch equip '+vp.width);
    await page.screenshot({path:path.join(shots,'costume-equipment-'+vp.width+'.png')});
    const before=(await state()).scrolls.find(x=>x.name==='EquipmentScroll')?.offset||0;await swipe();s=await state();
    check(s.scrolls.some(x=>x.name==='EquipmentScroll'&&x.offset>before),'equipment touch scroll '+vp.width);
    await cmd('close');await cmd('tab:Kampf');s=await state();
    check(s.hero_rigs.some(r=>r.name!=='EquipmentComparisonHero'&&r.costume==='forest_path'&&r.costume_visible),'actual main hero updates '+vp.width);
    await page.screenshot({path:path.join(shots,'costume-combat-'+vp.width+'.png')});
  }
  await page.setViewportSize({width:390,height:844});await cmd('close');await cmd('tab:Wesen');await cmd('open:equipment');await click(page,'EquipmentTab_costume');await click(page,'CostumeEquip_forest_path');
  await cmd('close');await cmd('tab:Kampf');s=await state();check(s.profile.wardrobe.active===''&&!s.hero_rigs.some(r=>r.costume_visible),'real touch unequip updates main hero');
  await cmd('tab:Wesen');await cmd('open:equipment');await click(page,'EquipmentTab_chest');s=await state();
  const gold=s.profile.gold;await text('Freischalten');await text('Ausrüsten');s=await state();
  check(s.profile.hero_equipment.equipped.chest==='wander_leather'&&gold-s.profile.gold===15,'real touch buys and equips leather armor');
  await cmd('close');await cmd('tab:Kampf');await page.screenshot({path:path.join(shots,'wander-leather-combat.png')});
  await cmd('fixture711:family@silver_guard');await page.screenshot({path:path.join(shots,'silver-guard-combat.png')});
  await cmd('fixture711:family@sand_traveler');await page.screenshot({path:path.join(shots,'sand-traveler-combat.png')});
  await cmd('tab:Mehr');
  const motion=[];
  for(let i=0;i<3;i++){
    await click(page,'Action_effects');await cmd('tab:Kampf');s=await state();
    motion.push(s.hero_rigs.find(r=>r.costume==='sand_traveler')?.cloth_motion);
    await cmd('tab:Mehr');
  }
  check(motion.some(v=>v===0)&&motion.some(v=>v>0),'real settings touch stops and restores costume cloth');
  await cmd('tab:Kampf');
  await page.setViewportSize({width:1536,height:1024});
  for(const family of ['wander_leather','silver_guard','forest_path','sand_traveler']){
    await cmd('gallery711:'+family);await page.waitForTimeout(150);await page.screenshot({path:path.join(shots,'poses-'+family+'.png')});
  }
  await cmd('gallery711:close');check(errors.length===0,'no browser, script or shader errors');
  fs.writeFileSync(report,JSON.stringify({checks,errors},null,2));console.log(JSON.stringify({passed:checks.filter(x=>x.ok).length,total:checks.length}));
  await browser.close();await new Promise(resolve=>server.close(resolve));process.exitCode=checks.every(x=>x.ok)?0:1;
})().catch(async error=>{console.error(error);if(page){await page.screenshot({path:path.join(shots,'failure.png')}).catch(()=>{});fs.writeFileSync(report+'.state.json',JSON.stringify(await page.evaluate(()=>window.realmQAState??null).catch(()=>null),null,2));}fs.writeFileSync(report,JSON.stringify({checks,errors,error:String(error)},null,2));if(browser)await browser.close();if(server)server.close();process.exitCode=1;});
