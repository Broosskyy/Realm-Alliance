#!/usr/bin/env python3
import json, pathlib, re, sys
ROOT=pathlib.Path(__file__).resolve().parents[1]
checks=[]
def ok(name, cond, detail=''):
    checks.append((name,bool(cond),detail))

# Version/build
proj=(ROOT/'project.godot').read_text()
build=(ROOT/'BuildInfo.gd').read_text()
ok('project version 1.91','config/version="1.91"' in proj)
ok('build 91','SOURCE_VERSION := "1.91"' in build and 'BUILD_NUMBER := 91' in build)

# JSON + production bindings
for p in ROOT.joinpath('data').glob('*.json'):
    try: json.loads(p.read_text())
    except Exception as e: ok('json '+p.name,False,str(e))
reg=json.loads((ROOT/'data/production_asset_registry.json').read_text())
bind=json.loads((ROOT/'data/runtime_art_bindings_v191.json').read_text())
assets={**reg.get('textures',{}),**reg.get('assets',{})}; atl=reg.get('atlases',{})
missing=[]
for role,b in bind.get('bindings',{}).items():
    if b.get('confidence')=='hold': continue
    aid=str(b.get('asset',''))
    if aid.startswith('atlas:'):
        parts=aid[6:].split('/',1); found=len(parts)==2 and parts[0] in atl and parts[1] in atl[parts[0]].get('regions',{})
    else: found=aid in assets
    if not found: missing.append(f'{role}->{aid}')
ok('v191 bound ids resolve',not missing,', '.join(missing[:10]))
path_missing=[]
for aid,e in assets.items():
    p=str(e.get('path',''))
    if p.startswith('res://') and not (ROOT/p[6:]).exists(): path_missing.append(p)
ok('production paths exist',not path_missing,', '.join(path_missing[:10]))

main=(ROOT/'MainGame.gd').read_text()
for needle,name in [
 ('"tap_hit"','tap hit hook'),('"monster_defeat"','monster defeat hook'),('"spin_motion"','spin motion hook'),
 ('"spin_stop"','spin stop hook'),('"spin_win"','spin win hook'),('"spin_jackpot"','spin jackpot hook'),
 ('play_projectile(self, td_fight_button, td_enemy_marker','td projectile hook'),('ProductionAssetConvergenceV191.apply(self)','v191 convergence hook')]:
    ok(name,needle in main)
svc=(ROOT/'GameplayVfxService.gd').read_text()
ok('presentation service exists','play_overlay' in svc and 'play_projectile' in svc)
ok('vfx service has no PlayerData mutation','PlayerData.' not in svc)
ok('vfx service has no reward/economy authority',not re.search(r'grant_|add_gold|spend_|reward_value\s*=|damage_monster',svc))
world=(ROOT/'GreenvaleWorldDecorationV191.gd').read_text()
ok('greenvale decor production ids',world.count('v190.world.')>=5)
ok('greenvale decor ignores input','MOUSE_FILTER_IGNORE' in world)
registry=(ROOT/'ProductionAssetRegistry.gd').read_text()
ok('registry resolves v190 assets namespace','registry.get("assets", {})' in registry)

failed=[x for x in checks if not x[1]]
print(f'V1.91 STATIC QA: {len(checks)-len(failed)}/{len(checks)} PASS')
for name,good,detail in checks:
    print(('PASS ' if good else 'FAIL ')+name+((' :: '+detail) if detail else ''))
sys.exit(1 if failed else 0)
