// Use the excluded tests/review702.tscn scene for QA; never ship that scene.
const { chromium } = require(process.env.REALM_PLAYWRIGHT || 'playwright');
const fs = require('fs'), path = require('path'), http = require('http');
const arg = (name, fallback) => { const i = process.argv.indexOf(name); return i < 0 ? fallback : process.argv[i + 1]; };
const root = path.resolve(arg('--web-root', 'build710/qa'));
const shots = path.resolve(arg('--screenshots', '/tmp/realm710-review'));
const report = path.resolve(arg('--report', 'browser_checks_710.json'));
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
  check(s.profile.hero_roster.active==='runenpaladin' && s.actual_hero==='runenpaladin','actual fresh boot uses Runenpaladin model and art');
  check(Object.keys(s.profile.hero_roster.owned).join(',')==='runenpaladin','fresh player does not own legendary guardian');
  await page.screenshot({path:path.join(shots,'fresh-starter.png')});
  await cmd('fixture709:rich');
  for(const vp of [{width:320,height:568},{width:390,height:844},{width:430,height:932},{width:960,height:540}]){
    await page.setViewportSize(vp);await page.waitForTimeout(150);await cmd('close');await cmd('tab:Wesen');await cmd('open:equipment');await click(page,'EquipmentTab_wings');
    s=await state();const before=JSON.stringify(s.profile);const preview=s.hero_rigs.filter(r=>r.name==='EquipmentComparisonHero');
    check(preview.length===2 && preview.some(r=>r.wings_visible && r.back_layer>0),'candidate wing rig renders above preview background '+vp.width);
    check(JSON.stringify((await state()).profile)===before,'equipment comparison preserves actual profile '+vp.width);
    if(!s.profile.hero_equipment.owned.sky_wings){await text('Freischalten');await text('Ausrüsten');}
    s=await state();check(s.profile.hero_equipment.equipped.wings==='sky_wings','actual wing equip through native touch '+vp.width);
    await page.screenshot({path:path.join(shots,'equipment-wings-'+vp.width+'.png')});
    await name('SheetBack');s=await state();if(s.collection_detail)await text('< Sammlung');await name('HeroCard_runenpaladin');s=await state();
    check(s.hero_rigs.some(r=>r.name==='CollectionHeroRig' && r.hero==='runenpaladin' && r.wings==='sky_wings' && r.wings_visible && r.back_layer>0),'equipped wings visible in collection hero '+vp.width);
    await page.screenshot({path:path.join(shots,'collection-wings-'+vp.width+'.png')});
  }
  await page.setViewportSize({width:390,height:844});await cmd('fixture709:legacy');await cmd('tab:Wesen');s=await state();if(s.collection_detail)await text('< Sammlung');
  const oldGold=s.profile.gold,oldXp=s.profile.xp;await click(page,'AdoptStarter709');await text('Übernehmen');s=await state();
  check(s.actual_hero==='runenpaladin' && s.profile.hero_roster.owned.realmwachter,'old profile transitions without deleting guardian');
  check(s.profile.gold===oldGold && s.profile.xp===oldXp && s.profile.hero_roster.owned.runenpaladin.xp===oldXp,'transition preserves currencies and earned XP');
  await cmd('tab:Kampf');await page.screenshot({path:path.join(shots,'migrated-starter.png')});
  await cmd('fixture709:victory');s=await state();check(s.banners===0,'boss result suppresses overlapping level celebration');await page.screenshot({path:path.join(shots,'boss-result.png')});
  const chests=s.profile.chests.sealed.length;await name('Action_restart');s=await state();check(s.profile.chests.sealed.length===chests && s.tab==='Kampf','continue does not duplicate boss reward');
  await page.screenshot({path:path.join(shots,'next-region.png')});
  await cmd('close');await cmd('fixture710:0');await cmd('fixture710:funds');
  await cmd('tab:Wesen');await cmd('open:equipment');await click(page,'EquipmentTab_wings');
  s=await state();const prices=[],originalXp=s.profile.xp;
  for(let plus=0;plus<15;plus++){
    const before=await state(),oldGold=before.profile.gold,oldShards=before.profile.shards;
    const views=before.hero_rigs.filter(r=>r.name==='EquipmentComparisonHero');
    check(views.length===2&&views[0].wing_plus===plus&&views[1].wing_plus===plus+1,'actual and next visual stage '+plus);
    let btn=before.buttons.find(b=>b.text.startsWith('Verbessern'));
    if(!btn)throw Error('Upgrade button unavailable '+plus);
    const cost=btn.text.match(/(\d+) G \/ (\d+) Splitter/);
    await tap(b=>b.text.startsWith('Verbessern'),'upgrade '+plus);s=await state();
    check(s.profile.hero_equipment.owned.sky_wings.level===plus+2&&oldGold-s.profile.gold===Number(cost[1])&&oldShards-s.profile.shards===Number(cost[2]),'real touch upgrade and exact charge '+(plus+1));
  }
  check(s.profile.xp===originalXp,'wing forging does not alter character XP');
  const capped=JSON.stringify(s.profile);check(s.buttons.some(b=>b.text==='Maximalstufe'&&b.disabled),'maximum cannot be upgraded again');
  for(const vp of [{width:320,height:568},{width:390,height:844},{width:960,height:540}]){
    await page.setViewportSize(vp);await page.waitForTimeout(150);
    await page.screenshot({path:path.join(shots,'wing15-equipment-'+vp.width+'.png')});
    check(JSON.stringify((await state()).profile)===capped,'max wing layout preserves save '+vp.width);
  }
  await page.setViewportSize({width:390,height:844});await name('SheetBack');await cmd('tab:Kampf');await page.screenshot({path:path.join(shots,'wing15-combat.png')});
  await page.setViewportSize({width:390,height:844});
  for(const plus of [0,1,5,10,15]){
    await cmd('fixture710:'+plus);await cmd('tab:Wesen');s=await state();if(s.collection_detail)await text('< Sammlung');
    await name('HeroCard_runenpaladin');await page.screenshot({path:path.join(shots,'wing-stage-'+plus+'.png')});
  }
  await cmd('close');await cmd('tab:Wesen');await cmd('open:equipment');await click(page,'EquipmentTab_chest');
  for(const id of ['astral_plate','eclipse_plate']){
    if(id==='astral_plate'||id==='eclipse_plate'){
      let found=false;
      for(let i=0;i<8;i++){s=await state();if(s.buttons.some(b=>b.item?.id===id)){found=true;break;}await swipe();}
      if(!found)throw Error('Missing armor card '+id);
      await tap(b=>b.item?.id===id,id);
    }
    s=await state();if(!s.profile.hero_equipment.owned[id])await text('Freischalten');
    s=await state();if(s.profile.hero_equipment.equipped.chest!==id)await text('Ausrüsten');
    s=await state();check(s.profile.hero_equipment.equipped.chest===id&&s.hero_rigs.some(r=>r.armor===id&&r.armor_details),'actual fitted armor equipped '+id);
    await page.screenshot({path:path.join(shots,'armor-'+id+'.png')});
  }
  await cmd('fixture710:effects_off');s=await state();check(s.hero_rigs.some(r=>r.wings_visible&&r.wing_plus===15),'effects off retains max-level wing shape');
  check(errors.length===0,'no script or browser exceptions');fs.writeFileSync(report,JSON.stringify({checks,errors},null,2));console.log(JSON.stringify({passed:checks.filter(x=>x.ok).length,total:checks.length}));
  await browser.close();await new Promise(resolve=>server.close(resolve));process.exitCode=checks.every(x=>x.ok)?0:1;
})().catch(async error=>{console.error(error);if(page){await page.screenshot({path:path.join(shots,'failure.png')}).catch(()=>{});fs.writeFileSync(report+'.state.json',JSON.stringify(await page.evaluate(()=>window.realmQAState??null).catch(()=>null),null,2));}fs.writeFileSync(report,JSON.stringify({checks,errors,error:String(error)},null,2));if(browser)await browser.close();if(server)server.close();process.exitCode=1;});
