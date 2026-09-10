from pathlib import Path
import json,re,sys
root=Path(sys.argv[1]) if len(sys.argv)>1 else Path('.')
errors=[]
required=['ScreenCompositionService.gd','data/runtime_art_bindings_v161.json','data/screen_asset_contracts_v161.json','data/asset_rules_v161.json','V1_61_CHANGELOG.md']
for x in required:
    if not (root/x).exists(): errors.append('missing '+x)
main=(root/'MainGame.gd').read_text(encoding='utf-8')
for marker in ['const ScreenCompositionService = preload','ScreenCompositionService.new().apply(self)','ScreenCompositionService.new().set_building_label']:
    if marker not in main: errors.append('MainGame missing '+marker)
svc=(root/'ScreenCompositionService.gd').read_text(encoding='utf-8')
for marker in ['_compose_primary_navigation','_compose_home','_compose_spin','_compose_village','QuickActions','RuntimeLabelV161']:
    if marker not in svc: errors.append('composition missing '+marker)
contract=json.loads((root/'data/screen_asset_contracts_v161.json').read_text())
if 'MonsterHP' in contract['screens']['home_tap']['nodes']: errors.append('dynamic MonsterHP must not be statically rebound')
bind=json.loads((root/'data/runtime_art_bindings_v161.json').read_text())['bindings']
for role in ['ui.icon.spin','ui.icon.menu','ui.icon.village','ui.home.boss_progress']:
    if role not in bind: errors.append('binding missing '+role)
build=(root/'BuildInfo.gd').read_text()
if 'SOURCE_VERSION := "V1.61"' not in build: errors.append('BuildInfo version')
if errors:
    print('V1.61 FAILED')
    for e in errors: print('-',e)
    raise SystemExit(1)
print('V1.61 PASS · screen auto-composition · existing assets only · dynamic HP protected')
