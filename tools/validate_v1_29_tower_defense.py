from pathlib import Path
import json,sys
root=Path(__file__).resolve().parents[1]
errors=[]
project=(root/"project.godot").read_text(encoding="utf-8")
flags=(root/"FeatureFlags.gd").read_text(encoding="utf-8")
scene=(root/"MainGame.tscn").read_text(encoding="utf-8")
game=(root/"MainGame.gd").read_text(encoding="utf-8")
save=(root/"SaveGame.gd").read_text(encoding="utf-8")
td=(root/"TowerDefenseSystem.gd").read_text(encoding="utf-8")
cfg=json.loads((root/"data/tower_defense_v1_29.json").read_text(encoding="utf-8"))
checks=[
("autoload",'TowerDefenseSystem="*res://TowerDefenseSystem.gd"' in project),
('version','config/version="1.29"' in project or 'config/version="1.41"' in project or 'config/version="1.38"' in project or 'config/version="1.37"' in project or 'config/version="1.36"' in project or 'config/version="1.30"' in project or 'config/version="1.32"' in project or 'config/version="1.33"' in project or 'config/version="1.34"' in project or 'config/version="1.33"' in project or 'config/version="1.34"' in project or 'config/version="1.31"' in project or 'config/version="1.35"' in project or 'config/version="1.50"' in project or 'config/version="1.51"' in project or 'config/version="1.52"' in project or 'config/version="1.53"' in project),
("flag","const SHOW_TOWER_DEFENSE := true" in flags),
("lane battle forward-compatible","const SHOW_LANE_BATTLE := false" in flags or "const SHOW_LANE_BATTLE := true" in flags),
("view",'name="View_TowerDefense"' in scene),
("entry",'name="DefenseGameButton"' in scene),
("existing TD HUD",'name="TDWaveLabel"' in scene and 'name="TDUpgradeButton"' in scene),
("save export",'"tower_defense": TowerDefenseSystem.export_save_data()' in save),
("save import",'TowerDefenseSystem.apply_save_data(parsed.get("tower_defense", {}))' in save),
("schema","const SAVE_VERSION := 20" in save),
("build","func build_tower" in td),
("fight","func defend_tick" in td),
("runtime","_on_td_fight_pressed" in game and "_on_td_build_pressed" in game),
("waves",int(cfg.get("waves",0))==3),
("primary nav",'text = "HOME"' in scene and 'text = "SPIN"' in scene and 'text = "DORF"' in scene)
]
for label,ok in checks:
 if not ok: errors.append(label)
print(json.dumps({"ok":not errors,"errors":errors,"source":"V1.29"},indent=2))
sys.exit(1 if errors else 0)
