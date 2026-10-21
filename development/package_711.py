"""Package the normal web export and complete tracked sources, excluding signing material."""
from pathlib import Path
import argparse,hashlib,json,subprocess,zipfile
p=argparse.ArgumentParser();p.add_argument('--web',required=True);p.add_argument('--output',required=True);a=p.parse_args()
root=Path(__file__).resolve().parents[1];web=Path(a.web).resolve();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=True)
if json.loads((web/'BUILD_711.json').read_text())['qa']:raise SystemExit('QA export cannot be shipped')
webzip=out/'REALM_ALLIANCE_711_Web.zip'
with zipfile.ZipFile(webzip,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for f in sorted(web.rglob('*')):
  if f.is_file():z.write(f,f.relative_to(web))
sourcezip=out/'REALM_ALLIANCE_711_Quellen.zip'
tracked=subprocess.check_output(['git','ls-files','-z'],cwd=root).decode().split('\0')
source_manifest={'version':711,'source_commit':subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip(),'files':{}}
if subprocess.run(['git','diff','--quiet','HEAD','--'],cwd=root).returncode:raise SystemExit('Commit source changes before packaging')
with zipfile.ZipFile(sourcezip,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for name in tracked:
  if not name:continue
  f=root/name
  if f.suffix.lower() in {'.keystore','.jks','.p12','.pfx','.pem'} or f.name=='.env' or f.name.startswith('.env.'):continue
  if not f.is_file():raise SystemExit('Tracked source file missing: '+name)
  z.write(f,Path('Source')/name)
  source_manifest['files'][name]={'bytes':f.stat().st_size,'sha256':hashlib.sha256(f.read_bytes()).hexdigest()}
 z.writestr('Source/SOURCE_MANIFEST_711.json',json.dumps(source_manifest,indent=2)+'\n')
manifest={}
for f in [webzip,sourcezip]:
 with zipfile.ZipFile(f) as z:
  if z.testzip() is not None:raise SystemExit('Archive integrity failed')
 manifest[f.name]={'bytes':f.stat().st_size,'sha256':hashlib.sha256(f.read_bytes()).hexdigest()}
(out/'SHA256_711.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(json.dumps(manifest,indent=2))
