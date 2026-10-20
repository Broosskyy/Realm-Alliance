"""Export a new 710 game pack with the exact already shipped Godot 4.7.2 web engine."""
from pathlib import Path
import argparse,os,re,shutil,subprocess,tempfile,json,hashlib
p=argparse.ArgumentParser();p.add_argument('--godot',default='godot');p.add_argument('--output',required=True);p.add_argument('--qa',action='store_true');a=p.parse_args()
root=Path(__file__).resolve().parents[1];source=root/'godot/realm_alliance';output=Path(a.output).resolve();output.mkdir(parents=True,exist_ok=True)
engine=root/'web_build/709'
if not (engine/'index.wasm').is_file():raise SystemExit('Verified 709 web engine is required')
if hasattr(os,'sched_getaffinity'):os.sched_setaffinity(0,sorted(os.sched_getaffinity(0))[:4])
def export(project):
 base=[a.godot,'--headless','--path',str(project)]
 subprocess.run(base+['--import'],check=True)
 subprocess.run(base+['--export-pack','Web',str(output/'index.pck')],check=True)
if a.qa:
 with tempfile.TemporaryDirectory(prefix='realm710-qa-') as t:
  project=Path(t)/'project';shutil.copytree(source,project,ignore=shutil.ignore_patterns('.godot','*.import'))
  c=project/'project.godot';c.write_text(c.read_text().replace('run/main_scene="res://scenes/main.tscn"','run/main_scene="res://tests/review702.tscn"'))
  c=project/'export_presets.cfg';c.write_text(c.read_text().replace(',tests/*',''))
  export(project)
else:export(source)
for f in engine.iterdir():
 if f.is_file() and f.name!='index.pck':shutil.copy2(f,output/f.name)
index=output/'index.html';text=index.read_text();text,count=re.subn(r'("index.pck"\s*:\s*)\d+',lambda m:m[1]+str((output/'index.pck').stat().st_size),text)
if count!=1:raise SystemExit('Expected exactly one Godot pack size entry')
index.write_text(text)
(output/'backend').mkdir(exist_ok=True)
for name in ['realm_service.py','README.md']:shutil.copy2(root/'backend'/name,output/'backend'/name)
(output/'START_WEB.py').write_text('from pathlib import Path\nimport subprocess,sys\nr=Path(__file__).resolve().parent\nraise SystemExit(subprocess.call([sys.executable,str(r/"backend/realm_service.py"),"--web-root",str(r),*sys.argv[1:]]))\n')
(output/'LIESMICH.txt').write_text('REALM ALLIANCE 710\nPython 3.10+: python3 START_WEB.py; http://127.0.0.1:8765 öffnen.\n'+('QA BUILD - NOT FOR PLAYERS\n' if a.qa else 'Normaler Spielbuild ohne QA-Adapter. Kein öffentlicher Realm vorverbunden.\n'))
manifest={f.name:hashlib.sha256(f.read_bytes()).hexdigest() for f in output.iterdir() if f.name in ['index.pck','index.wasm','index.js']}
(output/'BUILD_710.json').write_text(json.dumps({'version':710,'qa':a.qa,'engine':'Godot 4.7.2; unchanged verified 709 JavaScript/WASM runtime','sha256':manifest},indent=2))
print('Exported 710',output,'QA' if a.qa else 'NORMAL')
