"""Run isolated Godot suites, checkpoint every result and retain timeout evidence."""
from pathlib import Path
import argparse,subprocess,tempfile,os,json
p=argparse.ArgumentParser();p.add_argument('--godot',default='godot');p.add_argument('--report');p.add_argument('--only',nargs='*');p.add_argument('--resume',action='store_true');args=p.parse_args()
if hasattr(os,'sched_getaffinity'):os.sched_setaffinity(0,sorted(os.sched_getaffinity(0))[:4])
r=Path(__file__).resolve().parents[1]/'godot/realm_alliance'
results=json.loads(Path(args.report).read_text()) if args.resume and args.report and Path(args.report).exists() else []
for test in sorted((r/'tests').glob('test_*.gd')):
 if args.only and test.name not in args.only:continue
 if args.resume and any(x['test']==test.name and x['passed'] for x in results):continue
 with tempfile.TemporaryDirectory(prefix='realm62-test-708-') as data:
  try:
   q=subprocess.run([args.godot,'--headless','--path',str(r),'--script','res://tests/'+test.name],env={**os.environ,'XDG_DATA_HOME':data},capture_output=True,text=True,timeout=60)
   out=q.stdout+q.stderr;ok=q.returncode==0 and 'SCRIPT ERROR' not in out and 'ERROR:' not in out
  except subprocess.TimeoutExpired as error:
   decode=lambda v:v.decode(errors='replace') if isinstance(v,bytes) else (v or '')
   out=decode(error.stdout)+decode(error.stderr)+'\nTIMEOUT after 60 seconds';ok=False
 results=[x for x in results if x['test']!=test.name]+[{'test':test.name,'passed':ok,'output':out}]
 if args.report:Path(args.report).write_text(json.dumps(results,indent=2))
 print(('PASS ' if ok else 'FAIL ')+test.name,flush=True)
raise SystemExit(0 if all(x['passed'] for x in results) else 1)
