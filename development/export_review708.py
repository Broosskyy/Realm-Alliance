"""Create a separate, disposable QA web export. Never changes the normal project."""
from pathlib import Path
import argparse, os, shutil, subprocess, tempfile
p=argparse.ArgumentParser();p.add_argument('--godot',default='godot');p.add_argument('--output',required=True);args=p.parse_args()
if hasattr(os,'sched_getaffinity'):os.sched_setaffinity(0,sorted(os.sched_getaffinity(0))[:4])
source=Path(__file__).resolve().parents[1]/'godot/realm_alliance'
output=Path(args.output).resolve();output.mkdir(parents=True,exist_ok=True)
with tempfile.TemporaryDirectory(prefix='realm708-review-') as temp:
    project=Path(temp)/'project';shutil.copytree(source,project,ignore=shutil.ignore_patterns('.godot','*.import'))
    cfg=project/'project.godot';cfg.write_text(cfg.read_text().replace('run/main_scene="res://scenes/main.tscn"','run/main_scene="res://tests/review702.tscn"'))
    cfg=project/'export_presets.cfg';cfg.write_text(cfg.read_text().replace(',tests/*',''))
    base=[args.godot,'--headless','--path',str(project)]
    subprocess.run(base+['--import'],check=True)
    subprocess.run(base+['--export-debug','Web',str(output/'index.html')],check=True)
