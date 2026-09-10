from pathlib import Path
import json,sys,re
from PIL import Image
root=Path(__file__).resolve().parents[1]
project=(root/"project.godot").read_text(encoding="utf-8")
game=(root/"MainGame.gd").read_text(encoding="utf-8")
scene=(root/"MainGame.tscn").read_text(encoding="utf-8")
flow=(root/"RuntimeFlowService.gd").read_text(encoding="utf-8")
ui=(root/"UiPolishService.gd").read_text(encoding="utf-8")
save=(root/"SaveGame.gd").read_text(encoding="utf-8")
cfg=json.loads((root/"data/runtime_flow_v1_54.json").read_text(encoding="utf-8"))
swap=json.loads((root/"data/asset_swap_map_v1_54.json").read_text(encoding="utf-8"))
ready_start=game.find("func _ready()")
ready_end=game.find("func _restore_next_pending_presentation_v154",ready_start)
boot_segment=game[ready_start:ready_end]
checks=[
("version",'config/version="1.54"' in project),
("autoload",'RuntimeFlowService="*res://RuntimeFlowService.gd"' in project),
("priority",cfg.get("pending_presentation_priority")==["spin","journey","puzzle","tower_defense","lane_battle","village_upgrade","afk"]),
("single boot restore",'_restore_next_pending_presentation_v154()' in boot_segment and '_restore_pending_spin_presentation()' not in boot_segment),
("coordinator",'func _restore_next_pending_presentation_v154()' in game and 'RuntimeFlowService.pending_kind()' in game),
("lane bug fixed",'or LaneAttackSystem.has_pending_battle_result(): return' not in game[game.find("func _restore_pending_lane_battle_v150"):game.find("func _update_defense_nav")]),
("spin chain",'_continue_pending_flow_v154()' in game[game.find("func _close_wheel_reward"):game.find("func _refresh_p0_village")]),
("journey hub",'name="HubJourneyP0"' in scene and 'hub_journey_p0.pressed.connect(_hub_open_journey_v154)' in game),
("hierarchy wording",'keine Wertung der Modi' in scene),
("empty ranking",'Keine simulierten Spieler.' in game),
("attention",'RuntimeFlowService.attention_count()' in game),
("touch",'QuickActions' in scene and '_polish_navigation_v154' in ui),
("schema",'const SAVE_VERSION := 20' in save),
("swap",len(swap.get("slots",[]))==8),
]
errors=[name for name,ok in checks if not ok]
assets=list((root/"assets/v154_runtime_ui").glob("V154_*.png"))
if len(assets)!=8:errors.append("asset count")
for a in assets:
 im=Image.open(a)
 if im.size!=(768,768) or im.mode!="RGBA":errors.append("asset format "+a.name)
# Basic duplicate-function regression check.
funcs=re.findall(r'^func\s+([A-Za-z0-9_]+)\s*\(',game,re.M)
dupes=sorted({f for f in funcs if funcs.count(f)>1})
if dupes:errors.append("duplicate MainGame funcs: "+",".join(dupes))
print(json.dumps({"ok":not errors,"errors":errors,"assets":len(assets),"source":"V1.54"},indent=2))
sys.exit(1 if errors else 0)
