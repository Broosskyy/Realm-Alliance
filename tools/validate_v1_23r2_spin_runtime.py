from pathlib import Path
import json,sys
r=Path(__file__).resolve().parents[1]
errors=[]
proj=(r/'project.godot').read_text(encoding='utf-8')
scene=(r/'MainGame.tscn').read_text(encoding='utf-8')
main=(r/'MainGame.gd').read_text(encoding='utf-8')
cfg=json.loads((r/'data/spin_3reel_v2_0.json').read_text(encoding='utf-8'))
for x in ['V1.23R2','Master V2.0']:
    if x not in proj: errors.append('project metadata missing '+x)
for reel in ['Reel1','Reel2','Reel3']:
    if f'name="{reel}"' not in scene: errors.append('scene missing '+reel)
    for row in range(3):
        if f'name="{reel}Symbol{row}" type="TextureRect" parent="Safe/VBox/Gameplay/View_CoinMaster/{reel}"' not in scene: errors.append(f'{reel} missing Symbol{row}')
for x in ['_refresh_reel_symbols','_randomize_reel_symbols','reel_stops','SPIN_SYMBOL_PATHS']:
    if x not in main: errors.append('runtime missing '+x)
if cfg.get('reel_count')!=3: errors.append('config reel_count')
if len(cfg.get('segments',[]))!=8: errors.append('reward families')
if (r/'web_platform').exists(): errors.append('web_platform leaked into source')
print(json.dumps({'ok':not errors,'errors':errors,'source':'V1.23R2','master':'V2.0'},indent=2))
sys.exit(1 if errors else 0)
