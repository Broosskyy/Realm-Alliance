from pathlib import Path
import json,sys
ROOT=Path(__file__).resolve().parents[1]
errors=[]
enc=json.loads((ROOT/'data/encounters_greenvale_p0_v1_4.json').read_text(encoding='utf-8'))
ids=[m['id'] for m in enc['monsters']]
if len(enc.get('rotation',[])) != 14: errors.append('normal rotation must contain 14 IDs')
if len(enc.get('boss_rotation',[])) != 3: errors.append('boss rotation must contain 3 IDs')
for mid in ids:
    for st in ['idle','attack','hit','defeat']:
        if not (ROOT/f'assets/monsters/greenvale/states/{mid}_{st}.png').exists(): errors.append(f'missing {mid}_{st}')
for bid in ['townhall','goldmine','forge','lucktemple']:
    if not (ROOT/f'assets/village/greenvale/production/{bid}.png').exists(): errors.append(f'missing village {bid}')
cat=json.loads((ROOT/'data/asset_canonical_catalog_v159.json').read_text(encoding='utf-8'))
if cat.get('ui_texture_count') != 219: errors.append('canonical V4 UI count changed')
if cat.get('exact_duplicate_groups'): errors.append('unexpected exact duplicate canonical UI files')
sv=(ROOT/'ScreenVisualCalibration.gd').read_text(encoding='utf-8')
if 'more.text = "MODI"' not in sv: errors.append('MODI navigation collapse missing')
if errors:
 print('V1.59 FAIL')
 for e in errors: print('-',e)
 sys.exit(1)
print('V1.59 PASS · 14 normal monsters · 3 bosses · 4-state contract · village mapping · 219 UI textures')
