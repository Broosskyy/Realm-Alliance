from pathlib import Path
import json,sys
from PIL import Image
root=Path(__file__).resolve().parents[1]
project=(root/"project.godot").read_text(encoding="utf-8")
lane=(root/"LaneAttackSystem.gd").read_text(encoding="utf-8")
prog=(root/"LaneBattleProgressionSystem.gd").read_text(encoding="utf-8")
game=(root/"MainGame.gd").read_text(encoding="utf-8")
scene=(root/"MainGame.tscn").read_text(encoding="utf-8")
save=(root/"SaveGame.gd").read_text(encoding="utf-8")
live=(root/"LiveOpsRankingSystem.gd").read_text(encoding="utf-8")
cfg=json.loads((root/"data/lane_battle_v1_30.json").read_text(encoding="utf-8"))
swap=json.loads((root/"data/asset_swap_map_v1_50.json").read_text(encoding="utf-8"))
checks=[
("version",'config/version="1.50"' in project or 'config/version="1.51"' in project or 'config/version="1.52"' in project or 'config/version="1.53"' in project),
("autoload",'LaneBattleProgressionSystem="*res://LaneBattleProgressionSystem.gd"' in project),
("config",cfg.get("version")=="v1.50-lane-v2-06"),
("stages",len(cfg.get("stage_profiles",[]))==6),
("battle id",'"battle_id":current_battle_id' in lane),
("pending",'pending_battle_result=result.duplicate(true)' in lane),
("save-before-emit",lane.find("pending_battle_result=result.duplicate(true)")<lane.find("battle_finished.emit(won,result)")),
("tech","func upgrade_unit_tech()" in prog),
("mastery","func register_win()" in prog and "func register_deployment()" in prog),
("next CTA",'name="LaneNextBattleP0"' in scene and "func _start_next_lane_battle_v150()" in game),
("no auto home",'await get_tree().create_timer(0.8 if SettingsService.reduced_motion else 1.2).timeout\n\t_switch_view(view_tap)' not in game),
("restore","func _restore_pending_lane_battle_v150()" in game),
("save progression",'"lane_battle_progression": LaneBattleProgressionSystem.export_save_data()' in save),
("load order",save.find('LaneBattleProgressionSystem.apply_save_data(parsed.get("lane_battle_progression", {}))')<save.find('LaneAttackSystem.apply_save_data(parsed.get("lane_battle", {}))')),
("liveops","func register_lane_win()" in live and "LiveOpsRankingSystem.register_lane_win()" in game),
("schema",'const SAVE_VERSION := 20' in save),
("swap",len(swap.get("slots",[]))==8)
]
errors=[label for label,ok in checks if not ok]
assets=list((root/"assets/v150_lane").glob("V150_*.png"))
if len(assets)!=8: errors.append("asset count")
for a in assets:
 im=Image.open(a)
 if im.size!=(768,768) or im.mode!="RGBA": errors.append("asset format:"+a.name)
print(json.dumps({"ok":not errors,"errors":errors,"assets":len(assets),"source":"V1.50"},indent=2))
sys.exit(1 if errors else 0)
