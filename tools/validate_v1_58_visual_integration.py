from pathlib import Path
import json, re, sys
root=Path(__file__).resolve().parents[1]
errors=[]

# Build/version/master
bi=(root/'BuildInfo.gd').read_text()
for needle in ['SOURCE_VERSION := "V1.58"','MASTER_CONCEPT := "V2.1"','BUILD_NUMBER := 58']:
    if needle not in bi: errors.append('BuildInfo missing '+needle)
proj=(root/'project.godot').read_text()
if 'Realm Alliance V1.58 · Full Visual Integration & Calibration' not in proj:
    errors.append('project.godot title not V1.58')
if 'config/version="1.58"' not in proj:
    errors.append('project.godot config/version not 1.58')

# JSON parse
for p in root.rglob('*.json'):
    try: json.loads(p.read_text())
    except Exception as e: errors.append(f'JSON {p.relative_to(root)}: {e}')

reg=json.loads((root/'data/production_asset_registry.json').read_text())
bind=json.loads((root/'data/runtime_art_bindings_v158.json').read_text())
if 'spin.machine.frame' not in bind.get('bindings',{}): errors.append('spin.machine.frame binding missing')
if bind.get('bindings',{}).get('spin.machine.frame',{}).get('asset')!='atlas:spin_machine_modular_01/asset_06':
    errors.append('spin machine verified asset changed')

# Validate every non-empty binding asset
for role,info in bind.get('bindings',{}).items():
    aid=str(info.get('asset',''))
    if not aid: continue
    if aid.startswith('atlas:'):
        spec=aid[6:]
        if '/' not in spec:
            errors.append(f'{role}: malformed atlas id {aid}'); continue
        atlas,region=spec.split('/',1)
        if atlas not in reg.get('atlases',{}): errors.append(f'{role}: atlas {atlas} missing'); continue
        if region not in reg['atlases'][atlas].get('regions',{}): errors.append(f'{role}: region {region} missing')
    elif aid not in reg.get('textures',{}):
        errors.append(f'{role}: texture {aid} missing')

# Required screen nodes for calibration
scene=(root/'MainGame.tscn').read_text()
for name in ['MonsterButton','MonsterHP','MonsterHPLabel','MonsterProgressLabel','SpinMachineFrame','SpinButton','P0BuildingGrid','FeatureHubGrid','QuestList','ShopVBox','ProgressionVBox','AfkVBox','LiveOpsVBox','BottomMenu']:
    if f'[node name="{name}"' not in scene: errors.append('scene node missing '+name)

# MainGame hooks
mg=(root/'MainGame.gd').read_text()
for needle in ['ScreenVisualCalibration.new().apply(self)','_apply_production_art_v158()','spin.machine.frame','LEBEN %d / %d','SHOP-VORSCHAU','NOCH NICHT VERFÜGBAR','OFFLINE · +%d GOLD']:
    if needle not in mg: errors.append('MainGame missing '+needle)
if 'str(product.get("type"' in mg or 'str(product.get("price_tier"' in mg:
    errors.append('shop still exposes technical type/price tier')
for forbidden in ['SERVERDATEN NOCH NICHT VERBUNDEN','AFK ·',' LV.',' HP"']:
    if forbidden in mg:
        errors.append('legacy player-facing copy remains: '+forbidden)

# Duplicate function names per GDScript file
for p in root.rglob('*.gd'):
    names=re.findall(r'^func\s+([A-Za-z0-9_]+)\s*\(',p.read_text(),flags=re.M)
    dup=sorted({x for x in names if names.count(x)>1})
    if dup: errors.append(f'duplicate funcs {p.relative_to(root)}: {dup}')

# No active legacy wheel art binding
for role,info in bind.get('bindings',{}).items():
    if role.startswith('legacy.wheel') and str(info.get('confidence',''))!='hold':
        errors.append(f'legacy wheel role not hold: {role}')

if errors:
    print('V1.58 VISUAL INTEGRATION QA: FAIL')
    for e in errors: print('-',e)
    sys.exit(1)
print('V1.58 VISUAL INTEGRATION QA: PASS')
print('bindings',len(bind.get('bindings',{})),'atlases',len(reg.get('atlases',{})),'textures',len(reg.get('textures',{})))
