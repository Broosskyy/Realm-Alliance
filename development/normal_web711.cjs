// Use the excluded tests/review702.tscn scene for QA; never ship that scene.
const { chromium } = require(process.env.REALM_PLAYWRIGHT || 'playwright');
const fs = require('fs'), path = require('path'), http = require('http');
const arg = (name, fallback) => { const i = process.argv.indexOf(name); return i < 0 ? fallback : process.argv[i + 1]; };
const root = path.resolve(arg('--web-root', 'build711/web'));
const shots = path.resolve(arg('--screenshots', '/tmp/realm711-review'));
const report = path.resolve(arg('--report', 'normal_web_711.json'));
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
  browser = await chromium.launch({ executablePath: path.resolve(arg('--browser', process.env.REALM_BROWSER || 'tools/headless-shell/chrome-headless-shell-linux64/chrome-headless-shell')),
    args: ['--no-sandbox','--no-zygote','--single-process','--disable-dev-shm-usage','--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader'] });
  const page=await browser.newPage({viewport:{width:390,height:844},hasTouch:true,isMobile:true});
  page.on('pageerror',e=>errors.push(e.message));
  page.on('console',m=>{if(/SCRIPT ERROR|Parse Error|Invalid call/.test(m.text()))errors.push(m.text());});
  await page.goto('http://127.0.0.1:'+server.address().port);
  await page.waitForFunction(()=>!document.querySelector('#status'),null,{timeout:90000});
  const qa=await page.evaluate(()=>typeof window.realmQA);
  check(qa==='undefined','normal export has no QA bridge');
  await page.waitForTimeout(500);await page.screenshot({path:path.join(shots,'normal-boot.png')});
  for(let i=0;i<12;i++){await page.touchscreen.tap(210,440);await page.waitForTimeout(100);}
  await page.waitForTimeout(120);await page.screenshot({path:path.join(shots,'normal-combat.png')});
  for(const [tab,x] of [['Abenteuer',117],['Wesen',195],['Beute',273],['Mehr',351],['Kampf',39]]){
    await page.touchscreen.tap(x,814);await page.waitForTimeout(250);await page.screenshot({path:path.join(shots,'normal-'+tab+'.png')});
  }
  check(errors.length===0,'normal boot and main navigation have no script or browser errors');
  fs.writeFileSync(report,JSON.stringify({normal_build_loaded:true,qa_bridge_absent:qa==='undefined',real_taps:12,main_tabs_opened:5,errors,checks},null,2));
  console.log(JSON.stringify({checks,errors}));await browser.close();await new Promise(r=>server.close(r));
  process.exitCode=checks.every(c=>c.ok)?0:1;
})().catch(async e=>{console.error(e);if(browser)await browser.close();if(server)server.close();process.exitCode=1;});
