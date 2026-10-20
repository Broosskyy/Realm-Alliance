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
  const reach=async id=>{for(let i=0;i<8;i++){const s=await state();if(s.buttons.some(b=>b.name===id))return;await swipe();}throw Error('Cannot reach '+id);};
  for(const vp of [{width:320,height:568},{width:390,height:844},{width:430,height:932},{width:960,height:540}]){
    await page.setViewportSize(vp);await page.waitForTimeout(180);let s=await cmd('tab:Wesen');
    if(s.collection_detail)await text('< Sammlung');await text('Helden');
    await page.screenshot({path:path.join(shots,'tools-final-'+vp.width+'.png')});
    await name('HeroCard_realmwachter');await reach('HeroPreviewAttack');s=await state();let profile=JSON.stringify(s.profile),run=s.run_id,hp=s.enemy_hp;
    await name('HeroPreviewAttack');s=await state();check(s.preview.busy,'final hero preview touch '+vp.width);
    check(JSON.stringify(s.profile)===profile && s.run_id===run && s.enemy_hp===hp,'final preview remains presentation-only '+vp.width);
    await cmd('open:equipment:weapon');s=await state();
    check(s.window_labels.some(t=>t.startsWith('Nächste Stufe: Angriff')),'next values remain visible in final sheet '+vp.width);
    const level=s.profile.inventory.steel.level,gold=s.profile.gold;
    for(let i=0;i<6;i++){s=await state();if(s.buttons.some(b=>b.text.startsWith('Verbessern')))break;await swipe();}
    await tap(b=>b.text.startsWith('Verbessern'),'final upgrade');s=await state();
    check(s.profile.inventory.steel.level===level+1 && s.profile.gold===gold-(20+(level-1)*17),'final action order performs exact upgrade '+vp.width);
    await page.screenshot({path:path.join(shots,'upgrade-final-'+vp.width+'.png')});await name('SheetBack');
  }
  check(errors.length===0,'final UI has no script or browser errors');
  fs.writeFileSync(report,JSON.stringify({checks,errors},null,2));console.log(JSON.stringify({passed:checks.filter(x=>x.ok).length,total:checks.length,errors}));
  await browser.close();await new Promise(r=>server.close(r));process.exitCode=checks.every(x=>x.ok)?0:1;
})().catch(async e=>{console.error(e);fs.writeFileSync(report,JSON.stringify({checks,errors,error:String(e)},null,2));if(browser)await browser.close();if(server)server.close();process.exitCode=1;});
