"""Package the normal web export and complete tracked sources, excluding signing material."""
from pathlib import Path
import argparse,hashlib,json,subprocess,zipfile,os
p=argparse.ArgumentParser();p.add_argument('--web',required=True);p.add_argument('--output',required=True);a=p.parse_args()
root=Path(__file__).resolve().parents[1];web=Path(a.web).resolve();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=True)
if json.loads((web/'BUILD_712.json').read_text())['qa']:raise SystemExit('QA export cannot be shipped')
webzip=out/'REALM_ALLIANCE_712_Web.zip'
webtmp=webzip.with_suffix('.zip.partial')
with zipfile.ZipFile(webtmp,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for f in sorted(web.rglob('*')):
  if f.is_file():z.write(f,f.relative_to(web))
with webtmp.open('rb') as f:os.fsync(f.fileno())
with zipfile.ZipFile(webtmp) as z:
 if z.testzip() is not None:raise SystemExit('Web archive integrity failed')
webtmp.replace(webzip)
sourcezip=out/'REALM_ALLIANCE_712_Quellen.zip'
tracked=subprocess.check_output(['git','ls-files','-z'],cwd=root).decode().split('\0')
source_manifest={'version':712,'source_commit':subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip(),'files':{}}
if subprocess.run(['git','diff','--quiet','HEAD','--'],cwd=root).returncode:raise SystemExit('Commit source changes before packaging')
sourcetmp=sourcezip.with_suffix('.zip.partial')
with zipfile.ZipFile(sourcetmp,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for name in tracked:
  if not name:continue
  f=root/name
  if f.suffix.lower() in {'.keystore','.jks','.p12','.pfx','.pem'} or f.name=='.env' or f.name.startswith('.env.'):continue
  if not f.is_file():raise SystemExit('Tracked source file missing: '+name)
  z.write(f,Path('Source')/name)
  source_manifest['files'][name]={'bytes':f.stat().st_size,'sha256':hashlib.sha256(f.read_bytes()).hexdigest()}
 z.writestr('Source/SOURCE_MANIFEST_712.json',json.dumps(source_manifest,indent=2)+'\n')
with sourcetmp.open('rb') as f:os.fsync(f.fileno())
with zipfile.ZipFile(sourcetmp) as z:
 if z.testzip() is not None:raise SystemExit('Source archive integrity failed')
sourcetmp.replace(sourcezip)
manifest={}
for f in [webzip,sourcezip]:
 with zipfile.ZipFile(f) as z:
  if z.testzip() is not None:raise SystemExit('Archive integrity failed')
 manifest[f.name]={'bytes':f.stat().st_size,'sha256':hashlib.sha256(f.read_bytes()).hexdigest()}
(out/'SHA256_712.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(json.dumps(manifest,indent=2))
