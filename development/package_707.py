"""Package verified exports and clean sources; never bundles the QA web export."""
from pathlib import Path
import argparse, hashlib, shutil, zipfile
p=argparse.ArgumentParser();p.add_argument('--build',required=True);p.add_argument('--output',required=True);a=p.parse_args()
source=Path(__file__).resolve().parents[1];build=Path(a.build).resolve();out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=True)
apk=out/'REALM_ALLIANCE_707.apk';shutil.copy2(build/'android/REALM_ALLIANCE_707.apk',apk)
web=build/'web'
(web/'START_WEB.py').write_text('from pathlib import Path\nimport os,http.server\nos.chdir(Path(__file__).resolve().parent)\nprint("REALM ALLIANCE: http://127.0.0.1:8000")\nhttp.server.ThreadingHTTPServer(("127.0.0.1",8000),http.server.SimpleHTTPRequestHandler).serve_forever()\n')
(web/'LIESMICH.txt').write_text('REALM ALLIANCE 707\nZIP entpacken, python3 START_WEB.py ausführen und http://127.0.0.1:8000 öffnen.\nDie HTML-Datei braucht einen Webserver. Dies ist die normale Spielfassung ohne QA-Adapter.\n')
webzip=out/'REALM_ALLIANCE_707_Web.zip'
with zipfile.ZipFile(webzip,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
    for file in sorted(web.rglob('*')):
        if file.is_file():z.write(file,file.relative_to(web))
sources=out/'REALM_ALLIANCE_707_Quellen.zip'
excluded={'.godot','.git','node_modules','__pycache__','dist','build'}
with zipfile.ZipFile(sources,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
    for file in sorted(source.rglob('*')):
        relative=file.relative_to(source)
        if file.is_file() and not excluded.intersection(relative.parts) and file.suffix not in {'.import','.pyc'}:z.write(file,Path('Source')/relative)
for file in [webzip,sources]:
    with zipfile.ZipFile(file) as z:assert z.testzip() is None
report=out/'REALM_ALLIANCE_707_Bericht.md'
text=(source/'README_MOCKUP_707.md').read_text()+'\n## Abgabedateien\n\n| Datei | Bytes | SHA-256 |\n| --- | ---: | --- |\n'
for file in [apk,webzip,sources]:text+='| %s | %d | %s |\n'%(file.name,file.stat().st_size,hashlib.sha256(file.read_bytes()).hexdigest())
report.write_text(text)
print('\n'.join(str(x)+' '+str(x.stat().st_size) for x in [apk,webzip,sources,report]))
