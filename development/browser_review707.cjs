// Use the excluded tests/review702.tscn scene for QA; never ship that scene.
const { chromium } = require('playwright');
const fs = require('fs'), path = require('path'), http = require('http');
const arg = (name, fallback) => { const i = process.argv.indexOf(name); return i < 0 ? fallback : process.argv[i + 1]; };
const root = path.resolve(arg('--web-root', 'build707/qa'));
const shots = path.resolve(arg('--screenshots', '/tmp/realm707-review'));
const report = path.resolve(arg('--report', 'browser_checks_707.json'));
const checks = [], errors = [];
const check = (ok, label) => { checks.push({ ok: !!ok, label }); if (!ok) console.log('FAIL', label); };
const mime = { '.html':'text/html', '.js':'application/javascript', '.wasm':'application/wasm', '.png':'image/png' };
let browser, server;
(async () => {
  fs.mkdirSync(shots, { recursive: true });
  server = http.createServer((req, res) => {
    const name = decodeURIComponent(new URL(req.url, 'http://localhost').pathname);
    const file = path.resolve(root, '.' + (name === '/' ? '/index.html' : name));
    if (!file.startsWith(root + path.sep)) { res.writeHead(403); res.end(); return; }
    res.setHeader('Content-Type', mime[path.extname(file)] || 'application/octet-stream');
    fs.createReadStream(file).on('error', () => { res.statusCode = 404; res.end(); }).pipe(res);
  });
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  browser = await chromium.launch({ executablePath: path.resolve(arg('--browser', 'tools/headless-shell/chrome-headless-shell-linux64/chrome-headless-shell')),
    args: ['--no-sandbox','--no-zygote','--single-process','--disable-dev-shm-usage','--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader'] });
  const context = await browser.newContext({ viewport: { width:390, height:844 }, hasTouch:true, isMobile:true });
  const page = await context.newPage();
  page.on('pageerror', error => errors.push(error.message));
  page.on('console', message => { if (/SCRIPT ERROR|Parse Error|Invalid call|Cannot call method/.test(message.text())) errors.push(message.text()); });
  await page.goto('http://127.0.0.1:' + server.address().port);
  await page.waitForFunction(() => !!window.realmQA, { timeout:90000 });
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
  await cmd('fixture:loot');
  for (const vp of [{width:320,height:568},{width:390,height:844},{width:430,height:932},{width:960,height:540}]) {
    const tag=vp.width+'x'+vp.height;
    await page.setViewportSize(vp); await page.waitForTimeout(250); await cmd('close');
    let start=await cmd('tab:Wesen');
    if(start.collection_detail)await text(start.collection_category==='Monster'?'< Monsterbuch':'< Sammlung');
    await text('Monster');
    let s=await state();check(s.collection_category==='Monster','real touch opens monster collection '+tag);
    await name('MonsterCard_cloud_slime');s=await state();
    check(s.collection_detail==='cloud_slime','real touch opens monster entry '+tag);
    await page.screenshot({path:path.join(shots,'monster-'+tag+'.png')});
    await text('< Monsterbuch');await text('Helden');await name('HeroCard_realmwachter');
    s=await state();check(s.collection_detail==='realmwachter','real touch opens hero details '+tag);
    const before=JSON.stringify(s.profile), encounter=s.run_id, hp=s.enemy_hp;
    await name('EquippedSlot_head');s=await state();check(s.windows.length===1,'equipped slot opens correct equipment page '+tag);
    await name('SheetBack');s=await state();check(s.windows.length===0 && s.run_id===encounter && s.enemy_hp===hp && JSON.stringify(s.profile)===before,'back preserves profile and encounter '+tag);
    await cmd('open:hero_skill_0');s=await state();
    const seen=new Set(s.buttons.filter(b=>b.text==='Details & Aufwertung').map(b=>b.name));
    for(let i=0;i<3;i++) {await swipe();s=await state();for(const b of s.buttons.filter(b=>b.text==='Details & Aufwertung'))seen.add(b.name);}
    check(s.windows.length===1 && seen.size===3,'all four skills are reachable by touch scrolling '+tag);
    check(s.scrolls.some(v=>v.offset>0),'actual touch scroll moves skill page '+tag);
    await name('SheetBack');await cmd('tab:Kampf');s=await state();
    const scale=vp.width/s.viewport[0];
    for(const id of ['Kampf','Abenteuer','Wesen','Beute','Mehr','auto']) {
      const b=s.buttons.find(v=>v.name==='Action_'+id), minimum=vp.width<500?43.9:35.9;check(b && b.width*scale>=minimum && b.height*(vp.height/s.viewport[1])>=minimum,'target size '+(vp.width<500?'44 px touch':'36 px desktop')+' '+id+' '+tag);
    }
    await page.screenshot({path:path.join(shots,'combat-'+tag+'.png')});
    await cmd('tab:Beute');s=await state();check(s.fields.some(f=>f.name==='InventorySearch'),'inventory search exists '+tag);
    await text('Besser');s=await state();check(s.buttons.filter(b=>b.item).every(b=>b.item.better),'upgrade filter uses actual item comparisons '+tag);
    await text('Alles');
  }
  await page.setViewportSize({width:390,height:844});await page.waitForTimeout(250);
  await cmd('fixture:bestiary');await cmd('tab:Wesen');await text('< Sammlung').catch(()=>{});await text('Monster');await name('MonsterCard_cloud_slime');
  let s=await state();const gold=s.profile.gold, rank=s.profile.bestiary.claimed.cloud_slime||0;
  await swipe();
  for(let i=0;i<2;i++) { s=await state(); const claim=s.buttons.find(b=>b.name==='BestiaryClaim');const p=await point(claim); if(p.y<page.viewportSize().height-80 && p.y>80) break; await swipe(); }
  await name('BestiaryClaim');s=await state();check(s.profile.bestiary.claimed.cloud_slime===rank+1 && s.profile.gold===gold+20,'real touch pays first mastery reward once');
  check(s.buttons.find(b=>b.name==='BestiaryClaim').disabled,'paid mastery cannot be reclaimed');
  await cmd('tab:Beute');await text('Alles');s=await state();
  let input=s.fields.find(f=>f.name==='InventorySearch'), p=await point(input);await page.touchscreen.tap(p.x,p.y);await page.keyboard.type('Rune');
  s=await state();check(s.fields.some(f=>f.text==='Rune'&&f.focused),'search retains keyboard focus while typing');
  check(s.buttons.filter(b=>b.item).every(b=>b.item.name.toLowerCase().includes('rune')),'search filters real owned items');
  await page.screenshot({path:path.join(shots,'inventory-search.png')});
  await page.keyboard.press('Control+A');await page.keyboard.press('Backspace');await page.keyboard.press('Escape');
  await cmd('pause');await page.screenshot({path:path.join(shots,'inventory-art.png')});
  await cmd('tab:Wesen');await text('< Monsterbuch').catch(()=>{});await text('Helden');await name('HeroCard_realmwachter');await page.screenshot({path:path.join(shots,'hero.png')});
  await cmd('open:hero_skill_0');await page.screenshot({path:path.join(shots,'skills.png')});
  await name('SheetBack');
  const reach = async id => {
    for(let i=0;i<8;i++) {const s=await state();if(s.buttons.some(b=>b.name===id))return;await swipe();}
    throw Error('Cannot reach '+id);
  };
  // Exercise presentation controls through actual touch, with a frozen encounter.
  for(const vp of [{width:320,height:568},{width:390,height:844},{width:430,height:932},{width:960,height:540}]) {
    await page.setViewportSize(vp);await page.waitForTimeout(250);await cmd('tab:Wesen');
    let s=await state();
    if(s.collection_detail)await text(s.collection_category==='Monster'?'< Monsterbuch':'< Sammlung');
    await text('Helden');await name('HeroCard_realmwachter');await reach('HeroPreviewAttack');
    s=await state();let profile=JSON.stringify(s.profile), encounter=s.run_id, hp=s.enemy_hp;
    await name('HeroPreviewAttack');s=await state();
    check(s.preview.kind==='hero' && s.preview.busy,'hero attack preview starts '+vp.width);
    check(JSON.stringify(s.profile)===profile && s.run_id===encounter && s.enemy_hp===hp,'hero preview preserves real game '+vp.width);
    await text('< Sammlung');await text('Begleiter');
    s=await state();const pet=s.buttons.find(b=>b.name.startsWith('HeroCard_'));
    await name(pet.name);await reach('CompanionPreviewCast');s=await state();profile=JSON.stringify(s.profile);
    await name('CompanionPreviewCast');await page.waitForTimeout(420);s=await state();
    check(s.preview.kind==='pet' && s.preview.pose.endsWith('_cast.png'),'pet ability visibly animates '+vp.width);
    await name('CompanionPreviewForm');s=await state();
    check(s.preview.evolved,'development form is available as preview '+vp.width);
    check(JSON.stringify(s.profile)===profile && s.run_id===encounter && s.enemy_hp===hp,'pet form preview preserves ownership, currency and encounter '+vp.width);
    await name('CompanionPreviewForm');s=await state();check(!s.preview.evolved,'return to base preview '+vp.width);
    await page.screenshot({path:path.join(shots,'pet-preview-'+vp.width+'x'+vp.height+'.png')});
  }
  await page.setViewportSize({width:390,height:844});await page.waitForTimeout(250);
  await cmd('open:equipment:weapon');let upgrade=await state();
  check(upgrade.window_labels.some(t=>t.startsWith('Nächste Stufe: Angriff')),'weapon shows exact next upgrade value');
  let steelLevel=upgrade.profile.inventory.steel.level, goldBefore=upgrade.profile.gold;
  await tap(b=>b.text.startsWith('Verbessern'), 'upgrade weapon');upgrade=await state();
  check(upgrade.profile.inventory.steel.level===steelLevel+1 && upgrade.profile.gold===goldBefore-(20+(steelLevel-1)*17),'touch upgrade pays exact displayed weapon price');
  await text('Rüstung');upgrade=await state();check(upgrade.window_labels.some(t=>t.startsWith('Nächste Stufe: HP')),'armor shows next HP and DEF');
  await page.screenshot({path:path.join(shots,'equipment-upgrade.png')});await name('SheetBack');
  await cmd('tab:Kampf');await cmd('attack:');await page.waitForTimeout(280);await page.screenshot({path:path.join(shots,'animated-impact.png')});await cmd('pause');
  check(errors.length===0,'no Godot script errors or browser exceptions');
  fs.writeFileSync(report,JSON.stringify({checks,errors,screenshots:shots},null,2));
  console.log(JSON.stringify({passed:checks.filter(c=>c.ok).length,total:checks.length,errors}));
  await browser.close();await new Promise(resolve=>server.close(resolve));
  process.exitCode=checks.every(c=>c.ok)&&errors.length===0?0:1;
})().catch(async error=>{console.error(error);fs.writeFileSync(report,JSON.stringify({checks,errors,error:String(error)},null,2));if(browser)await browser.close();if(server)server.close();process.exitCode=1;});
