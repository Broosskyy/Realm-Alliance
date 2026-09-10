#!/usr/bin/env python3
from pathlib import Path
import json,re,sys
from PIL import Image
root=Path(__file__).resolve().parents[1]
project=(root/'project.godot').read_text(encoding='utf-8')
game=(root/'MainGame.gd').read_text(encoding='utf-8')
scene=(root/'MainGame.tscn').read_text(encoding='utf-8')
flow=(root/'RuntimeFlowService.gd').read_text(encoding='utf-8')
ui=(root/'UiPolishService.gd').read_text(encoding='utf-8')
save=(root/'SaveGame.gd').read_text(encoding='utf-8')
cfg=json.loads((root/'data/runtime_flow_v1_54.json').read_text(encoding='utf-8'))
swap=json.loads((root/'data/asset_swap_map_v1_54.json').read_text(encoding='utf-8'))
checks=[
 ('version','config/version="1.56"' in project),
 ('runtime autoload','RuntimeFlowService="*res://RuntimeFlowService.gd"' in project),
 ('production autoload','ProductionAssetRegistry="*res://ProductionAssetRegistry.gd"' in project),
 ('priority',cfg.get('pending_presentation_priority')==['spin','journey','puzzle','tower_defense','lane_battle','village_upgrade','afk']),
 ('coordinator','func _restore_next_pending_presentation_v154()' in game and 'RuntimeFlowService.pending_kind()' in game),
 ('journey hub','name="HubJourneyP0"' in scene and 'hub_journey_p0.pressed.connect(_hub_open_journey_v154)' in game),
 ('empty ranking','Keine simulierten Spieler.' in game),
 ('touch','QuickActions' in scene and '_polish_navigation_v154' in ui),
 ('schema','const SAVE_VERSION := 20' in save),
 ('swap',len(swap.get('slots',[]))==8),
 ('production ui binder','ProductionUiBinder = preload("res://ProductionUiBinder.gd")' in game),
]
errors=[n for n,ok in checks if not ok]
funcs=re.findall(r'^func\s+([A-Za-z0-9_]+)\s*\(',game,re.M)
dupes=sorted({f for f in funcs if funcs.count(f)>1})
if dupes: errors.append('duplicate MainGame funcs: '+','.join(dupes))
if errors:
 print(json.dumps({'ok':False,'errors':errors},indent=2));sys.exit(1)
print(json.dumps({'ok':True,'errors':[],'inherited_runtime':'V1.54','production_binding':'V1.56'},indent=2))
