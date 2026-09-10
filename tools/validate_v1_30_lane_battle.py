from pathlib import Path
import json,sys
root=Path(__file__).resolve().parents[1]
errors=[]
project=(root/"project.godot").read_text(encoding="utf-8")
flags=(root/"FeatureFlags.gd").read_text(encoding="utf-8")
scene=(root/"MainGame.tscn").read_text(encoding="utf-8")
game=(root/"MainGame.gd").read_text(encoding="utf-8")
save=(root/"SaveGame.gd").read_text(encoding="utf-8")
lane=(root/"LaneAttackSystem.gd").read_text(encoding="utf-8")
cfg=json.loads((root/"data/lane_battle_v1_30.json").read_text(encoding="utf-8"))
checks=[
("version",'config/version="1.30"' in project or 'config/version="1.41"' in project or 'config/version="1.40"' in project or 'config/version="1.39"' in project or 'config/version="1.38"' in project or 'config/version="1.37"' in project or 'config/version="1.36"' in project or 'config/version="1.31"' in project or 'config/version="1.32"' in project or 'config/version="1.33"' in project or 'config/version="1.34"' in project or 'config/version="1.33"' in project or 'config/version="1.34"' in project or 'config/version="1.35"' in project or 'config/version="1.50"' in project or 'config/version="1.51"' in project or 'config/version="1.52"' in project or 'config/version="1.53"' in project),
("lane flag","const SHOW_LANE_BATTLE := true" in flags),
("legacy attack hidden","const SHOW_ATTACK := false" in flags),
("lane view",'name="View_LaneAttack"' in scene),
("entry",'name="LaneBattleButton"' in scene),
("left control",'name="LaneLeftButton"' in scene),
("right control",'name="LaneRightButton"' in scene),
("data path",'DATA_PATH := "res://data/lane_battle_v1_30.json"' in lane),
("deploy unit","func deploy_unit" in lane),
("legacy alias","func deploy_hero" in lane),
("no hero dependency","HeroSystem" not in lane),
("save export",'"lane_battle": LaneAttackSystem.export_save_data()' in save),
("save import",'LaneAttackSystem.apply_save_data(parsed.get("lane_battle", {}))' in save),
("schema V20","const SAVE_VERSION := 20" in save),
("resume opener","_open_lane_battle_slice" in game and "lane_battle_resume" in game),
("unit telemetry","lane_unit_deployed" in game),
("completion telemetry","lane_battle_complete" in game),
("two lanes","lane_power := [0.0, 0.0]" in lane),
("duration",float(cfg.get("duration_seconds",0))==45.0),
("primary nav",'text = "HOME"' in scene and 'text = "SPIN"' in scene and 'text = "DORF"' in scene)
]
for label,ok in checks:
 if not ok: errors.append(label)
print(json.dumps({"ok":not errors,"errors":errors,"source":"V1.30"},indent=2))
sys.exit(1 if errors else 0)
