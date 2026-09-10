#!/usr/bin/env python3
from pathlib import Path
import json, sys
root=Path(__file__).resolve().parents[1]
errors=[]

def need(path):
    p=root/path
    if not p.exists(): errors.append(f'missing {path}')
    return p

need('ProductionUiBinder.gd')
reg=need('data/production_asset_registry.json')
bind=need('data/runtime_art_bindings_v156.json')
main=need('MainGame.gd')
proj=need('project.godot')
if reg.exists() and bind.exists():
    r=json.loads(reg.read_text())
    b=json.loads(bind.read_text())['bindings']
    for role,entry in b.items():
        if entry.get('confidence')=='hold': continue
        aid=entry.get('asset','')
        if aid.startswith('atlas:'):
            key=aid[6:]
            if '/' not in key:
                errors.append(f'bad atlas id {role}: {aid}'); continue
            atlas,region=key.split('/',1)
            if atlas not in r.get('atlases',{}): errors.append(f'missing atlas {atlas} for {role}'); continue
            if region not in r['atlases'][atlas].get('regions',{}): errors.append(f'missing region {atlas}/{region} for {role}')
        else:
            if aid and aid not in r.get('textures',{}): errors.append(f'missing texture {aid} for {role}')

m=main.read_text() if main.exists() else ''
for marker in ['_apply_production_art_v156()', 'spin.symbol.gold', 'ProductionUiBinder.apply_backdrop(panel, role_id', 'spin.payline']:
    if marker not in m: errors.append(f'MainGame missing marker: {marker}')

pr=proj.read_text() if proj.exists() else ''
if 'config/version="1.56"' not in pr: errors.append('project version is not 1.56')

if errors:
    print('V1.56 production-art validation FAILED')
    for e in errors: print('-',e)
    sys.exit(1)
print('V1.56 production-art validation PASS')
print('bindings:', len(json.loads(bind.read_text())['bindings']))
print('atlases:', len(json.loads(reg.read_text()).get('atlases',{})))
